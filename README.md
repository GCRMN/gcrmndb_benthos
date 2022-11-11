# gcrmndb_benthos 

## 1. Introduction

Coral reef benthic monitoring have started in different places of the world based on different methods.

`gcrmndb_benthos` is one of the synthetic dataset (the other is `gcrmndb_fish`) created and maintained by the GCRMN.

## 2. How to contribute?


## 3. Description of variables


**Table 1.** List of individual da

| #  | Variable          | Cat.   | Description                                              |
|----|-------------------|--------|----------------------------------------------------------|
| 1  | dataset_id        |        |                                                          |  
| 1  | gcrmn_region      |        |                                                          |  
| 1  | country           |        |                                                          |  
| 1  | territory         |        |                                                          |  
| 1  | lat               |        |                                                          |  
| 1  | long              |        |                                                          |  
| 1  | depth             |        |                                                          |  
| 1  | year              |        |                                                          |  
| 1  | month             |        |                                                          |  
| 1  | day               |        |                                                          |  
| 1  | date              |        |                                                          |  


## 4. Quality checks


**Table 2.** List of quality checks used for the `gcrmndb_benthos` synthetic dataset. Inspired by [Vandepitte *et al*, 2015](https://doi.org/10.1093/database/bau125).

| #  | Cat.          | Variable        | Question                                                                        |
|----|---------------|-----------------|---------------------------------------------------------------------------------|
| 1  |               | lat             | Is the latitude within its possible boundaries (*i.e.* between -90 and 90)?     |  
| 2  |               | long            | Is the longitude within its possible boundaries (*i.e.* between -180 and 180)?  |  


## 5. List of individual datasets


**Table 3.** List of individual datasets integrated in the `gcrmndb_benthos` synthetic dataset. The column *datasetID* is the identifier of individual datasets integrated, *rightsHolder* is the person or organization owning or managing rights over the resource, *accessRights* is the indication of the security status of the resource, *aggregator* is the name of the person in charge of the data integration for the individual dataset considered. The names of column headers (except *aggregator*) correspond to [DarwinCore terms](https://dwc.tdwg.org/terms).

| datasetID   | rightsHolder                                                                                 | accessRights   | aggregator    |
|-------------|----------------------------------------------------------------------------------------------|----------------|---------------|
| 0001        | [CSUN](https://portal.edirepository.org/nis/mapbrowse?scope=edi&identifier=1091&revision=1)  | open           | Wicquart, J.  |         
| 0002        | [CSUN](https://portal.edirepository.org/nis/mapbrowse?scope=edi&identifier=1091&revision=1)  | open           | Wicquart, J.  |                          
| 0003        | AIMS LTMP                                                                                    | upon request   | Wicquart, J.  |                          
| 0004        | MPA Moorea                                                                                   | upon request   | Wicquart, J.  |                              
| 0005        | Polynesia Mana                                                                               | upon request   | Wicquart, J.  |                               
| 0006        | Tiahura                                                                                      | upon request   | Wicquart, J.  |
| 0007        | [Seaview Survey](https://doi.org/10.1038/s41597-020-00698-6)                                 | open           | Wicquart, J.  |
