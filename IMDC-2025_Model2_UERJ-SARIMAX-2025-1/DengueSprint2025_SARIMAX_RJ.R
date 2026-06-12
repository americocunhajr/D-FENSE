library(Mcomp)
library(forecast)
library(TSA)
library(zoo)
setwd("C:\\Users\\Estat\\Documents\\UERJ\\Extensão\\EstatisticaSemFronteiras\\Dengue_2025\\DengueSprint2025_DataAggregated")
DengueSprint2025_AggregatedData_RJ <- read.csv("DengueSprint2025_AggregatedData_RJ.csv")
DengueSprint2025_AggregatedData_RJ$ln100_casos <- log(DengueSprint2025_AggregatedData_RJ$cases+100)
DengueSprint2025_AggregatedData_RJ_ts <- ts(DengueSprint2025_AggregatedData_RJ,
                                            start = c(2010,1),
                                            frequency = 52)
plot(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"])



# Modelo diferença sazonal para o período T3

plot(window(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"],
            start=c(2010,52),
            end = c(2024,25)))

(m1 <- auto.arima(window(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"],
                         start=c(2011,02),
                         end = c(2024,25)),
                  xreg = cbind(window(DengueSprint2025_AggregatedData_RJ_ts[,"temp_med"],
                                      start=c(2010,52),
                                end = c(2024,23)),
                               ts(rollsumr(DengueSprint2025_AggregatedData_RJ_ts[,"precip_med"],k=52)/52,
                                  start=c(2010,52),
                                  end = c(2024,23),
                                  freq=52))))


(out_m1 <- detectAO(m1))

(M1 <- TSA::arima(window(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"],,
                         start=c(2011,02),
                         end = c(2024,25)),
                  order = c(1,0,1)
                  , seasonal = list(order = c(1,1,1))#,io=out_m1$ind
                  ,xreg = cbind(window(DengueSprint2025_AggregatedData_RJ_ts[,"temp_med"],
                                       start=c(2010,52),
                                       end = c(2024,23)),
                                ts(rollsumr(DengueSprint2025_AggregatedData_RJ_ts[,"precip_med"],k=52)/52,
                                   start=c(2010,52),
                                   end = c(2024,23),
                                   freq=52))     
))

for_M1 <- predict(M1, n.ahead=67
                  ,newxreg=cbind(window(DengueSprint2025_AggregatedData_RJ_ts[,"temp_med"],
                                        start=c(2023,24),
                                        end = c(2024,38)),
                                 ts(rollsumr(DengueSprint2025_AggregatedData_RJ_ts[,"precip_med"],k=52)/52,
                                    start=c(2023,24),
                                    end = c(2024,38),
                                    freq=52))
)


e95 <- qnorm(1-0.05/2,0,1)
e90 <- qnorm(1-0.1/2,0,1)
e80 <- qnorm(1-0.2/2,0,1)
e50 <- qnorm(1-0.5/2,0,1)

data <- window(DengueSprint2025_AggregatedData_RJ_ts[,"epiweek"],
               start=c(2023,26),
               end=c(2024,40))+100
prev_med <- for_M1$pred
lb_95 <- for_M1$pred-e95*for_M1$se
ub_95 <- for_M1$pred+e95*for_M1$se
lb_90 <- for_M1$pred-e90*for_M1$se
ub_90 <- for_M1$pred+e90*for_M1$se
lb_80 <- for_M1$pred-e80*for_M1$se
ub_80 <- for_M1$pred+e80*for_M1$se
lb_50 <- for_M1$pred-e50*for_M1$se
ub_50 <- for_M1$pred+e50*for_M1$se
plot(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"])
lines(for_M1$pred)
lines(ub_95)
saida_T3_csv <- data.frame(Data=data,
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
write.csv(saida_T3_csv[16:67,], 
          "T3_arimax_RJ.csv")



# Modelo diferença sazonal para o período T1

plot(window(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"],
            start=c(2010,52),
            end = c(2022,25)))

(m1 <- auto.arima(window(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"],
                         start=c(2011,02),
                         end = c(2022,25)),
                  xreg = cbind(window(DengueSprint2025_AggregatedData_RJ_ts[,"temp_med"],
                                      start=c(2010,52),
                                      end = c(2022,23)),
                               ts(rollsumr(DengueSprint2025_AggregatedData_RJ_ts[,"precip_med"],k=52)/52,
                                  start=c(2010,52),
                                  end = c(2022,23),
                                  freq=52))))


(out_m1 <- detectAO(m1))

(M1 <- TSA::arima(window(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"],,
                         start=c(2011,02),
                         end = c(2022,25)),
                  order = c(1,0,1)
                  , seasonal = list(order = c(1,1,1))#,io=out_m1$ind
                  ,xreg = cbind(window(DengueSprint2025_AggregatedData_RJ_ts[,"temp_med"],
                                       start=c(2010,52),
                                       end = c(2022,23)),
                                ts(rollsumr(DengueSprint2025_AggregatedData_RJ_ts[,"precip_med"],k=52)/52,
                                   start=c(2010,52),
                                   end = c(2022,23),
                                   freq=52))     
))

for_M1 <- predict(M1, n.ahead=67
                  ,newxreg=cbind(window(DengueSprint2025_AggregatedData_RJ_ts[,"temp_med"],
                                        start=c(2022,24),
                                        end = c(2023,38)),
                                 ts(rollsumr(DengueSprint2025_AggregatedData_RJ_ts[,"precip_med"],k=52)/52,
                                    start=c(2022,24),
                                    end = c(2023,38),
                                    freq=52))
)


e95 <- qnorm(1-0.05/2,0,1)
e90 <- qnorm(1-0.1/2,0,1)
e80 <- qnorm(1-0.2/2,0,1)
e50 <- qnorm(1-0.5/2,0,1)

data <- window(DengueSprint2025_AggregatedData_RJ_ts[,"epiweek"],
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
plot(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"])
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
          "T1_arimax_RJ.csv")



# Modelo diferença sazonal para o período T2

plot(window(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"],
            start=c(2010,52),
            end = c(2023,25)))

(m1 <- auto.arima(window(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"],
                         start=c(2011,02),
                         end = c(2023,25)),
                  xreg = cbind(window(DengueSprint2025_AggregatedData_RJ_ts[,"temp_med"],
                                      start=c(2010,52),
                                      end = c(2023,23)),
                               ts(rollsumr(DengueSprint2025_AggregatedData_RJ_ts[,"precip_med"],k=52)/52,
                                  start=c(2010,52),
                                  end = c(2023,23),
                                  freq=52))))


(out_m1 <- detectAO(m1))

(M1 <- TSA::arima(window(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"],,
                         start=c(2011,02),
                         end = c(2023,25)),
                  order = c(1,0,1)
                  , seasonal = list(order = c(1,1,1))#,io=out_m1$ind
                  ,xreg = cbind(window(DengueSprint2025_AggregatedData_RJ_ts[,"temp_med"],
                                       start=c(2010,52),
                                       end = c(2023,23)),
                                ts(rollsumr(DengueSprint2025_AggregatedData_RJ_ts[,"precip_med"],k=52)/52,
                                   start=c(2010,52),
                                   end = c(2023,23),
                                   freq=52))     
))

for_M1 <- predict(M1, n.ahead=67
                  ,newxreg=cbind(window(DengueSprint2025_AggregatedData_RJ_ts[,"temp_med"],
                                        start=c(2023,24),
                                        end = c(2024,38)),
                                 ts(rollsumr(DengueSprint2025_AggregatedData_RJ_ts[,"precip_med"],k=52)/52,
                                    start=c(2023,24),
                                    end = c(2024,38),
                                    freq=52))
)


e95 <- qnorm(1-0.05/2,0,1)
e90 <- qnorm(1-0.1/2,0,1)
e80 <- qnorm(1-0.2/2,0,1)
e50 <- qnorm(1-0.5/2,0,1)

data <- window(DengueSprint2025_AggregatedData_RJ_ts[,"epiweek"],
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
plot(DengueSprint2025_AggregatedData_RJ_ts[,"ln100_casos"])
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
          "T2_arimax_RJ.csv")


