## Dynamics for Epidemic Surveillance and Evaluation


**D-FENSE: Dynamics for Epidemic Surveillance and Evaluation** is an initiative to deal with Dengue Virus (DENV) epidemics in Brazil. 

This repository stores and shares surveillance and climate data related to DENV epidemics since 2010. It also presents predictive models for DENV outbreaks in the country. This work seeks to address emerging demands for dengue monitoring and forecasting, contributing to detailed analysis and supporting decision-making in public health.
The objectives of this initiative include:

- Storing and organizing relevant data on dengue cases in Brazil;
- Building tools for clear and accessible visualization of dengue-related data;
- Developing mathematical models for reliable short-term dengue progression forecasting;
- Disseminating high-quality information to the interested public, aiding in the understanding and combating of dengue.

### Team
- Americo Cunha Jr (LNCC / UERJ, Brazil)
- Emanuelle Arantes Paixão (LNCC, Brazil)
- Marcello Montillo Provenza (UERJ, Brazil)
- Marcelo Rubens dos Santos do Amaral (UERJ, Brazil)
- Marcio Rentes Borges (LNCC, Brazil)
- Paulo Antonio Andrade Esquef (LNCC, Brazil)
- Sergio Luque (LNCC, Brazil)
- Thiago Malheiros Porcino (LNCC, Brazil)
- Vinicius Layter Xavier (UERJ, Brazil)

### Collaborators
- Christian Soize (Université Gustave Eiffel, France)
- Golnaz Shahtahmassebi (Nottingham Trent University, UK)
- Rebecca E. Morrison (University of Colorado Boulder, USA)

### Repository structure

```
D-FENSE/
│
├── DengueSprint2024_ChallengeRules/           # Official 2024 challenge docs (scope, submission rules, etc)
├── DengueSprint2024_DataAggregated/           # 2024 data after basic aggregation and harmonization
├── DengueSprint2024_DataProcessed/            # 2024 data after spurious values cleaning and noise filtering
├── DengueSprint2024_DataProcessingCode/       # Codes used for data processing in 2024 Sprint
│
├── DengueSprint2025_ChallengeRules/           # Official 2025 challenge docs (scope, submission rules, etc)
├── DengueSprint2025_DataAggregated/           # 2025 data after basic aggregation and harmonization
├── DengueSprint2025_DataProcessed/            # 2025 data after spurious values cleaning and noise filtering
├── DengueSprint2025_DataProcessingCode/       # Codes used for data processing in 2025 Sprint
│
├── DengueSprint2025_DataVisualization/        # Graphs to visualize surveillance and climate variables
│
├── DengueSprint2025_Model1_LNCC-ARp/          # Codes and results obtained with LNCC-ARp model
├── DengueSprint2025_Model2_UERJ-SARIMAX/      # Codes and results obtained with UERJ-SARIMAX model
├── DengueSprint2025_Model3_LNCC-CLiDENGO/     # Codes and results obtained with LNCC-CLiDENGO model
├── DengueSprint2025_Model4_LNCC-SURGE/        # Codes and results obtained with LNCC-SURGE model
```

### Data Source

The raw data used here was obtained in Mosqlimate platform:
[https://sprint.mosqlimate.org/data/](https://sprint.mosqlimate.org/data/)

Reference:
- F. C. Coelho et al., Full dataset for dengue forecasting in Brazil for Infodengue-Mosqlimate sprint 2024, [https://zenodo.org/records/13328231](https://zenodo.org/records/13328231)

### Data Processing

### Data Visualization

### Model 1: LNCC-ARp

### Model 2: UERJ-SARIMAX

### Model 3: LNCC-CLiDENGO

### Model 4: LNCC-SURGE


### How to Cite This Repository

If you wish to cite this repository in a document, please use the following reference:

- D-FENSE: Dynamics for Epidemic Surveillance and Evaluation, GitHub repository, 2024, [https://github.com/americocunhajr/D-FENSE](https://github.com/americocunhajr/D-FENSE)

In BibTeX format:

```bibtex
@misc{D-FENSE-GitHub,
   author       = {A. {Cunha~Jr} et al.},
   title        = { {D-FENSE}: {D}ynamics for {E}pidemic {S}urveillance and {E}valuation},
   year         = {2025},
   publisher    = {GitHub},
   journal      = {GitHub repository},
   howpublished = {https://github.com/americocunhajr/D-FENSE},
}
```

### License

All material available in this repository is licensed under the terms of the CC-BY-NC-ND 4.0 license.

<img src="logo/CC-BY-NC-ND.png" width="20%">

### Institutional support

 <img src="logo/logo_lncc.png" width="25%"> &nbsp; &nbsp; <img src="logo/logo_uerj.png" width="13%"> 

### Funding

<img src="logo/cnpq.png" width="20%"> &nbsp; &nbsp; <img src="logo/capes.png" width="10%">  &nbsp; &nbsp; &nbsp; <img src="logo/faperj.png" width="20%">

### Contact
For any questions or further information, please contact:

Americo Cunha Jr: americo@lncc.br
