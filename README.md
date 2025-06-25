
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

**It is important to note that the `gcrmndb_benthos` is a code
repository, which consist of a hub to store the code used for data
integration, and not a data repository.**

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

| Term | Definition |
|---:|:---|
| Dataset | A collection of related sets of information that is composed of separate elements (data files) but can be manipulated as a unit by a computer. |
| Data aggregator | Data analyst responsible for the data integration process. |
| Data integration | Process of combining, merging, or joining data together, in order to make what were distinct, multiple data objects, into a single, unified data object ([Schildhauer, 2018](https://link.springer.com/chapter/10.1007/978-3-319-59928-1_8)). |
| Data provider | A person or an institution sharing a dataset for which they have been or are involved in the acquisition of the data contained in the dataset. |
| Data standardization | Process of converting the data format of a given dataset to a common data format (*i.e.* variables names and units). Data standardization is the preliminary step of data integration. |
| Synthetic dataset | A dataset resulting from the integration of multiple existing datasets ([Poisot *et al*., 2016](https://onlinelibrary.wiley.com/doi/10.1111/ecog.01941)). |

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
*region*, *subregion*, *ecoregion*, *category*, *subcategory*, and
*condition*) correspond to [DarwinCore
terms](https://dwc.tdwg.org/terms).

| \# | Variable | Cat. | Type | Description |
|---:|:---|:--:|:---|:---|
| 1 | datasetID | :memo: | Factor | ID of the dataset |
| 2 | region | :globe_with_meridians: | Factor | GCRMN region (see [gcrmn_regions](https://github.com/JWicquart/gcrmn_regions)) |
| 3 | subregion | :globe_with_meridians: | Factor | GCRMN subregion (see [gcrmn_regions](https://github.com/JWicquart/gcrmn_regions)) |
| 4 | ecoregion | :globe_with_meridians: | Factor | Marine Ecoregion of the World (see [Spalding et al, 2007](https://doi.org/10.1641/B570707)) |
| 5 | country | :globe_with_meridians: | Factor | Country (obtained from [World EEZ v12](https://www.marineregions.org/downloads.php) (*SOVEREIGN1*)) |
| 6 | territory | :globe_with_meridians: | Character | Territory (obtained from [World EEZ v12](https://www.marineregions.org/downloads.php) (*TERRITORY1*)) |
| 7 | locality | :globe_with_meridians: | Character | Site name |
| 8 | habitat | :globe_with_meridians: | Factor | Habitat |
| 9 | parentEventID | :globe_with_meridians: | Integer | Transect ID |
| 10 | eventID | :globe_with_meridians: | Integer | Quadrat ID |
| 11 | decimalLatitude | :globe_with_meridians: | Numeric | Latitude (*decimal, EPSG:4326*) |
| 12 | decimalLongitude | :globe_with_meridians: | Numeric | Longitude (*decimal, EPSG:4326*) |
| 13 | verbatimDepth | :globe_with_meridians: | Numeric | Depth (*m*) |
| 14 | year | :calendar: | Integer | Four-digit year |
| 15 | month | :calendar: | Integer | Integer month |
| 16 | day | :calendar: | Integer | Integer day |
| 17 | eventDate | :calendar: | Date | Date (*YYYY-MM-DD*, ISO 8601) |
| 18 | samplingProtocol | :straight_ruler: | Character | Description of the method used to acquire the measurement |
| 19 | recordedBy | :straight_ruler: | Character | Name of the person who acquired the measurement |
| 20 | category | :crab: | Factor | Benthic category |
| 21 | subcategory | :crab: | Factor | Benthic subcategory |
| 22 | condition | :crab: | Character |  |
| 23 | phylum | :crab: | Character | Phylum |
| 24 | class | :crab: | Character | Class |
| 25 | order | :crab: | Character | Order |
| 26 | family | :crab: | Character | Family |
| 27 | genus | :crab: | Character | Genus |
| 28 | scientificName | :crab: | Character | Species |
| 29 | measurementValue | :chart_with_upwards_trend: | Numeric | Percentage cover |

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

| \# | Cat. | Variables | Questions |
|:--:|:--:|----|:---|
| 1 | :globe_with_meridians: | `decimalLatitude` `decimalLongitude` | Are the latitude and longitude available? |
| 2 | :globe_with_meridians: | `decimalLatitude` | Is the latitude within its possible boundaries (*i.e.* between -90 and 90)? |
| 3 | :globe_with_meridians: | `decimalLongitude` | Is the longitude within its possible boundaries (*i.e.* between -180 and 180)? |
| 4 | :globe_with_meridians: | `decimalLatitude` `decimalLongitude` | Is the site within the coral reef distribution area (100 km buffer)? |
| 5 | :globe_with_meridians: | `decimalLatitude` `decimalLongitude` | Is the site located within a GCRMN region? |
| 6 | :globe_with_meridians: | `decimalLatitude` `decimalLongitude` | Is the site located within an EEZ (1 km buffer)? |
| 7 | :calendar: | `year` | Is the year available? |
| 8 | :chart_with_upwards_trend: | `measurementValue` | Is the sum of the percentage cover of benthic categories within the sampling unit greater than 0 and lower than 100? |
| 9 | :chart_with_upwards_trend: | `measurementValue` | Is the percentage cover of a given benthic category (*i.e.* a row) greater than 0 and lower than 100? |

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

| datasetID | rightsHolder | accessRights | type | modified | aggregator |
|:--:|:---|:---|:--:|:--:|:--:|
| 0001 | [USVI - Yawzi and Tektite](https://portal.edirepository.org/nis/mapbrowse?scope=edi&identifier=1091&revision=1) | open | Rp. | 2022-02-21 | JW |
| 0002 | [USVI - Random](https://portal.edirepository.org/nis/mapbrowse?scope=edi&identifier=1091&revision=1) | open | Rp. | 2022-02-21 | JW |
| 0003 | [AIMS](https://www.aims.gov.au/) | upon request | Sh. | 2024-12-04 | JW |
| 0004 | [CRIOBE - MPA](https://observatoire.criobe.pf/wiki/tiki-index.php?page=AMP+Moorea&structure=SO+CORAIL) | upon request | Sh. | 2022-09-08 | JW |
| 0005 | [CRIOBE - Polynesia Mana](https://observatoire.criobe.pf/wiki/tiki-index.php?page=Transect+corallien+par+photo-quadrat&structure=SO+CORAIL&latest=1) | upon request | Sh. | 2024-02-06 | JW |
| 0006 | [CRIOBE - Tiahura](https://observatoire.criobe.pf/wiki/tiki-index.php?page=Technique+d%27%C3%A9chantillonnage+Benthos+LTT&structure=SO+CORAIL&latest=1) | upon request | Sh. | 2022-12-31 | JW |
| 0007 | [CRIOBE - ATPP barrier reef](https://observatoire.criobe.pf/wiki/tiki-index.php?page=R%C3%A9cif+Barri%C3%A8re+ATPP&structure=SO+CORAIL&latest=1) | upon request | Sh. |  | JW |
| 0008 | [CRIOBE - ATPP outer slope](https://observatoire.criobe.pf/wiki/tiki-index.php?page=Pente+externe+ATPP&structure=SO+CORAIL&latest=1) | upon request | Sh. |  | JW |
| 0009 | [Seaview Survey](https://www.nature.com/articles/s41597-020-00698-6) | open | Pa. |  | JW |
| 0010 | [2013-2014_Koro Island, Fiji](https://dashboard.datamermaid.org/?project=2013-2014_Koro%20Island,%20Fiji) | open (summary) | Me. | 2021-06-08 | JW |
| 0011 | [NCRMP - American Samoa](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:NCRMP-StRS-Images-AmSam) | open | Rp. | 2021-09-14 | JW |
| 0012 | [NCRMP - CNMI and Guam](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:NCRMP-StRS-Images-Marianas) | open | Rp. | 2018-10-12 | JW |
| 0013 | [NCRMP - Hawaii](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:NCRMP-StRS-Images-HI) | open | Rp. | 2022-11-11 | JW |
| 0014 | [NCRMP - PRIA](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:NCRMP-StRS-Images-PRIA) | open | Rp. | 2021-07-30 | JW |
| 0015 | [Reef Check Foundation](https://www.reefcheck.org/tropical-program/tropical-monitoring-instruction/) | upon request | Db. | 2024-10-16 | JW |
| 0016 | Biosphere Foundation | upon request | Sh. |  | JW |
| 0017 | KNS | upon request | Sh. | 2022-12-27 | JW |
| 0018 | Kiribati | upon request | Sh. | 2020-03-05 | JW |
| 0019 | SLN | upon request | Sh. | 2022-05-12 | JW |
| 0020 | [PACN](https://www.nps.gov/im/pacn/benthic.htm) | upon request | Sh. |  | JW |
| 0021 | RORC NC | upon request | Sh. |  | JW |
| 0022 | [MCRMP](https://micronesiareefmonitoring.com/) | upon request | Sh. |  | JW |
| 0023 | PA-NC | upon request | Sh. |  | JW |
| 0024 | [Laurent WANTIEZ](https://scholar.google.fr/citations?user=4H_FTE0AAAAJ&hl=fr&oi=ao) | upon request | Sh. |  | JW |
| 0025 | [2011_Southern Bua](https://dashboard.datamermaid.org/?project=2011_Southern%20Bua) | open (summary) | Me. | 2021-09-08 | JW |
| 0026 | [2012_Western Bua](https://dashboard.datamermaid.org/?project=2012_Western%20Bua) | open (summary) | Me. | 2021-09-10 | JW |
| 0027 | [2009-2011_Kubulau](https://dashboard.datamermaid.org/?project=2009-2011_Kubulau) | open (summary) | Me. | 2021-09-08 | JW |
| 0028 | [C<sub>2</sub>O Pacific (a)](https://c2o.net.au/our-work-in-the-pacific/) | upon request | Rc. |  | JW |
| 0029 | Kimbe Bay | upon request | Sh. | 2019-09-11 | JW |
| 0030 | [PNG BAF 2019](https://dashboard.datamermaid.org/?project=PNG%20BAF%202019) | open (summary) | Me. | 2019-10-31 | JW |
| 0031 | [2017_Northern Lau](https://dashboard.datamermaid.org/?project=2017_Northern%20Lau) | open (summary) | Me. | 2021-02-08 | JW |
| 0032 | [2013-2014_Vatu-i-Ra](https://dashboard.datamermaid.org/?project=2013-2014_Vatu-i-Ra) | open (summary) | Me. | 2021-02-08 | JW |
| 0033 | [2019_Dama Bureta](https://dashboard.datamermaid.org/?project=2019_Dama%20Bureta%20Waibula%20and%20Dawasamu-WISH%20ecological%20survey) | open (summary) | Me. | 2020-08-12 | JW |
| 0034 | [2020_NamenaAndVatuira](https://dashboard.datamermaid.org/?project=2020_NamenaAndVatuira%20coral%20reef%20surveys) | open (summary) | Me. | 2020-10-12 | JW |
| 0035 | [Lau Seascape Surveys](https://dashboard.datamermaid.org/?project=Lau%20Seascape%20Surveys%20March%202022) | open (summary) | Me. | 2022-04-18 | JW |
| 0036 | SI_Munda | open (summary) | Rc. |  | JW |
| 0037 | [Khen et al, 2022](https://link.springer.com/article/10.1007/s00338-022-02271-6) | upon request | Sh. |  | JW |
| 0038 | [Reef Life Survey](https://doi.org/10.1016/j.biocon.2020.108855) | upon request | Sh. | 2023-09-13 | JW |
| 0039 | [MMR](https://www.mmr.gov.ck/) | upon request | Sh. | 2023-09-12 | JW |
| 0040 | [Smallhorn-West et al, 2019](https://doi.pangaea.de/10.1594/PANGAEA.904800) | open | Rp. | 2019-08-15 | JW |
| 0041 | Hydro-Paalo | upon request | Sh. | 2022-12-16 | JW |
| 0042 | [Living Ocean Foundation](https://www.livingoceansfoundation.org/) | upon request | Sh. |  | JW |
| 0043 | [100 Island Challenge](https://sandinlab.ucsd.edu/100-island-challenge/) | upon request | Sh. | 2023-11-06 | JW |
| 0044 | [PICRC](https://picrc.org/work/coral/) | upon request | Sh. |  | JW |
| 0045 | [SRMR and Combe Reef](https://dashboard.datamermaid.org/?project=SRMR%20and%20Combe%20reef%20comparison) | open (summary) | Me. | 2024-01-09 | JW |
| 0046 | [2023-24 Fiji GCRMN sites](https://dashboard.datamermaid.org/?project=2023-24%20Fiji%20GCRMN%20sites) | open (summary) | Me. | 2024-01-09 | JW |
| 0047 | Kayal and Dromard | upon request | Sh. |  | JW |
| 0048 | Kayal, Penin, and Adjeroud (NC) | upon request | Sh. |  | JW |
| 0049 | Kayal, Penin, and Adjeroud (Mo.) | upon request | Sh. |  | JW |
| 0050 | FEO | upon request | Sh. | 2020-02-12 | JW |
| 0051 | Phoenix Islands | upon request | Sh. |  | JW |
| 0052 | [Vava’u Ocean Initiative 2017](https://vavauenvironment.org/portfolio/vavau-ocean-initiative/) | upon request | Sh. |  | JW |
| 0053 | [Vava’u Ocean Initiative 2022](https://vavauenvironment.org/portfolio/vavau-ocean-initiative/) | upon request | Sh. |  | JW |
| 0054 | [100 Island Challenge (SLI)](https://sandinlab.ucsd.edu/100-island-challenge/) | upon request | Sh. |  | JW |
| 0055 | [Samoa Ocean Strategy](https://www.samoaocean.org/) | upon request | Sh. |  | JW |
| 0056 | [SBN_UAE_2023](https://dashboard.datamermaid.org/?project=SBN_UAE_2023) | open (summary) | Me. |  | JW |
| 0057 | Montefalcone et al. | upon request | Sh. | 2025-03-19 | JW |
| 0058 | [Kuwait_2014](https://dashboard.datamermaid.org/?project=Kuwait_2014) | open (summary) | Me. |  | JW |
| 0059 | [Bahrain_2011](https://dashboard.datamermaid.org/?project=Bahrain_2011) | open (summary) | Me. |  | JW |
| 0060 | [Ankay Conservation](https://ankayconservation.com) | upon request | Sh. | 2024-07-08 | JW |
| 0061 | [C<sub>2</sub>O Pacific (b)](https://c2o.net.au/our-work-in-the-pacific/) | upon request | Sh. | 2024-07-09 | JW |
| 0062 | [Reef Renewal Bonaire](https://www.reefrenewalbonaire.org/) | upon request | Sh. | 2024-07-16 | JW |
| 0063 | [Qatar_2015-2017](https://dashboard.datamermaid.org/?project=Qatar_2015-2017) | open (summary) | Me. | 2024-07-24 | JW |
| 0064 | [UAE_Musandam](https://dashboard.datamermaid.org/?project=UAE_Musandam_Multiproject_2019-2020) | open (summary) | Me. | 2024-07-24 | JW |
| 0065 | [SBNvsKF_UAE_2021-2022](https://dashboard.datamermaid.org/?project=SBNvsKF_UAE_2021-2022) | open (summary) | Me. | 2024-07-25 | JW |
| 0066 | [Nature Foundation SXM](https://naturefoundationsxm.org/) | upon request | Sh. | 2024-07-25 | JW |
| 0067 | [ODE Martinique](https://www.eaumartinique.fr/oe-accueil) | upon request | Sh. | 2024-07-31 | JW |
| 0068 | [AlHiel_UAE_2023](https://dashboard.datamermaid.org/?project=AlHiel_UAE_2023) | open (summary) | Me. | 2024-07-25 | JW |
| 0069 | [UAE_Musandam_2022](https://dashboard.datamermaid.org/?project=UAE_Musandam_2022) | open (summary) | Me. | 2024-08-02 | JW |
| 0070 | Claereboudt, 2015 | upon request | Sh. | 2024-08-25 | JW |
| 0071 | Aeby et al, 2022 | upon request | Sh. | 2024-08-25 | JW |
| 0072 | Al Mealla, 2022 | upon request | Sh. | 2024-08-26 | JW |
| 0073 | [Howells et al, 2020](https://doi.org/10.1007/s00338-020-01946-2) | upon request | Sh. | 2024-08-26 | JW |
| 0074 | Shokri, 2021 | upon request | Sh. | 2024-08-26 | JW |
| 0075 | [Aeby et al, 2020](https://doi.org/10.1007/s00338-020-01928-4) | upon request | Sh. | 2024-08-25 | JW |
| 0076 | [KFUPM - Saudi Aramco](https://kfupm.edu.sa/) | upon request | Sh. | 2024-09-11 | JW |
| 0077 | [Sulubaaï (Shark Fin Bay project)](https://dashboard.datamermaid.org/?project=Shark%20Fin%20Bay%20Project) | open (summary) | Me. | 2024-09-13 | JW |
| 0078 | [Puntacana Foundation](https://puntacana.org/) | upon request | Sh. | 2024-09-17 | JW |
| 0079 | [TCRMP](https://www.vitcrmp.org/) | upon request | Sh. | 2024-09-19 | JW |
| 0080 | [FUNDEMAR](https://www.fundemardr.org/) | upon request | Sh. | 2024-09-23 | JW |
| 0081 | UWI DBML | upon request | Sh. | 2024-09-24 | JW |
| 0082 | Saba | upon request | Sh. | 2024-09-30 | JW |
| 0083 | [RNSM](https://reservenaturelle-saint-martin.com/) | upon request | Sh. | 2024-10-06 | JW |
| 0084 | [Curacao](https://www.researchstationcarmabi.org/) | upon request | Sh. | 2024-10-10 | JW |
| 0085 | [BREAM](https://www.bermudabream.com/) | upon request | Sh. | 2024-10-10 | JW |
| 0086 | [Fundacion Cap Cana](https://www.fundacioncapcana.org/) | upon request | Sh. | 2024-10-10 | JW |
| 0087 | Titè - ONF | upon request | Sh. | 2024-10-10 | JW |
| 0088 | Grand Cayman | upon request | Sh. | 2024-10-11 | JW |
| 0089 | [Coral Cay Conservation](https://www.coralcay.org/) | upon request | Sh. | 2024-10-14 | JW |
| 0090 | [Montilla et al, 2021](https://doi.org/10.1016/j.dib.2021.107235) | open | Pa. | 2024-10-15 | JW |
| 0091 | [AGRRA](https://www.agrra.org/) | upon request | Db. | 2024-10-17 | JW |
| 0092 | CZMU | upon request | Sh. | 2024-10-18 | JW |
| 0093 | [Puerto Rico CRMP](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:0204647) | open | Rp. | 2024-10-18 | JW |
| 0094 | CECIMAR | upon request | Sh. | 2024-10-21 | JW |
| 0095 | CIMAR - UCR | upon request | Sh. | 2024-10-22 | JW |
| 0096 | Bouchon and Bouchon | upon request | Sh. | 2024-10-28 | JW |
| 0097 | [SECREMP](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:0280596) | open | Rp. | 2024-10-28 | JW |
| 0098 | Steneck | upon request | Sh. | 2024-10-28 | JW |
| 0099 | Meesters et al. | upon request | Sh. | 2024-10-30 | JW |
| 0100 | [Abu Dhabi 2017-2019](https://dashboard.datamermaid.org/?project=Abu%20Dhabi%202017-2019) | open (summary) | Me. | 2024-10-31 | JW |
| 0101 | [NCRMP - FGB](https://doi.org/10.7289/v5vd6wts) | open | Rp. | 2024-11-04 | JW |
| 0102 | [NCRMP - Puerto Rico](https://doi.org/10.7289/v5pg1q23) | open | Rp. | 2024-11-04 | JW |
| 0103 | [NCRMP - USVI](https://doi.org/10.7289/v5ww7fqk) | open | Rp. | 2024-11-04 | JW |
| 0104 | [NCRMP - Florida](https://doi.org/10.7289/v5xw4h4z) | open | Rp. | 2024-11-04 | JW |
| 0105 | [UAE_Oman_2008-2012](https://dashboard.datamermaid.org/?project=UAE_Oman_2008-2012) | open (summary) | Me. | 2024-11-04 | JW |
| 0106 | [DTCREMP](https://geodata.myfwc.com/documents/797abdd95d4146e1b7546d7df6a1ecf5/about) | open | Rp. | 2024-11-05 | JW |
| 0107 | [CREMP](https://geodata.myfwc.com/documents/2ab2e706c83d4247855f8e4e689c7cba/about) | open | Rp. | 2024-11-05 | JW |
| 0108 | WLC | upon request | Sh. | 2024-11-06 | JW |
| 0109 | Kemenes-Varadero | upon request | Sh. | 2024-11-07 | JW |
| 0110 | [INVEMAR](https://www.invemar.org.co/) | upon request | Sh. | 2024-11-09 | JW |
| 0111 | [NEPA](https://www.nepa.gov.jm/) | upon request | Sh. | 2024-11-12 | JW |
| 0112 | [DBCA](https://www.dbca.wa.gov.au/) | upon request | Sh. | 2024-11-25 | JW |
| 0113 | [Barcolab](https://www.barcolab.org/) | upon request | Sh. | 2024-11-25 | JW |
| 0114 | [STENAPA](https://statiapark.org/) | upon request | Sh. | 2024-11-28 | JW |
| 0115 | [CCMI](https://reefresearch.org/) | upon request | Sh. | 2024-11-29 | JW |
| 0116 | [SFS](https://fieldstudies.org/center/tci/) | upon request | Sh. | 2024-12-02 | JW |
| 0117 | González Díaz et al. | upon request | Sh. | 2024-12-02 | JW |
| 0118 | [Tebbett et al, 2022](https://doi.org/10.1016/j.marenvres.2021.105537) | upon request | Sh. | 2024-12-05 | JW |
| 0119 | [UAE_2019_Mateos](https://dashboard.datamermaid.org/?project=UAE_2019_Mateos) | upon request | Me. | 2024-12-05 | JW |
| 0120 | [Oman_2017_2020](https://dashboard.datamermaid.org/?project=Oman_2017_2020) | upon request | Me. | 2024-12-05 | JW |
| 0121 | [CORDIO (Kenya)](https://cordioea.net/) | upon request | Sh. | 2024-12-06 | JW |
| 0122 | [A Rocha Kenya](https://www.arocha.or.ke/) | upon request | Sh. | 2024-12-06 | JW |
| 0123 | [REEFolution](https://reefolution.org/) | upon request | Sh. | 2024-12-06 | JW |
| 0124 | [KMFRI](https://kmfri.go.ke/) | upon request | Sh. | 2024-12-06 | JW |
| 0125 | [WRTI](https://wrti.go.ke/) | upon request | Sh. | 2024-12-06 | JW |
| 0126 | [Dahari](https://daharicomores.org/) | upon request | Sh. | 2024-12-06 | JW |
| 0127 | Moheli MPA | upon request | Sh. | 2024-12-06 | JW |
| 0128 | [AIDE](https://www.aide-comores.org/) | upon request | Sh. | 2024-12-06 | JW |
| 0129 | [CORDIO (Comoros)](https://cordioea.net/) | upon request | Sh. | 2024-12-06 | JW |
| 0130 | Alemu I | upon request | Sh. | 2024-12-09 | JW |
| 0131 | [Maldives Resilient Reefs](https://www.maldivesresilientreefs.com/) | upon request | Sh. | 2024-12-09 | JW |
| 0132 | [Maldives Resilient Reefs (RC)](https://www.maldivesresilientreefs.com/) | upon request | Rc. | 2024-12-10 | JW |
| 0133 | [Wilkinson et al, 2013](https://doi.org/10.1016/j.marpolbul.2013.02.040) | upon request | Sh. | 2024-12-12 | JW |
| 0134 | Kimberley Marine Parks | upon request | Sh. | 2024-12-13 | JW |
| 0135 | Garza et al, 2022 | upon request | Sh. | 2024-12-14 | JW |
| 0136 | Coral Sea Marine Park | upon request | Sh. | 2024-12-17 | JW |
| 0137 | [Qatar_2014](https://dashboard.datamermaid.org/?project=Qatar_2014) | upon request | Me. | 2024-12-18 | JW |
| 0138 | Hawkins and Roberts, 1995 | upon request | Sh. | 2024-12-18 | JW |
| 0139 | Raghunathan and Mondal | upon request | Sh. | 2025-01-02 | JW |
| 0140 | Fairoz | upon request | Sh. | 2025-01-02 | JW |
| 0141 | SDMRI | upon request | Sh. | 2025-03-21 | JW |
| 0142 | [Benkwitt et al. (a)](https://www.science.org/doi/10.1126/sciadv.adj0390) | upon request | Sh. | 2025-01-12 | JW |
| 0143 | Benkwitt et al. (b) | upon request | Sh. | 2025-01-12 | JW |
| 0144 | [UAE_2006-2014](https://dashboard.datamermaid.org/?project=UAE_2006-2014) | upon request | Me. | 2025-01-16 | JW |
| 0145 | Steneck and Torres | upon request | Sh. | 2025-01-20 | JW |
| 0146 | STINAPA Bonaire | upon request | Sh. | 2025-01-21 | JW |
| 0147 | USF | upon request | Sh. | 2025-01-22 | JW |
| 0148 | Maréchal et al. | upon request | Sh. | 2025-01-22 | JW |
| 0149 | [Mallela 2007](https://doi.org/10.18475/cjos.v46i1.a10) | upon request | Sh. | 2025-01-24 | JW |
| 0150 | Mallela CI-CKI | upon request | Sh. | 2025-01-29 | JW |
| 0151 | [pre-NCRMP](https://doi.org/10.25921/rt0s-ty25) | open | Rp. | 2025-01-30 | JW |
| 0152 | Forrester | upon request | Sh. | 2025-02-03 | JW |
| 0153 | Iberostar | upon request | Sh. | 2025-02-12 | JW |
| 0154 | McField, 1997 | upon request | Sh. | 2025-02-03 | JW |
| 0155 | McField, 1999 | upon request | Sh. | 2025-02-03 | JW |
| 0156 | [Al-Abdulkader et al, 2019](https://www.researchgate.net/publication/334811093_Chapter_310_Coral_Reef_Ecosystem_-The_Hermatypic_Scleractinian_Hard_Corals) | open | Ar. | 2025-02-10 | JW |
| 0157 | [Vogt, 1994](https://www.researchgate.net/profile/Friedhelm-Krupp/publication/308336361_The_Status_of_Coastal_and_Marine_Habitats_two_Years_after_the_Gulf_War_Oil_Spill/links/57e134a208aefd725a7d510d/The-Status-of-Coastal-and-Marine-Habitats-two-Years-after-the-Gulf-War-Oil-Spill.pdf#page=64) | open | Ar. | 2025-02-10 | JW |
| 0158 | [Bloomberg Coral Bleaching](https://dashboard.datamermaid.org/?project=Bloomberg%20Coral%20Bleaching) | upon request | Me. | 2025-02-10 | JW |
| 0159 | [Bahari ni Urithi](https://dashboard.datamermaid.org/?project=Bahari%20ni%20Urithi) | upon request | Me. | 2025-02-10 | JW |
| 0160 | [BAF](https://dashboard.datamermaid.org/?project=BAF) | upon request | Me. | 2025-02-10 | JW |
| 0161 | [Vibrant Ocean Initiative 2022](https://dashboard.datamermaid.org/?project=Vibrant%20Ocean%20Initiative%202022) | upon request | Me. | 2025-02-10 | JW |
| 0162 | [GFCR Survey 2022](https://dashboard.datamermaid.org/?project=GFCR%20Survey%202022) | upon request | Me. | 2025-02-10 | JW |
| 0163 | FGB LTMP - Random Transect | upon request | Sh. | 2025-02-13 | JW |
| 0164 | FGB LTMP - Repetitive Quadrat | upon request | Sh. | 2025-02-13 | JW |
| 0165 | McLeod et al. | upon request | Sh. | 2025-02-20 | JW |
| 0166 | [FUNDEMAR (2011-2016)](https://www.fundemardr.org/) | upon request | Sh. | 2025-02-20 | JW |
| 0167 | [Leduc](https://dashboard.datamermaid.org/?project=Oman_2022_Leduc) | upon request | Sh. | 2025-02-24 | JW |
| 0168 | ETP regional dataset | upon request | Sh. | 2025-02-25 | JW |
| 0169 | Moity | upon request | Sh. | 2025-02-25 | JW |
| 0170 | [Sannassy Pilly et al, 2024](https://doi.org/10.1098/rsos.231246) | upon request | Sh. | 2025-02-28 | JW |
| 0171 | [Benzoni et al, 2006](https://www.researchgate.net/publication/292031854_The_coral_reefs_of_the_Northern_Arabian_Gulf_Stability_over_time_in_extreme_environmental_conditions) | open | Ar. | 2025-03-03 | JW |
| 0172 | [Vousden, 1995](https://research.bangor.ac.uk/portal/en/theses/bahrain-marine-habitats-and-some-environmental-effects-on-seagrass-beds--a-study-of-the-marine-habitats-of-bahrain-with-particular-reference-to-the-effects-of-water-temperature-depth-and-salinity-on-seagrass-biomass-and-distribution(106e2056-14e0-4b61-9251-aa54eeb8b585).html) | open | Ar. | 2025-03-03 | JW |
| 0173 | Attalla, 2024 | upon request | Sh. | 2025-03-17 | JW |
| 0174 | One Ocean LLC | upon request | Sh. | 2025-03-17 | JW |
| 0175 | [GBRMPA](https://www2.gbrmpa.gov.au/) | upon request | Sh. | 2025-03-18 | JW |
| 0176 | [Operation Wallacea](https://www.opwall.com/) | upon request | Sh. | 2025-03-18 | JW |
| 0177 | Al-Tawaha | upon request | Sh. | 2025-03-20 | JW |
| 0178 | [Antonius and Weiner, 1982](https://doi.org/10.1111/j.1439-0485.1982.tb00113.x) | open | Ar. | 2025-03-21 | JW |
| 0179 | [Bright et al, 1984](https://www.ingentaconnect.com/content/umrsmas/bullmar/1984/00000034/00000003/art00012) | open | Ar. | 2025-03-21 | JW |
| 0180 | [Dodge et al, 1982](https://www.ingentaconnect.com/content/umrsmas/bullmar/1982/00000032/00000003/art00009) | open | Ar. | 2025-03-21 | JW |
| 0181 | [Edmunds and Bruno, 1996](https://www.int-res.com/abstracts/meps/v143/p165-171) | open | Ar. | 2025-03-21 | JW |
| 0182 | [AIMS Western Australia](https://www.aims.gov.au/) | upon request | Sh. | 2025-03-26 | JW |
| 0183 | [SHAMS](https://shams.gov.sa/) | upon request | Sh. | 2025-03-27 | JW |
| 0184 | Saad et al. | upon request | Sh. | 2025-03-27 | JW |
| 0185 | Sh Aba et al. | upon request | Sh. | 2025-03-28 | JW |
| 0186 | [ORI](https://saambr.org.za/oceanographic-research-institute-ori/) | upon request | Sh. | 2025-03-28 | JW |
| 0187 | [Innoceana](https://innoceana.org/) | upon request | Sh. | 2025-03-31 | JW |
| 0188 | IMS | upon request | Sh. | 2025-03-28 | JW |
| 0189 | CORDIO (Tanzania) | upon request | Sh. | 2025-03-28 | JW |
| 0190 | CHICOP | upon request | Sh. | 2025-03-28 | JW |
| 0191 | SUZA | upon request | Sh. | 2025-03-28 | JW |
| 0192 | Elma | upon request | Sh. | 2025-03-28 | JW |
| 0193 | Under the Wave | upon request | Sh. | 2025-03-28 | JW |
| 0194 | Rajan et al. | upon request | Sh. | 2025-03-28 | JW |
| 0195 | CNRO | upon request | Sh. | 2025-03-31 | JW |
| 0196 | Blue Ventures | upon request | Sh. | 2025-03-31 | JW |
| 0197 | PRÎSM | upon request | Sh. | 2025-03-31 | JW |
| 0198 | YSO | upon request | Sh. | 2025-03-31 | JW |
| 0199 | IHSM | upon request | Sh. | 2025-03-31 | JW |
| 0200 | WWF Madagascar | upon request | Sh. | 2025-03-31 | JW |
| 0201 | CORDIO (Madagascar) | upon request | Sh. | 2025-03-31 | JW |
| 0202 | KORAI | upon request | Sh. | 2025-03-31 | JW |
| 0203 | MMRI | upon request | Sh. | 2025-03-31 | JW |
| 0204 | [Memba-Mossuril Baseline](https://dashboard.datamermaid.org/?project=Memba-Mossuril%20Baseline) | upon request | Me. | 2025-04-01 | JW |
| 0205 | PSESPA Monitoring2WWF | upon request | Me. | 2025-04-01 | JW |
| 0206 | [Inhambane LMMAs](https://dashboard.datamermaid.org/?project=Inhambane%20LMMAs%20Monitoring%20Program) | upon request | Me. | 2025-04-01 | JW |
| 0207 | [Vamizi Island Monitoring](https://dashboard.datamermaid.org/?project=Vamizi%20Island%20Monitoring) | upon request | Me. | 2025-04-01 | JW |
| 0208 | RCBrasil | upon request | Sh. | 2025-04-01 | JW |
| 0209 | Cordeiro et al. | upon request | Sh. | 2025-04-01 | JW |
| 0210 | Nair et al. (1998-2023) | upon request | Sh. | 2025-04-01 | JW |
| 0211 | Nair et al. (2007-2020) | upon request | Sh. | 2025-04-01 | JW |
| 0212 | Nair et al. (2024) | upon request | Sh. | 2025-04-01 | JW |
| 0213 | PSESPA 2019 | upon request | Sh. | 2025-04-01 | JW |
| 0214 | CTV | upon request | Sh. | 2025-04-01 | JW |
| 0215 | [BECA](https://dashboard.datamermaid.org/?project=Blue%20Economy%20for%20Conservation%20Areas) | upon request | Me. | 2025-04-02 | JW |
| 0216 | Ali et al. 2017 and 2018 | upon request | Sh. | 2025-04-03 | JW |
| 0217 | Elamin et al. 2018 (a) | upon request | Sh. | 2025-04-03 | JW |
| 0218 | Elamin et al. 2018 (b) | upon request | Sh. | 2025-04-03 | JW |
| 0219 | Abaker 2021 | upon request | Sh. | 2025-04-03 | JW |
| 0220 | Voolstra et al. | upon request | Sh. | 2025-04-04 | JW |
| 0221 | Ghazilou, 2024 | upon request | Sh. | 2025-04-06 | JW |
| 0222 | Leduc, 2024 | upon request | Sh. | 2025-04-06 | JW |
| 0223 | Qatar, 2022 | upon request | Sh. | 2025-04-06 | JW |
| 0224 | Al Harthi, 2024 | upon request | Sh. | 2025-04-06 | JW |
| 0225 | Al Mealla, 2024 | upon request | Sh. | 2025-04-06 | JW |
| 0226 | [Kuwait_1987](https://dashboard.datamermaid.org/?project=Kuwait_1987) | upon request | Me. | 2025-04-06 | JW |
| 0227 | UAE_2023-2024 | upon request | Sh. | 2025-04-06 | JW |
| 0228 | Likhulu | upon request | Sh. | 2025-04-08 | JW |
| 0229 | [CSIRO](https://shiny.csiro.au/UVSeeR/) | upon request | Sh. | 2025-06-23 | JW |
| 0230 | [UTOPIAN](https://www.seanoe.org/data/00935/104728/) | open | Rp. | 2025-06-23 | JW |
| 0231 | GCRMN Réunion | upon request | Sh. | 2025-06-23 | JW |
| 0232 | Mayfield, 2024 | upon request | Sh. | 2025-06-25 | JW |

## 6. Description of the synthetic dataset

On the 2025-06-25, the `gcrmndb_benthos` synthetic dataset contains a
total of **19,042,708 observations** (*i.e* rows) representing **34,871
sites** and **71,205 surveys**. The distribution of monitoring sites in
time and space is shown in **Figure 2**. An interactive version of this
map is available on [Google Earth
Engine](https://jeremywicquart.users.earthengine.app/view/gcrmndbbenthos).

![](figs/map_sites.png)

**Figure 2.** Map of the distribution of benthic cover monitoring sites
for which data are included within the `gcrmndb_benthos` synthetic
dataset. Light grey polygons represents economic exclusive zones.
Colours corresponds to monitoring duration which is the difference, for
each site, between the first and last years with data. Note that the
datasetID 0009 is not included in this map, due to the very large number
of sites and a monitoring method that differs from those of the other
datasets.

**Table 6.** Summary of the content of the `gcrmndb_benthos` synthetic
dataset per GCRMN region. EAS = East Asian Seas, ETP = Eastern Tropical
Pacific, WIO = Western Indian Ocean. The total number of datasets
integrated within the `gcrmndb_benthos` can differ from the sum of the
column `Datasets (n)`, as some datasets includes sites in different
GCRMN regions. Note that the datasetID 0009 is not included in this
table, due to the very large number of sites and a monitoring method
that differs from those of the other datasets.

|         GCRMN region | Sites (n) | Surveys (n) | Datasets (n) | First year | Last year |
|---------------------:|----------:|------------:|-------------:|:----------:|:---------:|
|            Australia |     1,917 |      10,742 |           11 |    1980    |   2025    |
|               Brazil |       182 |         590 |            4 |    2002    |   2025    |
|            Caribbean |    14,271 |      23,898 |           69 |    1973    |   2024    |
|                  EAS |     3,046 |       6,816 |            8 |    1997    |   2024    |
|                  ETP |       775 |       2,688 |            5 |    1994    |   2025    |
|               PERSGA |       501 |         902 |           14 |    1997    |   2024    |
|              Pacific |     8,415 |      15,731 |           52 |    1987    |   2025    |
|                ROPME |       379 |         863 |           34 |    1985    |   2024    |
|           South Asia |       636 |       2,825 |           15 |    1997    |   2024    |
|                  WIO |     4,749 |       6,150 |           44 |    1987    |   2025    |
| Global (all regions) |    34,871 |      71,205 |          231 |    1973    |   2025    |

**Table 7.** Summary of the content of the `gcrmndb_benthos` synthetic
dataset per country and territory. The total number of datasets
integrated within the `gcrmndb_benthos` can differ from the sum of the
column `Datasets (n)`, as some datasets includes sites in different
territories. Note that the datasetID 0009 is not included in this table,
due to the very large number of sites and a monitoring method that
differs from those of the other datasets.

| Country | Territory | Sites (n) | Surveys (n) | Datasets (n) | First year | Last year |
|---:|:---|---:|---:|---:|:--:|:--:|
| Antigua and Barbuda | Antigua and Barbuda | 30 | 36 | 2 | 2003 | 2022 |
| Australia | Australia | 1,880 | 10,595 | 10 | 1980 | 2025 |
| Australia | Christmas Island | 25 | 84 | 3 | 2003 | 2023 |
| Australia | Cocos Islands | 27 | 85 | 2 | 1997 | 2023 |
| Bahamas | Bahamas | 466 | 682 | 3 | 1986 | 2024 |
| Bahrain | Bahrain | 45 | 55 | 5 | 1985 | 2024 |
| Bangladesh | Bangladesh | 2 | 2 | 1 | 2005 | 2006 |
| Barbados | Barbados | 80 | 349 | 3 | 1982 | 2022 |
| Belize | Belize | 340 | 536 | 6 | 1985 | 2024 |
| Brazil | Brazil | 178 | 580 | 4 | 2002 | 2025 |
| Brazil | Trindade | 4 | 10 | 1 | 2022 | 2024 |
| Brunei | Brunei | 38 | 45 | 1 | 1997 | 2016 |
| Cambodia | Cambodia | 98 | 105 | 2 | 1998 | 2013 |
| China | China | 100 | 366 | 1 | 1997 | 2012 |
| Colombia | Colombia | 221 | 711 | 6 | 1997 | 2024 |
| Comores | Comores | 35 | 94 | 4 | 1999 | 2022 |
| Costa Rica | Costa Rica | 231 | 475 | 5 | 2004 | 2025 |
| Cuba | Cuba | 37 | 46 | 2 | 2001 | 2023 |
| Djibouti | Djibouti | 23 | 23 | 1 | 2005 | 2008 |
| Dominica | Dominica | 19 | 33 | 1 | 2004 | 2018 |
| Dominican Republic | Dominican Republic | 140 | 478 | 8 | 2004 | 2024 |
| East Timor | East Timor | 11 | 13 | 2 | 2004 | 2017 |
| Ecuador | Galapagos | 256 | 1,523 | 3 | 1994 | 2024 |
| Egypt | Egypt | 216 | 527 | 4 | 1997 | 2024 |
| Eritrea | Eritrea | 2 | 2 | 1 | 2000 | 2000 |
| Federal Republic of Somalia | Federal Republic of Somalia | 5 | 5 | 2 | 2005 | 2024 |
| Fiji | Fiji | 654 | 1,003 | 12 | 1997 | 2025 |
| France | Collectivity of Saint Martin | 12 | 83 | 2 | 2007 | 2022 |
| France | Europa Island | 1 | 1 | 1 | 2002 | 2002 |
| France | French Polynesia | 229 | 2,191 | 8 | 1987 | 2024 |
| France | Guadeloupe | 27 | 209 | 4 | 2002 | 2024 |
| France | Martinique | 42 | 323 | 3 | 2001 | 2024 |
| France | Mayotte | 20 | 87 | 1 | 2003 | 2017 |
| France | New Caledonia | 873 | 3,616 | 9 | 1997 | 2023 |
| France | Réunion | 4,025 | 4,461 | 3 | 1998 | 2025 |
| France | Saint-Barthélemy | 4 | 43 | 2 | 2002 | 2024 |
| France | Wallis and Futuna | 12 | 12 | 1 | 2019 | 2019 |
| Grenada | Grenada | 86 | 225 | 3 | 2004 | 2024 |
| Guatemala | Guatemala | 21 | 45 | 2 | 2006 | 2023 |
| Haiti | Haiti | 96 | 109 | 2 | 2003 | 2018 |
| Haiti | Navassa Island | 15 | 15 | 1 | 2012 | 2012 |
| Honduras | Honduras | 400 | 787 | 3 | 1997 | 2024 |
| India | Andaman and Nicobar | 29 | 29 | 1 | 2021 | 2022 |
| India | India | 117 | 1,745 | 6 | 1998 | 2024 |
| Indonesia | Indonesia | 683 | 1,228 | 4 | 1997 | 2024 |
| Iran | Iran | 46 | 71 | 3 | 1999 | 2024 |
| Israel | Israel | 4 | 4 | 1 | 1997 | 2001 |
| Jamaica | Jamaica | 230 | 716 | 7 | 1986 | 2024 |
| Japan | Japan | 52 | 110 | 2 | 1997 | 2015 |
| Jordan | Jordan | 12 | 34 | 2 | 2008 | 2024 |
| Kenya | Kenya | 158 | 568 | 8 | 1987 | 2024 |
| Kiribati | Gilbert Islands | 18 | 18 | 2 | 2011 | 2018 |
| Kiribati | Line Group | 97 | 125 | 3 | 2009 | 2023 |
| Kiribati | Phoenix Group | 58 | 123 | 1 | 2009 | 2018 |
| Kuwait | Kuwait | 18 | 27 | 4 | 1987 | 2014 |
| Madagascar | Madagascar | 121 | 294 | 10 | 1998 | 2024 |
| Malaysia | Malaysia | 736 | 2,956 | 2 | 1997 | 2023 |
| Maldives | Maldives | 444 | 822 | 6 | 1997 | 2024 |
| Marshall Islands | Marshall Islands | 147 | 174 | 3 | 2002 | 2020 |
| Mexico | Mexico | 392 | 955 | 8 | 1997 | 2024 |
| Micronesia | Federated States of Micronesia | 217 | 555 | 3 | 2000 | 2020 |
| Mozambique | Mozambique | 153 | 204 | 9 | 1997 | 2024 |
| Myanmar | Myanmar | 22 | 29 | 1 | 2001 | 2013 |
| Netherlands | Aruba | 6 | 7 | 1 | 2003 | 2009 |
| Netherlands | Bonaire | 159 | 623 | 6 | 1973 | 2023 |
| Netherlands | Curaçao | 146 | 431 | 3 | 1973 | 2023 |
| Netherlands | Saba | 18 | 56 | 2 | 1994 | 2024 |
| Netherlands | Sint-Eustatius | 27 | 62 | 2 | 2005 | 2023 |
| Netherlands | Sint-Maarten | 12 | 59 | 2 | 2005 | 2024 |
| New Zealand | Cook Islands | 191 | 246 | 5 | 2005 | 2023 |
| New Zealand | Niue | 7 | 7 | 1 | 2011 | 2011 |
| Nicaragua | Nicaragua | 44 | 63 | 2 | 2009 | 2015 |
| Oman | Oman | 131 | 277 | 12 | 2003 | 2024 |
| Palau | Palau | 112 | 381 | 3 | 1997 | 2022 |
| Panama | Panama | 239 | 410 | 4 | 1997 | 2024 |
| Papua New Guinea | Papua New Guinea | 91 | 267 | 4 | 1998 | 2019 |
| Philippines | Philippines | 842 | 1,136 | 3 | 1997 | 2023 |
| Qatar | Qatar | 26 | 26 | 4 | 2014 | 2024 |
| Republic of Mauritius | Chagos Archipelago | 63 | 224 | 3 | 2010 | 2023 |
| Republic of Mauritius | Republic of Mauritius | 10 | 12 | 1 | 1999 | 2003 |
| Saint Kitts and Nevis | Saint Kitts and Nevis | 38 | 55 | 2 | 2004 | 2024 |
| Saint Lucia | Saint Lucia | 21 | 61 | 1 | 1999 | 2014 |
| Saint Vincent and the Grenadines | Saint Vincent and the Grenadines | 42 | 60 | 3 | 2004 | 2024 |
| Samoa | Samoa | 50 | 90 | 4 | 2012 | 2022 |
| Saudi Arabia | Saudi Arabia | 179 | 346 | 7 | 1985 | 2024 |
| Seychelles | Seychelles | 19 | 19 | 2 | 1997 | 2012 |
| Solomon Islands | Solomon Islands | 147 | 245 | 5 | 2005 | 2021 |
| South Africa | South Africa | 6 | 37 | 2 | 1993 | 2023 |
| Sri Lanka | Sri Lanka | 10 | 32 | 2 | 2003 | 2024 |
| Sudan | Sudan | 86 | 123 | 6 | 2004 | 2022 |
| Taiwan | Taiwan | 103 | 195 | 1 | 1997 | 2020 |
| Tanzania | Tanzania | 197 | 369 | 14 | 1992 | 2025 |
| Thailand | Thailand | 150 | 248 | 1 | 1998 | 2024 |
| Tonga | Tonga | 529 | 575 | 7 | 2002 | 2022 |
| Trinidad and Tobago | Trinidad and Tobago | 52 | 115 | 3 | 2007 | 2023 |
| United Arab Emirates | Abu musa, Greater and Lesser Tunb | 7 | 7 | 1 | 2016 | 2017 |
| United Arab Emirates | United Arab Emirates | 78 | 230 | 13 | 2004 | 2024 |
| United Kingdom | Anguilla | 1 | 1 | 1 | 2002 | 2002 |
| United Kingdom | Bermuda | 43 | 91 | 2 | 1982 | 2021 |
| United Kingdom | British Virgin Islands | 28 | 322 | 2 | 1992 | 2024 |
| United Kingdom | Cayman Islands | 28 | 185 | 4 | 1997 | 2024 |
| United Kingdom | Montserrat | 87 | 109 | 2 | 2005 | 2017 |
| United Kingdom | Pitcairn | 6 | 12 | 2 | 2009 | 2023 |
| United Kingdom | Turks and Caicos Islands | 66 | 123 | 4 | 2004 | 2024 |
| United States | American Samoa | 1,039 | 1,219 | 4 | 1997 | 2019 |
| United States | Guam | 391 | 545 | 4 | 1997 | 2021 |
| United States | Hawaii | 2,019 | 2,405 | 4 | 1997 | 2021 |
| United States | Howland and Baker Islands | 150 | 150 | 1 | 2015 | 2017 |
| United States | Jarvis Island | 222 | 222 | 1 | 2015 | 2017 |
| United States | Johnston Atoll | 46 | 46 | 1 | 2015 | 2015 |
| United States | Northern Mariana Islands | 680 | 924 | 3 | 1999 | 2020 |
| United States | Palmyra Atoll | 194 | 298 | 2 | 2009 | 2019 |
| United States | Puerto Rico | 2,968 | 3,279 | 7 | 1982 | 2024 |
| United States | United States | 1,967 | 5,190 | 12 | 1984 | 2024 |
| United States | United States Virgin Islands | 5,871 | 6,860 | 9 | 1982 | 2024 |
| United States | Wake Island | 146 | 146 | 1 | 2014 | 2017 |
| Vanuatu | Vanuatu | 75 | 114 | 3 | 2004 | 2023 |
| Venezuela | Venezuela | 38 | 45 | 2 | 2004 | 2018 |
| Vietnam | Vietnam | 182 | 356 | 1 | 1998 | 2011 |
| Yemen | Yemen | 6 | 12 | 3 | 1999 | 2017 |

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

- Spalding, M. D., Fox, H. E., Allen, G. R., Davidson, N., Ferdaña, Z.
  A., Finlayson, M. A. X., \[…\] & Robertson, J. (**2007**). [Marine
  ecoregions of the world: a bioregionalization of coastal and shelf
  areas](https://doi.org/10.1641/B570707). *BioScience*, 57(7), 573-583.

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

    Warning in system2("quarto", "-V", stdout = TRUE, env = paste0("TMPDIR=", :
    l'exécution de la commande '"quarto"
    TMPDIR=C:/Users/jwicquart/AppData/Local/Temp/RtmpWIPnIO/file354871463a99 -V'
    renvoie un statut 1
    ─ Session info ───────────────────────────────────────────────────────────────
     setting  value
     version  R version 4.5.0 (2025-04-11 ucrt)
     os       Windows 11 x64 (build 22631)
     system   x86_64, mingw32
     ui       RTerm
     language (EN)
     collate  French_France.utf8
     ctype    French_France.utf8
     tz       Europe/Paris
     date     2025-06-25
     pandoc   3.4 @ C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools/ (via rmarkdown)
     quarto   NA @ C:\\PROGRA~1\\RStudio\\RESOUR~1\\app\\bin\\quarto\\bin\\quarto.exe

    ─ Packages ───────────────────────────────────────────────────────────────────
     ! package           * version date (UTC) lib source
       askpass             1.2.1   2024-10-04 [1] CRAN (R 4.5.0)
       backports           1.5.0   2024-05-23 [1] CRAN (R 4.5.0)
       base64enc           0.1-3   2015-07-28 [1] CRAN (R 4.5.0)
       bit                 4.6.0   2025-03-06 [1] CRAN (R 4.5.0)
       bit64               4.6.0-1 2025-01-16 [1] CRAN (R 4.5.0)
       blob                1.2.4   2023-03-17 [1] CRAN (R 4.5.0)
       broom               1.0.8   2025-03-28 [1] CRAN (R 4.5.0)
       bslib               0.9.0   2025-01-30 [1] CRAN (R 4.5.0)
       cachem              1.1.0   2024-05-16 [1] CRAN (R 4.5.0)
       callr               3.7.6   2024-03-25 [1] CRAN (R 4.5.0)
       cellranger          1.1.0   2016-07-27 [1] CRAN (R 4.5.0)
       class               7.3-23  2025-01-01 [1] CRAN (R 4.5.0)
       classInt            0.4-11  2025-01-08 [1] CRAN (R 4.5.0)
       cli                 3.6.5   2025-04-23 [1] CRAN (R 4.5.0)
       clipr               0.8.0   2022-02-22 [1] CRAN (R 4.5.0)
       conflicted          1.2.0   2023-02-01 [1] CRAN (R 4.5.0)
       cpp11               0.5.2   2025-03-03 [1] CRAN (R 4.5.0)
       crayon              1.5.3   2024-06-20 [1] CRAN (R 4.5.0)
       crosstalk           1.2.1   2023-11-23 [1] CRAN (R 4.5.0)
       curl                6.2.2   2025-03-24 [1] CRAN (R 4.5.0)
       data.table          1.17.0  2025-02-22 [1] CRAN (R 4.5.0)
       DBI                 1.2.3   2024-06-02 [1] CRAN (R 4.5.0)
       dbplyr              2.5.0   2024-03-19 [1] CRAN (R 4.5.0)
       digest              0.6.37  2024-08-19 [1] CRAN (R 4.5.0)
       dplyr             * 1.1.4   2023-11-17 [1] CRAN (R 4.5.0)
       DT                  0.33    2024-04-04 [1] CRAN (R 4.5.0)
       dtplyr              1.3.1   2023-03-22 [1] CRAN (R 4.5.0)
       e1071               1.7-16  2024-09-16 [1] CRAN (R 4.5.0)
       evaluate            1.0.3   2025-01-10 [1] CRAN (R 4.5.0)
       fansi               1.0.6   2023-12-08 [1] CRAN (R 4.5.0)
       farver              2.1.2   2024-05-13 [1] CRAN (R 4.5.0)
       fastmap             1.2.0   2024-05-15 [1] CRAN (R 4.5.0)
       fontawesome         0.5.3   2024-11-16 [1] CRAN (R 4.5.0)
       forcats           * 1.0.0   2023-01-29 [1] CRAN (R 4.5.0)
       formattable         0.2.1   2021-01-07 [1] CRAN (R 4.5.0)
       fs                  1.6.6   2025-04-12 [1] CRAN (R 4.5.0)
       gargle              1.5.2   2023-07-20 [1] CRAN (R 4.5.0)
       generics            0.1.4   2025-05-09 [1] CRAN (R 4.5.0)
       ggplot2           * 3.5.2   2025-04-09 [1] CRAN (R 4.5.0)
       glue                1.8.0   2024-09-30 [1] CRAN (R 4.5.0)
       googledrive         2.1.1   2023-06-11 [1] CRAN (R 4.5.0)
       googlesheets4       1.1.1   2023-06-11 [1] CRAN (R 4.5.0)
       gtable              0.3.6   2024-10-25 [1] CRAN (R 4.5.0)
       haven               2.5.4   2023-11-30 [1] CRAN (R 4.5.0)
       highr               0.11    2024-05-26 [1] CRAN (R 4.5.0)
       hms                 1.1.3   2023-03-21 [1] CRAN (R 4.5.0)
       htmltools           0.5.8.1 2024-04-04 [1] CRAN (R 4.5.0)
       htmlwidgets         1.6.4   2023-12-06 [1] CRAN (R 4.5.0)
       httpuv              1.6.16  2025-04-16 [1] CRAN (R 4.5.0)
       httr                1.4.7   2023-08-15 [1] CRAN (R 4.5.0)
       ids                 1.0.1   2017-05-31 [1] CRAN (R 4.5.0)
       isoband             0.2.7   2022-12-20 [1] CRAN (R 4.5.0)
       jquerylib           0.1.4   2021-04-26 [1] CRAN (R 4.5.0)
       jsonlite            2.0.0   2025-03-27 [1] CRAN (R 4.5.0)
       kableExtra          1.4.0   2024-01-24 [1] CRAN (R 4.5.0)
       KernSmooth          2.23-26 2025-01-01 [1] CRAN (R 4.5.0)
       knitr             * 1.50    2025-03-16 [1] CRAN (R 4.5.0)
       labeling            0.4.3   2023-08-29 [1] CRAN (R 4.5.0)
       later               1.4.2   2025-04-08 [1] CRAN (R 4.5.0)
       lattice             0.22-7  2025-04-02 [1] CRAN (R 4.5.0)
       lazyeval            0.2.2   2019-03-15 [1] CRAN (R 4.5.0)
       leaflet             2.2.2   2024-03-26 [1] CRAN (R 4.5.0)
       leaflet.providers   2.0.0   2023-10-17 [1] CRAN (R 4.5.0)
       lifecycle           1.0.4   2023-11-07 [1] CRAN (R 4.5.0)
       lubridate         * 1.9.4   2024-12-08 [1] CRAN (R 4.5.0)
       magrittr            2.0.3   2022-03-30 [1] CRAN (R 4.5.0)
       MASS                7.3-65  2025-02-28 [1] CRAN (R 4.5.0)
       Matrix              1.7-3   2025-03-11 [1] CRAN (R 4.5.0)
       memoise             2.0.1   2021-11-26 [1] CRAN (R 4.5.0)
     R mermaidr            <NA>    <NA>       [?] <NA>
       mgcv                1.9-3   2025-04-04 [1] CRAN (R 4.5.0)
       mime                0.13    2025-03-17 [1] CRAN (R 4.5.0)
       modelr              0.1.11  2023-03-22 [1] CRAN (R 4.5.0)
       nlme                3.1-168 2025-03-31 [1] CRAN (R 4.5.0)
       openssl             2.3.2   2025-02-03 [1] CRAN (R 4.5.0)
       pillar              1.10.2  2025-04-05 [1] CRAN (R 4.5.0)
       pkgconfig           2.0.3   2019-09-22 [1] CRAN (R 4.5.0)
       plotly              4.10.4  2024-01-13 [1] CRAN (R 4.5.0)
       png                 0.1-8   2022-11-29 [1] CRAN (R 4.5.0)
       prettydoc           0.4.1   2021-01-10 [1] CRAN (R 4.5.0)
       prettyunits         1.2.0   2023-09-24 [1] CRAN (R 4.5.0)
       processx            3.8.6   2025-02-21 [1] CRAN (R 4.5.0)
       progress            1.2.3   2023-12-06 [1] CRAN (R 4.5.0)
       promises            1.3.2   2024-11-28 [1] CRAN (R 4.5.0)
       proxy               0.4-27  2022-06-09 [1] CRAN (R 4.5.0)
       ps                  1.9.1   2025-04-12 [1] CRAN (R 4.5.0)
       purrr             * 1.0.4   2025-02-05 [1] CRAN (R 4.5.0)
       R6                  2.6.1   2025-02-15 [1] CRAN (R 4.5.0)
       ragg                1.4.0   2025-04-10 [1] CRAN (R 4.5.0)
       rappdirs            0.3.3   2021-01-31 [1] CRAN (R 4.5.0)
       raster              3.6-32  2025-03-28 [1] CRAN (R 4.5.0)
       RColorBrewer        1.1-3   2022-04-03 [1] CRAN (R 4.5.0)
       Rcpp                1.0.14  2025-01-12 [1] CRAN (R 4.5.0)
       readr             * 2.1.5   2024-01-10 [1] CRAN (R 4.5.0)
       readxl            * 1.4.5   2025-03-07 [1] CRAN (R 4.5.0)
       rematch             2.0.0   2023-08-30 [1] CRAN (R 4.5.0)
       rematch2            2.1.2   2020-05-01 [1] CRAN (R 4.5.0)
       reprex              2.1.1   2024-07-06 [1] CRAN (R 4.5.0)
       rlang               1.1.6   2025-04-11 [1] CRAN (R 4.5.0)
       rmarkdown           2.29    2024-11-04 [1] CRAN (R 4.5.0)
       rstudioapi          0.17.1  2024-10-22 [1] CRAN (R 4.5.0)
       rvest               1.0.4   2024-02-12 [1] CRAN (R 4.5.0)
       s2                  1.1.7   2024-07-17 [1] CRAN (R 4.5.0)
       sass                0.4.10  2025-04-11 [1] CRAN (R 4.5.0)
       scales              1.4.0   2025-04-24 [1] CRAN (R 4.5.0)
       selectr             0.4-2   2019-11-20 [1] CRAN (R 4.5.0)
       sf                * 1.0-20  2025-03-24 [1] CRAN (R 4.5.0)
       sp                  2.2-0   2025-02-01 [1] CRAN (R 4.5.0)
       stringi             1.8.7   2025-03-27 [1] CRAN (R 4.5.0)
       stringr           * 1.5.1   2023-11-14 [1] CRAN (R 4.5.0)
       svglite             2.2.0   2025-05-07 [1] CRAN (R 4.5.0)
       sys                 3.4.3   2024-10-04 [1] CRAN (R 4.5.0)
       systemfonts         1.2.3   2025-04-30 [1] CRAN (R 4.5.0)
       terra               1.8-50  2025-05-09 [1] CRAN (R 4.5.0)
       textshaping         1.0.1   2025-05-01 [1] CRAN (R 4.5.0)
       tibble            * 3.2.1   2023-03-20 [1] CRAN (R 4.5.0)
       tidyr             * 1.3.1   2024-01-24 [1] CRAN (R 4.5.0)
       tidyselect          1.2.1   2024-03-11 [1] CRAN (R 4.5.0)
       tidyverse         * 2.0.0   2023-02-22 [1] CRAN (R 4.5.0)
       timechange          0.3.0   2024-01-18 [1] CRAN (R 4.5.0)
       tinytex             0.57    2025-04-15 [1] CRAN (R 4.5.0)
       tzdb                0.5.0   2025-03-15 [1] CRAN (R 4.5.0)
       units               0.8-7   2025-03-11 [1] CRAN (R 4.5.0)
       utf8                1.2.5   2025-05-01 [1] CRAN (R 4.5.0)
       uuid                1.2-1   2024-07-29 [1] CRAN (R 4.5.0)
       vctrs               0.6.5   2023-12-01 [1] CRAN (R 4.5.0)
       viridisLite         0.4.2   2023-05-02 [1] CRAN (R 4.5.0)
       vroom               1.6.5   2023-12-05 [1] CRAN (R 4.5.0)
       withr               3.0.2   2024-10-28 [1] CRAN (R 4.5.0)
       wk                  0.9.4   2024-10-11 [1] CRAN (R 4.5.0)
       xfun                0.52    2025-04-02 [1] CRAN (R 4.5.0)
       xml2                1.3.8   2025-03-14 [1] CRAN (R 4.5.0)
       yaml                2.3.10  2024-07-26 [1] CRAN (R 4.5.0)

     [1] C:/Users/jwicquart/AppData/Local/Programs/R/R-4.5.0/library

     * ── Packages attached to the search path.
     R ── Package was removed from disk.

    ──────────────────────────────────────────────────────────────────────────────
