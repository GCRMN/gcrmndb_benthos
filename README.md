
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gcrmndb_benthos <img src='figs/hex_logo.png' align="right" height="138.5" />

![status](https://img.shields.io/badge/status-in%20dev.-blue)
![version](https://img.shields.io/badge/version-0.0.0-blue)

## Table of Contents

- [1. Introduction](#1-introduction)
  - [1.1 What is the GCRMN?](#11-what-is-the-gcrmn)
  - [1.2 Coral reef monitoring](#12-coral-reef-monitoring)
  - [1.3 Why this repository?](#13-why-this-repository)
  - [1.4 How to contribute?](#14-how-to-contribute)
- [2. Data integration](#2-data-integration)
  - [2.1 Definitions](#21-definitions)
  - [2.2 Workflow](#22-workflow)
- [3. Description of variables](#3-description-of-variables)
- [4. Quality checks](#4-quality-checks)
- [5. List of individual datasets](#5-list-of-individual-datasets)
- [6. Description of the synthetic
  dataset](#6-description-of-the-synthetic-dataset)
- [7. Sponsors](#7-sponsors)
- [8. References](#8-references)
- [9. Reproducibility parameters](#9-reproducibility-parameters)

## 1. Introduction

### 1.1 What is the GCRMN?

The [*Global Coral Reef Monitoring Network*](https://gcrmn.net/) (GCRMN)
is an operational network of the [*International Coral Reef
Initiative*](https://icriforum.org/) (ICRI) aiming to provide the best
available scientific information on the status and trends of coral reef
ecosystems for their conservation and management. The GCRMN is a global
network of scientists, managers and organisations that monitor the
condition of coral reefs throughout the world, operating through ten
regional nodes.

### 1.2 Coral reef monitoring

While coral reefs provide many ecosystem services to human populations
and host immense biodiversity, they are directly or indirectly
threatened by human activities. To understand what are the main drivers
of coral reefs’ resilience in the Anthropocene, and to appropriately
inform environmental policies that aim to protect these ecosystems, it
is necessary to have data describing how coral reef integrity is
changing over space and time.

Such data are acquired from ecological monitoring, which consist of
repetitive measurements of a specified set of ecological variables at
one or more locations over an extended period of time ([Vos *et al.*,
2000](https://link.springer.com/article/10.1023/A:1006139412372)). Coral
reef monitoring is usually assessed at local scale by different actors
(*e.g.* research institutes, governments, NGOs), using different data
standards (*i.e.* using different variable names and units). Hence, it
exist numerous heterogeneous datasets based on coral reef monitoring in
the world, which represent a major challenge to assess status and trends
of coral reefs at larger spatial scales.

### 1.3 Why this repository?

This repository aims to gather individual datasets on benthic cover that
have been acquired in the world’s coral reefs over the last decades and
to integrate them into a unique synthetic dataset. This dataset, named
`gcrmndb_benthos`, is used to produce GCRMN reports on status and trends
of coral reefs. In addition to its use for the production of GCRMN
reports, this dataset can possibly be used for macroecological analyses,
although this utilization is restricted to open access individual
datasets integrated. Finally, this repository constitutes an inventory
of existing data on benthic cover in coral reefs (see **Table 5**), and
represents a means to change the culture around data towards the FAIR
principles ([Wilkinson *et al.*,
2016](https://www.nature.com/articles/sdata201618)), and to preserve
these data for future generations.

It is important to note that the `gcrmndb_benthos` is a code repository,
which consist of a hub to store the code used for data integration, and
not a data repository.

The `gcrmndb_benthos` is one of the two synthetic datasets developed and
maintained by the GCRMN, the other one is the `gcrmndb_fish`.

### 1.4 How to contribute?

If you would like to contribute to this initiative by providing a
dataset on benthic cover monitoring data acquired in coral reefs, you
can contact Jérémy Wicquart.

Because the GCRMN is a network based on trust, we are very vigilant
regarding data authorship. **You will always remained the owner of the
dataset you share** within the `gcrmndb_benthos`. You can control the
use that will be made of your dataset by signing a data sharing
agreement. Any new use of your dataset made by the GCRMN will be the
object of a request sent by email. You are free to remove your dataset
from the `gcrmndb_benthos` at any time. Feel free to provide any
suggestions by email on the data integration process or unincluded
individual datasets.

## 2. Data integration

### 2.1 Definitions

**Table 1.** Definition of main terms used in this README.

|                 Term | Definition                                                                                                                                                                                                                                    |
|---------------------:|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|              Dataset | A collection of related sets of information that is composed of separate elements (data files) but can be manipulated as a unit by a computer.                                                                                                |
|      Data aggregator | Data analyst responsible for the data integration process.                                                                                                                                                                                    |
|     Data integration | Process of combining, merging, or joining data together, in order to make what were distinct, multiple data objects, into a single, unified data object ([Schildhauer, 2018](https://link.springer.com/chapter/10.1007/978-3-319-59928-1_8)). |
|        Data provider | A person or an institution sharing a dataset for which they have been or are involved in the acquisition of the data contained in the dataset.                                                                                                |
| Data standardization | Process of converting the data format of a given dataset to a common data format (*i.e.* variables names and units). Data standardization is the preliminary step of data integration.                                                        |
|    Synthetic dataset | A dataset resulting from the integration of multiple existing datasets ([Poisot *et al*., 2016](https://onlinelibrary.wiley.com/doi/10.1111/ecog.01941)).                                                                                     |

### 2.2 Workflow

![](figs/workflow.png)

**Figure 1.** Illustration of the data integration workflow used for the
creation of the `gcrmndb_benthos` synthetic dataset (see [Wicquart *et
al.*,
2022](https://www.sciencedirect.com/science/article/pii/S1574954121003344)).
*EEZ* = Economic Exclusive Zone, *NCBI* = National Center for
Biotechnology Information.

## 3. Description of variables

**Table 2.** Description of variables included in the `gcrmndb_benthos`
synthetic dataset. The icons for the variables categories (`Cat.`)
represents :memo: = description variables, :globe_with_meridians: =
spatial variables, :calendar: = temporal variables, :straight_ruler: =
methodological variables, :crab: = taxonomic variables,
:chart_with_upwards_trend: = metric variables. Variables names (except
*category*, *subcategory*, and *condition*) correspond to [DarwinCore
terms](https://dwc.tdwg.org/terms).

|  \# | Variable         |            Cat.            | Type      | Description                                                                                           |
|----:|:-----------------|:--------------------------:|:----------|:------------------------------------------------------------------------------------------------------|
|   1 | datasetID        |           :memo:           | Factor    | ID of the dataset                                                                                     |
|   2 | higherGeography  |   :globe_with_meridians:   | Factor    | GCRMN region (see [gcrmn_regions](https://github.com/JWicquart/gcrmn_regions))                        |
|   3 | country          |   :globe_with_meridians:   | Factor    | Country (obtained from [World EEZ v11](https://www.marineregions.org/downloads.php) (*SOVEREIGN1*))   |
|   4 | territory        |   :globe_with_meridians:   | Character | Territory (obtained from [World EEZ v11](https://www.marineregions.org/downloads.php) (*TERRITORY1*)) |
|   5 | locality         |   :globe_with_meridians:   | Character | Site name                                                                                             |
|   6 | habitat          |   :globe_with_meridians:   | Factor    | Habitat                                                                                               |
|   7 | parentEventID    |   :globe_with_meridians:   | Integer   | Transect ID                                                                                           |
|   8 | eventID          |   :globe_with_meridians:   | Integer   | Quadrat ID                                                                                            |
|   9 | decimalLatitude  |   :globe_with_meridians:   | Numeric   | Latitude (*decimal, EPSG:4326*)                                                                       |
|  10 | decimalLongitude |   :globe_with_meridians:   | Numeric   | Longitude (*decimal, EPSG:4326*)                                                                      |
|  11 | verbatimDepth    |   :globe_with_meridians:   | Numeric   | Depth (*m*)                                                                                           |
|  12 | year             |         :calendar:         | Integer   | Four-digit year                                                                                       |
|  13 | month            |         :calendar:         | Integer   | Integer month                                                                                         |
|  14 | day              |         :calendar:         | Integer   | Integer day                                                                                           |
|  15 | eventDate        |         :calendar:         | Date      | Date (*YYYY-MM-DD*, ISO 8601)                                                                         |
|  16 | samplingProtocol |      :straight_ruler:      | Character | Description of the method used to acquire the measurement                                             |
|  17 | recordedBy       |      :straight_ruler:      | Character | Name of the person who acquired the measurement                                                       |
|  18 | category         |           :crab:           | Factor    | Benthic category                                                                                      |
|  19 | subcategory      |           :crab:           | Factor    | Benthic subcategory                                                                                   |
|  20 | condition        |           :crab:           | Character |                                                                                                       |
|  21 | phylum           |           :crab:           | Character | Phylum                                                                                                |
|  22 | class            |           :crab:           | Character | Class                                                                                                 |
|  23 | order            |           :crab:           | Character | Order                                                                                                 |
|  24 | family           |           :crab:           | Character | Family                                                                                                |
|  25 | genus            |           :crab:           | Character | Genus                                                                                                 |
|  26 | scientificName   |           :crab:           | Character | Species                                                                                               |
|  27 | measurementValue | :chart_with_upwards_trend: | Numeric   | Percentage cover                                                                                      |

**Table 3.** Description of levels for variables `category` and
`subcategory` (see **Table 2**).

|  category   | subcategory     | Description |
|:-----------:|:----------------|:------------|
|   Abiotic   | Rock            |             |
|             | Rubble          |             |
|             | Sand            |             |
|             | Silt            |             |
|    Algae    | Coralline algae |             |
|             | Cyanobacteria   |             |
|             | Macroalgae      |             |
|             | Turf algae      |             |
| Hard coral  |                 |             |
| Other fauna |                 |             |
|  Seagrass   |                 |             |

## 4. Quality checks

**Table 4.** List of quality checks used for the `gcrmndb_benthos`
synthetic dataset. Inspired by [Vandepitte *et al*,
2015](https://doi.org/10.1093/database/bau125). The icons for the
variables categories (`Cat.`) represents: :globe_with_meridians: =
spatial variables, :calendar: = temporal variables,
:chart_with_upwards_trend: = metric variables. EEZ = Economic Exclusive
Zone.

| \#  |            Cat.            | Variables                            | Questions                                                                                                            |
|:---:|:--------------------------:|--------------------------------------|:---------------------------------------------------------------------------------------------------------------------|
|  1  |   :globe_with_meridians:   | `decimalLatitude` `decimalLongitude` | Are the latitude and longitude available?                                                                            |
|  2  |   :globe_with_meridians:   | `decimalLatitude`                    | Is the latitude within its possible boundaries (*i.e.* between -90 and 90)?                                          |
|  3  |   :globe_with_meridians:   | `decimalLongitude`                   | Is the longitude within its possible boundaries (*i.e.* between -180 and 180)?                                       |
|  4  |   :globe_with_meridians:   | `decimalLatitude` `decimalLongitude` | Is the site within the coral reef distribution area (100 km buffer)?                                                 |
|  5  |   :globe_with_meridians:   | `decimalLatitude` `decimalLongitude` | Is the site located within an EEZ (1 km buffer)?                                                                     |
|  6  |         :calendar:         | `year`                               | Is the year available?                                                                                               |
|  7  | :chart_with_upwards_trend: | `measurementValue`                   | Is the sum of the percentage cover of benthic categories within the sampling unit greater than 0 and lower than 100? |
|  8  | :chart_with_upwards_trend: | `measurementValue`                   | Is the percentage cover of a given benthic category (*i.e.* a row) greater than 0 and lower than 100?                |

## 5. List of individual datasets

**Table 5.** List of individual datasets integrated in the
`gcrmndb_benthos` synthetic dataset. The column *datasetID* is the
identifier of individual datasets integrated, *rightsHolder* is the
person or organization owning or managing rights over the resource,
*accessRights* is the indication of the security status of the resource,
*type* is the type of individual dataset storage and/or acquisition
(*Ar.* = article, *Db.* = database, *Me.* =
[MERMAID](https://dashboard.datamermaid.org/), *Pa.* = data paper, *Rc.*
= [ReefCloud](https://reefcloud.ai/dashboard/), *Rp.* = data repository,
*Sh.* = data sharing), *modified* is the date (YYYY-MM-DD) of the last
version of the individual dataset, *aggregator* is the name of the
person in charge of the data integration for the individual dataset
considered. The column names (except *aggregator*) correspond to
[DarwinCore terms](https://dwc.tdwg.org/terms).

| datasetID | rightsHolder                                                                                                                                            | accessRights   | type |  modified  | aggregator |
|:---------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------|:----:|:----------:|:----------:|
|   0001    | [USVI - Yawzi and Tektite](https://portal.edirepository.org/nis/mapbrowse?scope=edi&identifier=1091&revision=1)                                         | open           | Rp.  | 2022-02-21 |     JW     |
|   0002    | [USVI - Random](https://portal.edirepository.org/nis/mapbrowse?scope=edi&identifier=1091&revision=1)                                                    | open           | Rp.  | 2022-02-21 |     JW     |
|   0003    | AIMS LTMP                                                                                                                                               |                |      |            |     JW     |
|   0004    | [CRIOBE - MPA](https://observatoire.criobe.pf/wiki/tiki-index.php?page=AMP+Moorea&structure=SO+CORAIL)                                                  | upon request   | Sh.  | 2022-09-08 |     JW     |
|   0005    | [CRIOBE - Polynesia Mana](https://observatoire.criobe.pf/wiki/tiki-index.php?page=Transect+corallien+par+photo-quadrat&structure=SO+CORAIL&latest=1)    | upon request   | Sh.  |            |     JW     |
|   0006    | [CRIOBE - Tiahura](https://observatoire.criobe.pf/wiki/tiki-index.php?page=Technique+d%27%C3%A9chantillonnage+Benthos+LTT&structure=SO+CORAIL&latest=1) | upon request   | Sh.  | 2022-12-31 |     JW     |
|   0007    | [CRIOBE - ATPP barrier reef](https://observatoire.criobe.pf/wiki/tiki-index.php?page=R%C3%A9cif+Barri%C3%A8re+ATPP&structure=SO+CORAIL&latest=1)        | upon request   | Sh.  |            |     JW     |
|   0008    | [CRIOBE - ATPP outer slope](https://observatoire.criobe.pf/wiki/tiki-index.php?page=Pente+externe+ATPP&structure=SO+CORAIL&latest=1)                    | upon request   | Sh.  |            |     JW     |
|   0009    | [Seaview Survey](https://www.nature.com/articles/s41597-020-00698-6)                                                                                    | open           | Pa.  |            |     JW     |
|   0010    | [2013-2014_Koro Island, Fiji](https://dashboard.datamermaid.org/?project=2013-2014_Koro%20Island,%20Fiji)                                               | open (summary) | Me.  | 2021-06-08 |     JW     |
|   0011    | [NCRMP - American Samoa](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:NCRMP-StRS-Images-AmSam)                       | open           | Rp.  | 2021-09-14 |     JW     |
|   0012    | [NCRMP - CNMI and Guam](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:NCRMP-StRS-Images-Marianas)                     | open           | Rp.  | 2018-10-12 |     JW     |
|   0013    | [NCRMP - Hawaii](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:NCRMP-StRS-Images-HI)                                  | open           | Rp.  | 2022-11-11 |     JW     |
|   0014    | [NCRMP - PRIA](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:NCRMP-StRS-Images-PRIA)                                  | open           | Rp.  | 2021-07-30 |     JW     |
|   0015    | [ReefCheck - Indo-Pacific](https://www.reefcheck.org/tropical-program/tropical-monitoring-instruction/)                                                 | upon request   | Db.  |            |     JW     |
|   0016    | Biosphere Foundation                                                                                                                                    | upon request   | Sh.  |            |     JW     |
|   0017    | KNS                                                                                                                                                     | upon request   | Sh.  | 2022-12-27 |     JW     |
|   0018    | Kiribati                                                                                                                                                | upon request   | Sh.  | 2020-03-05 |     JW     |
|   0019    | SLN                                                                                                                                                     | upon request   | Sh.  | 2022-05-12 |     JW     |
|   0020    | [PACN](https://www.nps.gov/im/pacn/benthic.htm)                                                                                                         | upon request   | Sh.  |            |     JW     |
|   0021    | RORC                                                                                                                                                    | upon request   | Sh.  |            |     JW     |
|   0022    | [MCRMP](https://micronesiareefmonitoring.com/)                                                                                                          | upon request   | Sh.  |            |     JW     |
|   0023    | PA-NC                                                                                                                                                   | upon request   | Sh.  |            |     JW     |
|   0024    | [Laurent WANTIEZ](https://scholar.google.fr/citations?user=4H_FTE0AAAAJ&hl=fr&oi=ao)                                                                    | upon request   | Sh.  |            |     JW     |
|   0025    | [2011_Southern Bua](https://dashboard.datamermaid.org/?project=2011_Southern%20Bua)                                                                     | open (summary) | Me.  | 2021-09-08 |     JW     |
|   0026    | [2012_Western Bua](https://dashboard.datamermaid.org/?project=2012_Western%20Bua)                                                                       | open (summary) | Me.  | 2021-09-10 |     JW     |
|   0027    | [2009-2011_Kubulau](https://dashboard.datamermaid.org/?project=2009-2011_Kubulau)                                                                       | open (summary) | Me.  | 2021-09-08 |     JW     |
|   0028    | [C<sub>2</sub>O Pacific](https://c2o.net.au/our-work-in-the-pacific/)                                                                                   | upon request   | Rc.  |            |     JW     |
|   0029    | Kimbe Bay                                                                                                                                               | upon request   | Sh.  | 2019-09-11 |     JW     |
|   0030    | [PNG BAF 2019](https://dashboard.datamermaid.org/?project=PNG%20BAF%202019)                                                                             | open (summary) | Me.  | 2019-10-31 |     JW     |
|   0031    | [2017_Northern Lau](https://dashboard.datamermaid.org/?project=2017_Northern%20Lau)                                                                     | open (summary) | Me.  | 2021-02-08 |     JW     |
|   0032    | [2013-2014_Vatu-i-Ra](https://dashboard.datamermaid.org/?project=2013-2014_Vatu-i-Ra)                                                                   | open (summary) | Me.  | 2021-02-08 |     JW     |
|   0033    | [2019_Dama Bureta](https://dashboard.datamermaid.org/?project=2019_Dama%20Bureta%20Waibula%20and%20Dawasamu-WISH%20ecological%20survey)                 | open (summary) | Me.  | 2020-08-12 |     JW     |
|   0034    | [2020_NamenaAndVatuira](https://dashboard.datamermaid.org/?project=2020_NamenaAndVatuira%20coral%20reef%20surveys)                                      | open (summary) | Me.  | 2020-10-12 |     JW     |
|   0035    | [Lau Seascape Surveys](https://dashboard.datamermaid.org/?project=Lau%20Seascape%20Surveys%20March%202022)                                              | open (summary) | Me.  | 2022-04-18 |     JW     |
|   0036    | SI_Munda                                                                                                                                                | open (summary) | Rc.  |            |     JW     |
|   0037    | [Khen et al, 2022](https://link.springer.com/article/10.1007/s00338-022-02271-6)                                                                        | upon request   | Sh.  |            |     JW     |
|   0038    | [Reef Life Survey](https://doi.org/10.1016/j.biocon.2020.108855)                                                                                        | upon request   | Sh.  | 2023-09-13 |     JW     |
|   0039    | [MMR](https://www.mmr.gov.ck/)                                                                                                                          | upon request   | Sh.  | 2023-09-12 |     JW     |
|   0040    |                                                                                                                                                         | upon request   | Sh.  |            |     JW     |
|   0041    | Pouebo                                                                                                                                                  | upon request   | Sh.  |            |     JW     |

## 6. Description of the synthetic dataset

On the 2023-10-18, the `gcrmndb_benthos` synthetic dataset contains a
total of **911,885 observations** (*i.e* rows) representing **10,973
sites** and **24,165 surveys**.

![](figs/map_sites.png)

**Figure 2.** Map of the distribution of benthic cover monitoring sites
for which data are included within the `gcrmndb_benthos` synthetic
dataset. Light grey polygons represents economic exclusive zones.
Colours corresponds to monitoring duration which is the difference, for
each site, between the first and last years with data.

**Table 6.** Summary of the content of the `gcrmndb_benthos` synthetic
dataset per GCRMN region. EAS = East Asian Seas, ETP = Eastern Tropical
Pacific, WIO = Western Indian Ocean. The total number of datasets
integrated within the `gcrmndb_benthos` can differ from the sum of the
column `Datasets (n)`, as some datasets includes sites in different
GCRMN regions.

| GCRMN region | Sites (n) | Surveys (n) | Datasets (n) | First year | Last year |
|-------------:|----------:|------------:|-------------:|:----------:|:---------:|
|    Australia |      1237 |        5314 |            3 |    1995    |   2023    |
|       Brazil |        10 |          11 |            1 |    2012    |   2012    |
|    Caribbean |        97 |         347 |            3 |    1987    |   2022    |
|          EAS |      2510 |        5386 |            3 |    1997    |   2022    |
|          ETP |       239 |         283 |            2 |    1998    |   2018    |
|       PERSGA |        12 |          12 |            1 |    2011    |   2011    |
|      Pacific |      6538 |       12220 |           36 |    1987    |   2023    |
|   South Asia |       163 |         229 |            2 |    1997    |   2022    |
|          WIO |       167 |         363 |            2 |    1997    |   2019    |

**Table 7.** Summary of the content of the `gcrmndb_benthos` synthetic
dataset per country and territory. The total number of datasets
integrated within the `gcrmndb_benthos` can differ from the sum of the
column `Datasets (n)`, as some datasets includes sites in different
territories.

|               Country | Territory                    | Sites (n) | Surveys (n) | Datasets (n) | First year | Last year |
|----------------------:|:-----------------------------|----------:|------------:|-------------:|:----------:|:---------:|
|             Australia | Australia                    |      1208 |        5248 |            3 |    1995    |   2023    |
|             Australia | Christmas Island             |        16 |          30 |            2 |    2003    |   2010    |
|             Australia | Cocos Islands                |        20 |          49 |            1 |    1997    |   2008    |
|            Bangladesh | Bangladesh                   |         2 |           2 |            1 |    2005    |   2006    |
|                Belize | Belize                       |        12 |          22 |            1 |    2015    |   2018    |
|                Brazil | Brazil                       |        10 |          11 |            1 |    2012    |   2012    |
|                Brunei | Brunei                       |        38 |          45 |            1 |    1997    |   2016    |
|              Cambodia | Cambodia                     |        96 |         103 |            2 |    1998    |   2013    |
|                 China | China                        |       100 |         366 |            1 |    1997    |   2012    |
|              Colombia | Colombia                     |        20 |          20 |            2 |    1998    |   2011    |
|              Colombia | Serrana Bank                 |         6 |           6 |            1 |    2016    |   2016    |
|            Costa Rica | Costa Rica                   |        51 |          64 |            2 |    2004    |   2011    |
|            East Timor | East Timor                   |        11 |          13 |            2 |    2004    |   2017    |
|               Ecuador | Galapagos                    |        62 |          62 |            1 |    2008    |   2012    |
|                 Egypt | Egypt                        |        12 |          12 |            1 |    2011    |   2011    |
|                  Fiji | Fiji                         |       567 |         889 |           10 |    1997    |   2022    |
|                France | Europa Island                |         1 |           1 |            1 |    2002    |   2002    |
|                France | French Polynesia             |       223 |        2075 |            7 |    1987    |   2022    |
|                France | Mayotte                      |        20 |          87 |            1 |    2003    |   2017    |
|                France | New Caledonia                |       725 |        3080 |            7 |    1997    |   2023    |
|                France | Réunion                      |        32 |         133 |            1 |    2003    |   2016    |
|                 India | India                        |         1 |           1 |            1 |    1998    |   1998    |
|             Indonesia | Indonesia                    |       665 |        1047 |            2 |    1997    |   2022    |
|                 Japan | Japan                        |        52 |         110 |            2 |    1997    |   2015    |
|                 Kenya | Kenya                        |         6 |           6 |            1 |    2003    |   2004    |
|              Kiribati | Gilbert Islands              |        18 |          18 |            2 |    2011    |   2018    |
|            Madagascar | Madagascar                   |        42 |          54 |            1 |    2001    |   2019    |
|              Malaysia | Malaysia                     |       621 |        2174 |            2 |    1997    |   2021    |
|              Maldives | Maldives                     |       157 |         223 |            2 |    1997    |   2022    |
|      Marshall Islands | Marshall Islands             |        84 |          98 |            3 |    2002    |   2020    |
|                Mexico | Mexico                       |         9 |          10 |            1 |    2018    |   2018    |
|            Micronesia | Micronesia                   |       168 |         385 |            2 |    2000    |   2020    |
|            Mozambique | Mozambique                   |        14 |          15 |            2 |    1997    |   2012    |
|               Myanmar | Myanmar                      |        22 |          29 |            1 |    2001    |   2013    |
|           Netherlands | Bonaire                      |        14 |          14 |            1 |    2012    |   2012    |
|           New Zealand | Cook Islands                 |       172 |         214 |            4 |    2005    |   2023    |
|           New Zealand | Niue                         |         7 |           7 |            1 |    2011    |   2011    |
|             Nicaragua | Nicaragua                    |        23 |          23 |            1 |    2011    |   2015    |
|                 Palau | Palau                        |         6 |          16 |            1 |    1997    |   2006    |
|                Panama | Panama                       |       109 |         140 |            1 |    2007    |   2015    |
|      Papua New Guinea | Papua New Guinea             |        90 |         266 |            4 |    1998    |   2019    |
|           Philippines | Philippines                  |       472 |         703 |            1 |    1997    |   2020    |
| Republic of Mauritius | Republic of Mauritius        |        10 |          12 |            1 |    1999    |   2003    |
|                 Samoa | Samoa                        |         2 |           4 |            2 |    2012    |   2019    |
|            Seychelles | Seychelles                   |        19 |          19 |            2 |    1997    |   2012    |
|       Solomon Islands | Solomon Islands              |        75 |         173 |            4 |    2005    |   2021    |
|          South Africa | South Africa                 |         5 |           6 |            1 |    2001    |   2005    |
|             Sri Lanka | Sri Lanka                    |         3 |           3 |            1 |    2003    |   2003    |
|                Taiwan | Taiwan                       |       103 |         195 |            1 |    1997    |   2020    |
|              Tanzania | Tanzania                     |        18 |          30 |            2 |    1997    |   2012    |
|              Thailand | Thailand                     |       148 |         245 |            1 |    1998    |   2022    |
|                 Tonga | Tonga                        |        29 |          34 |            3 |    2002    |   2019    |
|        United Kingdom | Cayman Islands               |         1 |           1 |            1 |    2011    |   2011    |
|        United Kingdom | Pitcairn                     |         6 |          11 |            2 |    2009    |   2018    |
|        United Kingdom | Turks and Caicos Islands     |         4 |           4 |            1 |    2015    |   2015    |
|         United States | American Samoa               |       843 |         903 |            4 |    1997    |   2019    |
|         United States | Guam                         |       301 |         353 |            4 |    1997    |   2021    |
|         United States | Hawaii                       |      1734 |        1924 |            4 |    1997    |   2021    |
|         United States | Howland and Baker islands    |       150 |         150 |            1 |    2015    |   2017    |
|         United States | Jarvis Island                |       222 |         222 |            1 |    2015    |   2017    |
|         United States | Johnston Atoll               |        46 |          46 |            1 |    2015    |   2015    |
|         United States | Northern Mariana Islands     |       679 |         840 |            3 |    1999    |   2020    |
|         United States | Palmyra Atoll                |       194 |         294 |            2 |    2009    |   2019    |
|         United States | United States                |        17 |          28 |            1 |    2010    |   2022    |
|         United States | United States Virgin Islands |         8 |         236 |            2 |    1987    |   2021    |
|         United States | Wake Island                  |       146 |         146 |            1 |    2014    |   2017    |
|               Vanuatu | Vanuatu                      |        44 |          59 |            2 |    2004    |   2019    |
|               Vietnam | Vietnam                      |       182 |         356 |            1 |    1998    |   2011    |

## 7. Sponsors

The following organizations have funded the realization of the
`gcrmndb_benthos` synthetic dataset:

- The Prince Albert II of Monaco Foundation
- French Ministry of Ecological Transition

## 8. References

- Poisot, T., Gravel, D., Leroux, S., Wood, S. A., Fortin, M. J.,
  Baiser, B., … & Stouffer, D. B. (**2016**). [Synthetic datasets and
  community tools for the rapid testing of ecological
  hypotheses](https://onlinelibrary.wiley.com/doi/10.1111/ecog.01941).
  *Ecography*, 39(4), 402-408.

- Schildhauer, M. (**2018**). [Data integration: Principles and
  practice](https://link.springer.com/chapter/10.1007/978-3-319-59928-1_8).
  In: Recknagel, F., Michener, W.K. (Eds.), *Ecological Informatics*.
  Springer, pp. 129–157.

- Vandepitte, L., Bosch, S., Tyberghein, L., Waumans, F., Vanhoorne, B.,
  Hernandez, F., \[…\] and Mees, J. (**2015**). [Fishing for data and
  sorting the catch: assessing the data quality, completeness and
  fitness for use of data in marine biogeographic
  databases](https://doi.org/10.1093/database/bau125). *Database*.

- Vos, P., E. Meelis, and W. J. Ter Keurs (**2000**). [A Framework for
  the Design of Ecological Monitoring Programs as a Tool for
  Environmental and Nature
  Management](https://link.springer.com/article/10.1023/A:1006139412372).
  Environmental Monitoring and Assessment\* 61(3): 317–44.

- Wicquart, J., Gudka, M., Obura, D., Logan, M., Staub, F., Souter, D.,
  & Planes, S. (**2022**). [A workflow to integrate ecological
  monitoring data from different
  sources](https://www.sciencedirect.com/science/article/pii/S1574954121003344).
  *Ecological Informatics*, 68, 101543.

- Wieczorek J, Bloom D, Guralnick R, Blum S, Döring M, et
  al. (**2012**). [Darwin Core: An Evolving Community-Developed
  Biodiversity Data
  Standard](https://doi.org/10.1371/journal.pone.0029715). *PLoS ONE*
  7(1): e29715.

- Wilkinson, M. D., Dumontier, M., Aalbersberg, I. J., Appleton, G.,
  Axton, M., Baak, A., … & Mons, B. (**2016**). [The FAIR Guiding
  Principles for scientific data management and
  stewardship](https://www.nature.com/articles/sdata201618). *Scientific
  data*, 3(1), 1-9.

## 9. Reproducibility parameters

    R version 4.3.1 (2023-06-16 ucrt)
    Platform: x86_64-w64-mingw32/x64 (64-bit)
    Running under: Windows 10 x64 (build 18363)

    Matrix products: default


    locale:
    [1] LC_COLLATE=French_France.utf8  LC_CTYPE=French_France.utf8   
    [3] LC_MONETARY=French_France.utf8 LC_NUMERIC=C                  
    [5] LC_TIME=French_France.utf8    

    time zone: Europe/Paris
    tzcode source: internal

    attached base packages:
    [1] stats     graphics  grDevices utils     datasets  methods   base     

    other attached packages:
     [1] mermaidr_0.6.4    kableExtra_1.3.4  plotly_4.10.2     rmarkdown_2.25   
     [5] taxize_0.9.100    leaflet_2.2.0     DT_0.30           formattable_0.2.1
     [9] knitr_1.44        sf_1.0-14         lubridate_1.9.3   forcats_1.0.0    
    [13] stringr_1.5.0     dplyr_1.1.3       purrr_1.0.2       readr_2.1.4      
    [17] tidyr_1.3.0       tibble_3.2.1      ggplot2_3.4.4     tidyverse_2.0.0  
    [21] extrafont_0.19   

    loaded via a namespace (and not attached):
     [1] tidyselect_1.2.0   viridisLite_0.4.2  farver_2.1.1       fastmap_1.1.1     
     [5] lazyeval_0.2.2     promises_1.2.1     digest_0.6.33      timechange_0.2.0  
     [9] lifecycle_1.0.3    magrittr_2.0.3     compiler_4.3.1     rlang_1.1.1       
    [13] tools_4.3.1        utf8_1.2.3         yaml_2.3.7         data.table_1.14.8 
    [17] conditionz_0.1.0   htmlwidgets_1.6.2  classInt_0.4-10    curl_5.1.0        
    [21] xml2_1.3.5         KernSmooth_2.23-22 httpcode_0.3.0     withr_2.5.1       
    [25] grid_4.3.1         fansi_1.0.4        e1071_1.7-13       colorspace_2.1-0  
    [29] extrafontdb_1.0    scales_1.2.1       iterators_1.0.14   crul_1.4.0        
    [33] cli_3.6.1          crayon_1.5.2       ragg_1.2.6         generics_0.1.3    
    [37] rstudioapi_0.15.0  httr_1.4.7         tzdb_0.4.0         DBI_1.1.3         
    [41] ape_5.7-1          proxy_0.4-27       rvest_1.0.3        parallel_4.3.1    
    [45] s2_1.1.4           vctrs_0.6.4        webshot_0.5.5      jsonlite_1.8.7    
    [49] hms_1.1.3          systemfonts_1.0.5  crosstalk_1.2.0    foreach_1.5.2     
    [53] units_0.8-4        glue_1.6.2         codetools_0.2-19   stringi_1.7.12    
    [57] gtable_0.3.4       later_1.3.1        munsell_0.5.0      pillar_1.9.0      
    [61] htmltools_0.5.6.1  R6_2.5.1           wk_0.8.0           textshaping_0.3.7 
    [65] bold_1.3.0         evaluate_0.22      lattice_0.21-9     httpuv_1.6.11     
    [69] class_7.3-22       Rcpp_1.0.11        uuid_1.1-1         svglite_2.1.2     
    [73] nlme_3.1-163       Rttf2pt1_1.3.12    xfun_0.40          zoo_1.8-12        
    [77] pkgconfig_2.0.3   
