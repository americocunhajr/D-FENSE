# Carregamento de pacotes necessários para a previsão de séries temporais
library(Mcomp)
library(forecast)
library(TSA)
library(zoo)
# Definição do diretório de trabalho: 
setwd("C:\\Users\\Estat\\Documents\\UERJ\\Extensão\\EstatisticaSemFronteiras\\Dengue_2025\\DengueSprint2025_DataAggregated")
# leitura da base de dados do estado
DengueSprint2025_AggregatedData_TO <- read.csv("DengueSprint2025_AggregatedData_TO.csv")
# Tranformação logaritmica para linearizar as variações que se dão por processo multiplicativo por taxa de transmissão
DengueSprint2025_AggregatedData_TO$ln100_casos <- log(DengueSprint2025_AggregatedData_TO$cases+100)
# Criação de objeto de séries temporais com definição das datas e da frequência dentro do ano.
DengueSprint2025_AggregatedData_TO_ts <- ts(DengueSprint2025_AggregatedData_TO,
                                            start = c(2010,1),
                                            frequency = 52)
# evolução do logaritmo da série de casos
plot(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"])

# Modelo diferença sazonal para o período T3
# inspeção da janela de ajuste do T3:
plot(window(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"],
            start=c(2010,52),
            end = c(2024,25)))
# ajuste automático de modelo sarimax
(m1 <- auto.arima(window(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"],
                         # início que bate com a disponibilidade da precipitação acumulada em um ano com lag de duas semanas
                         start=c(2011,02),
                         end = c(2024,25)),
                  # especificação das variáveis exógenas
                  # primeira variável: temperatura média
                  xreg = cbind(window(DengueSprint2025_AggregatedData_TO_ts[,"temp_med"],
                                      # primeira data com precipitação de um ano disponível
                                      start=c(2010,52),
                                end = c(2024,23)),
                               # segunda variável: precipitação média acumulada nas últimas 52 semanas (um ano)
                               ts(rollsumr(DengueSprint2025_AggregatedData_TO_ts[,"precip_med"],k=52)/52,
                                  # primeira data com precipitação de um ano disponível
                                  start=c(2010,52),
                                  end = c(2024,23),
                                  freq=52))))
# identificação automática de outliers para o modelo ajustado
(out_m1 <- detectAO(m1))

# Estimação do modelo para a previsão 67 semanas à frente. Não é igual ao identificado automaticamente. 
# No relatório explicaremos a regra geral e as exceções. Fins de previsão e de ajuste são diferentes
(M1 <- TSA::arima(window(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"],,
                         start=c(2011,02),
                         end = c(2024,25)),
                  order = c(1,0,1)
                  # comentário na linha seguinte seguinte exclui a possilidade de tratamento de outliers
                  , seasonal = list(order = c(3,1,1))#,io=list(out_m1$ind)
                  ,xreg = cbind(window(DengueSprint2025_AggregatedData_TO_ts[,"temp_med"],
                                       start=c(2010,52),
                                       end = c(2024,23)),
                                ts(rollsumr(DengueSprint2025_AggregatedData_TO_ts[,"precip_med"],k=52)/52,
                                   start=c(2010,52),
                                   end = c(2024,23),
                                   freq=52))
                  ))
# geração das 67 previsões (repetimos as variáveis exógenas de um anos antes)
for_M1 <- predict(M1, n.ahead=67
                  ,newxreg=cbind(window(DengueSprint2025_AggregatedData_TO_ts[,"temp_med"],
                                        start=c(2023,24),
                                        end = c(2024,38)),
                                 ts(rollsumr(DengueSprint2025_AggregatedData_TO_ts[,"precip_med"],k=52)/52,
                                    start=c(2023,24),
                                    end = c(2024,38),
                                    freq=52))
                  )
# Cálculo dos multiplicadores dos intervalos de confiança (envelopes)
e95 <- qnorm(1-0.05/2,0,1)
e90 <- qnorm(1-0.1/2,0,1)
e80 <- qnorm(1-0.2/2,0,1)
e50 <- qnorm(1-0.5/2,0,1)
# organização dos dados das previsões e intervalos de confiança
data <- window(DengueSprint2025_AggregatedData_TO_ts[,"epiweek"],
               start=c(2023,26),
               end=c(2024,40))+100 # recurso para adiantar em um ano as datas
prev_med <- for_M1$pred
lb_95 <- for_M1$pred-e95*for_M1$se
ub_95 <- for_M1$pred+e95*for_M1$se
lb_90 <- for_M1$pred-e90*for_M1$se
ub_90 <- for_M1$pred+e90*for_M1$se
lb_80 <- for_M1$pred-e80*for_M1$se
ub_80 <- for_M1$pred+e80*for_M1$se
lb_50 <- for_M1$pred-e50*for_M1$se
ub_50 <- for_M1$pred+e50*for_M1$se
# inspeção dos dados e previsões
plot(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"])
lines(for_M1$pred,lwd=2)
lines(ub_95,lwd=2,col="red")
lines(lb_95, lwd=2,col="red")

# Preparando os dados pera publicação
# Envolve a conversão dos dados para a escala original
saida_T3_csv <- data.frame(Data=data,
                           prev_med=exp(prev_med)-100,
                           LB_95=ifelse(exp(lb_95)-100<0,0,exp(lb_95)-100),
                           UB_95=exp(ub_95)-100,
                           LB_90=ifelse(exp(lb_90)-100<0,0,exp(lb_90)-100),
                           UB_90=exp(ub_90)-100,
                           LB_80=ifelse(exp(lb_80)-100<0,0,exp(lb_80)-100),
                           UB_80=exp(ub_80)-100,
                           LB_50=ifelse(exp(lb_50)-100<0,0,exp(lb_50)-100),
                           UB_50=exp(ub_50)-100)
write.csv(saida_T3_csv[16:67,], 
          "T3_arimax_TO.csv")



# Daqui em diante repete-se o algoritmo anteriormente comentado
# para os outros intervalos de ajuste e previsão








# Modelo diferença sazonal para o período T1

plot(window(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"],
            start=c(2010,52),
            end = c(2023,25)))

(m1 <- auto.arima(window(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"],
                         start=c(2011,02),
                         end = c(2022,25))
                  ,xreg = cbind(window(DengueSprint2025_AggregatedData_TO_ts[,"temp_med"],
                                      start=c(2010,52),
                                      end = c(2022,23)),
                               ts(rollsumr(DengueSprint2025_AggregatedData_TO_ts[,"precip_med"],k=52)/52,
                                  start=c(2010,52),
                                  end = c(2022,23),
                                  freq=52))
                  ))


(out_m1 <- detectAO(m1))

(M1 <- TSA::arima(window(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"],,
                         start=c(2011,02),
                         end = c(2022,25)),
                  order = c(1,0,1)
                  , seasonal = list(order = c(2,1,1))#,io=out_m1$ind
                  ,xreg = cbind(window(DengueSprint2025_AggregatedData_TO_ts[,"temp_med"],
                                       start=c(2010,52),
                                       end = c(2022,23)),
                                ts(rollsumr(DengueSprint2025_AggregatedData_TO_ts[,"precip_med"],k=52)/52,
                                   start=c(2010,52),
                                   end = c(2022,23),
                                   freq=52))     
))

for_M1 <- predict(M1, n.ahead=67
                  ,newxreg=cbind(window(DengueSprint2025_AggregatedData_TO_ts[,"temp_med"],
                                        start=c(2022,24),
                                        end = c(2023,38)),
                                 ts(rollsumr(DengueSprint2025_AggregatedData_TO_ts[,"precip_med"],k=52)/52,
                                    start=c(2022,24),
                                    end = c(2023,38),
                                    freq=52))
)


e95 <- qnorm(1-0.05/2,0,1)
e90 <- qnorm(1-0.1/2,0,1)
e80 <- qnorm(1-0.2/2,0,1)
e50 <- qnorm(1-0.5/2,0,1)

data <- window(DengueSprint2025_AggregatedData_TO_ts[,"epiweek"],
               start=c(2022,26),
               end=c(2023,40))
prev_med <- for_M1$pred
lb_95 <- for_M1$pred-e95*for_M1$se
ub_95 <- for_M1$pred+e95*for_M1$se
lb_90 <- for_M1$pred-e90*for_M1$se
ub_90 <- for_M1$pred+e90*for_M1$se
lb_80 <- for_M1$pred-e80*for_M1$se
ub_80 <- for_M1$pred+e80*for_M1$se
lb_50 <- for_M1$pred-e50*for_M1$se
ub_50 <- for_M1$pred+e50*for_M1$se
plot(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"])
lines(for_M1$pred)
lines(ub_95)
saida_T1_csv <- data.frame(Data=data,
                           prev_med=exp(prev_med)-100,
                           LB_95=ifelse(exp(lb_95)-100<0,0,exp(lb_95)-100),
                           UB_95=exp(ub_95)-100,
                           LB_90=ifelse(exp(lb_90)-100<0,0,exp(lb_90)-100),
                           UB_90=exp(ub_90)-100,
                           LB_80=ifelse(exp(lb_80)-100<0,0,exp(lb_80)-100),
                           UB_80=exp(ub_80)-100,
                           LB_50=ifelse(exp(lb_50)-100<0,0,exp(lb_50)-100),
                           UB_50=exp(ub_50)-100
)
write.csv(saida_T1_csv[16:67,], 
          "T1_arimax_TO.csv")












# Modelo diferença sazonal para o período T2

plot(window(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"],
            start=c(2010,52),
            end = c(2023,25)))

(m1 <- auto.arima(window(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"],
                         start=c(2011,02),
                         end = c(2023,25)),
                  xreg = cbind(window(DengueSprint2025_AggregatedData_TO_ts[,"temp_med"],
                                      start=c(2010,52),
                                      end = c(2023,23)),
                               ts(rollsumr(DengueSprint2025_AggregatedData_TO_ts[,"precip_med"],k=52)/52,
                                  start=c(2010,52),
                                  end = c(2023,23),
                                  freq=52))))


(out_m1 <- detectAO(m1))

(M1 <- TSA::arima(window(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"],,
                         start=c(2011,02),
                         end = c(2023,25)),
                  order = c(1,0,1)
                  , seasonal = list(order = c(2,1,1))#,io=out_m1$ind
                  ,xreg = cbind(window(DengueSprint2025_AggregatedData_TO_ts[,"temp_med"],
                                       start=c(2010,52),
                                       end = c(2023,23)),
                                ts(rollsumr(DengueSprint2025_AggregatedData_TO_ts[,"precip_med"],k=52)/52,
                                   start=c(2010,52),
                                   end = c(2023,23),
                                   freq=52))     
))

for_M1 <- predict(M1, n.ahead=67
                  ,newxreg=cbind(window(DengueSprint2025_AggregatedData_TO_ts[,"temp_med"],
                                        start=c(2023,24),
                                        end = c(2024,38)),
                                 ts(rollsumr(DengueSprint2025_AggregatedData_TO_ts[,"precip_med"],k=52)/52,
                                    start=c(2023,24),
                                    end = c(2024,38),
                                    freq=52))
)


e95 <- qnorm(1-0.05/2,0,1)
e90 <- qnorm(1-0.1/2,0,1)
e80 <- qnorm(1-0.2/2,0,1)
e50 <- qnorm(1-0.5/2,0,1)

data <- window(DengueSprint2025_AggregatedData_TO_ts[,"epiweek"],
               start=c(2023,26),
               end=c(2024,40))
prev_med <- for_M1$pred
lb_95 <- for_M1$pred-e95*for_M1$se
ub_95 <- for_M1$pred+e95*for_M1$se
lb_90 <- for_M1$pred-e90*for_M1$se
ub_90 <- for_M1$pred+e90*for_M1$se
lb_80 <- for_M1$pred-e80*for_M1$se
ub_80 <- for_M1$pred+e80*for_M1$se
lb_50 <- for_M1$pred-e50*for_M1$se
ub_50 <- for_M1$pred+e50*for_M1$se
plot(DengueSprint2025_AggregatedData_TO_ts[,"ln100_casos"])
lines(for_M1$pred)
lines(ub_95)
lines(lb_95)
saida_T2_csv <- data.frame(Data=data,
                           prev_med=exp(prev_med)-100,
                           LB_95=ifelse(exp(lb_95)-100<0,0,exp(lb_95)-100),
                           UB_95=exp(ub_95)-100,
                           LB_90=ifelse(exp(lb_90)-100<0,0,exp(lb_90)-100),
                           UB_90=exp(ub_90)-100,
                           LB_80=ifelse(exp(lb_80)-100<0,0,exp(lb_80)-100),
                           UB_80=exp(ub_80)-100,
                           LB_50=ifelse(exp(lb_50)-100<0,0,exp(lb_50)-100),
                           UB_50=exp(ub_50)-100
)
write.csv(saida_T2_csv[16:67,], 
          "T2_arimax_TO.csv")

