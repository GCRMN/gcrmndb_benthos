# gcrmndb_benthos <img src='figs/hex_logo.png' align="right" height="138.5" />
![status](https://img.shields.io/badge/status-in%20dev.-blue)
![version](https://img.shields.io/badge/version-0.0.0-blue)

## 1. Introduction

### Coral reef monitoring

Coral reef benthic monitoring have started in different places of the world based on different methods.

### What is the GCRMN?

The [*Global Coral Reef Monitoring Network*](https://gcrmn.net/) (GCRMN) is an operational network of the *International Coral Reef Initiative* (ICRI) aiming to provide the best available scientific information on the status and trends of coral reef ecosystems for their conservation and management. The GCRMN is a global network of scientists, managers and organisations that monitor the condition of coral reefs throughout the world, operating through ten regional nodes.

### Why this repository?

This repository aims to . The `gcrmndb_benthos` is a synthetic dataset dedicated to benthic cover monitoring data gathered in coral reefs.

* Data are lost
* Data are heterogeneous
* Data are not findable

The `gcrmndb_benthos` is one of the two synthetic datasets created and maintained by the GCRMN, the other one is the `gcrmndb_fish`.

### How to contribute?

## 2. Data integration

### Definitions

**Table 1.** Definition of main terms used in this README.

| Term                   | Definition                                                                                    | 
|-----------------------:|-----------------------------------------------------------------------------------------------|
| Dataset                | A collection of related sets of information that is composed of separate elements (data files) but can be manipulated as a unit by a computer.         |
| Data aggregator        | Data analyst responsible for the data integration process. |
| Data integration       | Process of combining, merging, or joining data together, in order to make what were distinct, multiple data objects, into a single, unified data object ([Schildhauer, 2018](https://link.springer.com/chapter/10.1007/978-3-319-59928-1_8)).|
| Data provider          | A person or an institution sharing a dataset for which they have been or are involved in the acquisition of the data contained in the dataset. |
| Synthetic dataset      | A dataset resulting from the integration of multiple existing datasets ([Poisot *et al*., 2016](https://onlinelibrary.wiley.com/doi/10.1111/ecog.01941)). |

### Workflow



## 3. Description of variables


**Table 2.** Description of variables included in the `gcrmndb_benthos` synthetic dataset. The icons for the variables categories (`Cat.`) represents :memo: = description variables, :globe_with_meridians: = spatial variables, :calendar: = temporal variables, :straight_ruler: = methodological variables, :crab: = taxonomic variables, :chart_with_upwards_trend: = metric variables.

|     | Variable    | Cat.                       | Description                                              |
|----:|-------------|:--------------------------:|----------------------------------------------------------|
| 1   | dataset_id  | :memo:                     |                                                          |  
| 2   | region      | :globe_with_meridians:     |                                                          |  
| 3   | country     | :globe_with_meridians:     |                                                          |  
| 4   | territory   | :globe_with_meridians:     |                                                          |  
| 5   | location    | :globe_with_meridians:     |                                                          |  
| 6   | site        | :globe_with_meridians:     |                                                          |  
| 7   | zone        | :globe_with_meridians:     |                                                          |  
| 8   | transect    | :globe_with_meridians:     |                                                          |  
| 9   | quadrat     | :globe_with_meridians:     |                                                          |  
| 10  | lat         | :globe_with_meridians:     |                                                          |  
| 11  | long        | :globe_with_meridians:     |                                                          |  
| 12  | depth       | :globe_with_meridians:     |                                                          |  
| 13  | year        | :calendar:                 |                                                          |  
| 14  | month       | :calendar:                 |                                                          |  
| 15  | day         | :calendar:                 |                                                          |  
| 16  | date        | :calendar:                 |                                                          |  
| 17  | method      | :straight_ruler:           |                                                          |  
| 18  | observer    | :straight_ruler:           |                                                          |  
| 19  | category    | :crab:                     |                                                          |  
| 20  | subcategory | :crab:                     |                                                          |  
| 21  | condition   | :crab:                     |                                                          |  
| 22  | family      | :crab:                     |                                                          |  
| 23  | genus       | :crab:                     |                                                          |  
| 24  | species     | :crab:                     |                                                          |  
| 25  | cover       | :chart_with_upwards_trend: |                                                          |  


## 4. Quality checks


**Table 3.** List of quality checks used for the `gcrmndb_benthos` synthetic dataset. Inspired by [Vandepitte *et al*, 2015](https://doi.org/10.1093/database/bau125). The icons for the variables categories (`Cat.`) represents: :globe_with_meridians: = spatial variables, :chart_with_upwards_trend: = metric variables.

| #  | Cat.                       | Variables       | Questions                                                                       |
|:--:|:--------------------------:|-----------------|:--------------------------------------------------------------------------------|
| 1  | :globe_with_meridians:     | `lat`           | Is the latitude within its possible boundaries (*i.e.* between -90 and 90)?     |  
| 2  | :globe_with_meridians:     | `long`          | Is the longitude within its possible boundaries (*i.e.* between -180 and 180)?  |  
| 3  | :globe_with_meridians:     | `lat` `long`    | Is the site within the coral reef distribution area?                            |  
| 4  | :globe_with_meridians:     | `lat` `long`    | Is the site located in sea or along the coastline (5 km buffer)?                |  
| 5  | :globe_with_meridians:     | `depth`         | Is the depth value between 0 and 100?                                           |  
| 7  | :chart_with_upwards_trend: | `cover`         | Is the sum of the percentage cover of benthic categories within the sampling unit greater than 0 and lower than 100? |
| 8  | :chart_with_upwards_trend: | `cover`         | Is the percentage cover of a given benthic category (*i.e.* a row) greater than 0 and lower than 100? |                                    


## 5. List of individual datasets


**Table 4.** List of individual datasets integrated in the `gcrmndb_benthos` synthetic dataset. The column *datasetID* is the identifier of individual datasets integrated, *rightsHolder* is the person or organization owning or managing rights over the resource, *accessRights* is the indication of the security status of the resource, *aggregator* is the name of the person in charge of the data integration for the individual dataset considered. The names of column headers (except *aggregator*) correspond to [DarwinCore terms](https://dwc.tdwg.org/terms).

| datasetID     | rightsHolder                                                                                 | accessRights   | aggregator    |
|:-------------:|----------------------------------------------------------------------------------------------|----------------|---------------|
| 0001          | [CSUN](https://portal.edirepository.org/nis/mapbrowse?scope=edi&identifier=1091&revision=1)  | open           | Wicquart, J.  |         
| 0002          | [CSUN](https://portal.edirepository.org/nis/mapbrowse?scope=edi&identifier=1091&revision=1)  | open           | Wicquart, J.  |                          
| 0003          | AIMS LTMP                                                                                    | upon request   | Wicquart, J.  |                          
| 0004          | MPA Moorea                                                                                   | upon request   | Wicquart, J.  |                              
| 0005          | Polynesia Mana                                                                               | upon request   | Wicquart, J.  |                               
| 0006          | Tiahura                                                                                      | upon request   | Wicquart, J.  |
| 0007          | [Seaview Survey](https://doi.org/10.1038/s41597-020-00698-6)                                 | open           | Wicquart, J.  |
| 0008          | [data-mermaid](https://github.com/data-mermaid/mermaidr)                                     | upon request   | Wicquart, J.  |


## 6. Sponsors

The following organizations have funded the realization of the `gcrmndb_benthos` synthetic dataset:

* The Prince Albert II of Monaco Foundation
* French Ministry of Ecological Transition

## 7. References

* Poisot, T., Gravel, D., Leroux, S., Wood, S. A., Fortin, M. J., Baiser, B., ... & Stouffer, D. B. (**2016**). [Synthetic datasets and community tools for the rapid testing of ecological hypotheses](https://onlinelibrary.wiley.com/doi/10.1111/ecog.01941). *Ecography*, 39(4), 402-408.

* Schildhauer, M. (**2018**). [Data integration: Principles and practice](https://link.springer.com/chapter/10.1007/978-3-319-59928-1_8). In: Recknagel, F., Michener, W.K. (Eds.), *Ecological Informatics*. Springer, pp. 129–157.

* Vandepitte, L., Bosch, S., Tyberghein, L., Waumans, F., Vanhoorne, B., Hernandez, F., [...] and Mees, J. (**2015**). [Fishing for data and sorting the catch: assessing the data quality, completeness and fitness for use of data in marine biogeographic databases](https://doi.org/10.1093/database/bau125). *Database*.

* Wicquart, J., Gudka, M., Obura, D., Logan, M., Staub, F., Souter, D., & Planes, S. (**2022**). [A workflow to integrate ecological monitoring data from different sources](https://www.sciencedirect.com/science/article/pii/S1574954121003344). *Ecological Informatics*, 68, 101543.
