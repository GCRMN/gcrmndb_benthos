
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
[MERMAID](https://dashboard.datamermaid.org/), *Pa.* = data paper, *Rp.*
= data repository, *Sh.* = data sharing), *modified* is the date
(YYYY-MM-DD) of the last version of the individual dataset, *aggregator*
is the name of the person in charge of the data integration for the
individual dataset considered. The column names (except *aggregator*)
correspond to [DarwinCore terms](https://dwc.tdwg.org/terms).

<table>
<thead>
<tr>
<th style="text-align:center;">
datasetID
</th>
<th style="text-align:left;">
rightsHolder
</th>
<th style="text-align:left;">
accessRights
</th>
<th style="text-align:center;">
type
</th>
<th style="text-align:center;">
modified
</th>
<th style="text-align:center;">
aggregator
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:center;">
0001
</td>
<td style="text-align:left;">
[USVI - Yawzi and
Tektite](https://portal.edirepository.org/nis/mapbrowse?scope=edi&identifier=1091&revision=1)
</td>
<td style="text-align:left;">
open
</td>
<td style="text-align:center;">
Rp.
</td>
<td style="text-align:center;">
21/02/2022
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0002
</td>
<td style="text-align:left;">
[USVI -
Random](https://portal.edirepository.org/nis/mapbrowse?scope=edi&identifier=1091&revision=1)
</td>
<td style="text-align:left;">
open
</td>
<td style="text-align:center;">
Rp.
</td>
<td style="text-align:center;">
21/02/2022
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0003
</td>
<td style="text-align:left;">
AIMS LTMP
</td>
<td style="text-align:left;">
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0004
</td>
<td style="text-align:left;">
[CRIOBE -
MPA](https://observatoire.criobe.pf/wiki/tiki-index.php?page=AMP+Moorea&structure=SO+CORAIL)
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
08/09/2022
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0005
</td>
<td style="text-align:left;">
[CRIOBE - Polynesia
Mana](https://observatoire.criobe.pf/wiki/tiki-index.php?page=Transect+corallien+par+photo-quadrat&structure=SO+CORAIL&latest=1)
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0006
</td>
<td style="text-align:left;">
[CRIOBE -
Tiahura](https://observatoire.criobe.pf/wiki/tiki-index.php?page=Technique+d%27%C3%A9chantillonnage+Benthos+LTT&structure=SO+CORAIL&latest=1)
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
31/12/2022
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0007
</td>
<td style="text-align:left;">
[CRIOBE - ATPP barrier
reef](https://observatoire.criobe.pf/wiki/tiki-index.php?page=R%C3%A9cif+Barri%C3%A8re+ATPP&structure=SO+CORAIL&latest=1)
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0008
</td>
<td style="text-align:left;">
[CRIOBE - ATPP outer
slope](https://observatoire.criobe.pf/wiki/tiki-index.php?page=Pente+externe+ATPP&structure=SO+CORAIL&latest=1)
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0009
</td>
<td style="text-align:left;">
[Seaview Survey](https://www.nature.com/articles/s41597-020-00698-6)
</td>
<td style="text-align:left;">
open
</td>
<td style="text-align:center;">
Pa.
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0010
</td>
<td style="text-align:left;">
[2013-2014_Koro Island,
Fiji](https://dashboard.datamermaid.org/?project=2013-2014_Koro%20Island,%20Fiji)
</td>
<td style="text-align:left;">
open (summary)
</td>
<td style="text-align:center;">
Me.
</td>
<td style="text-align:center;">
08/06/2021
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0011
</td>
<td style="text-align:left;">
[NCRMP - American
Samoa](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:NCRMP-StRS-Images-AmSam)
</td>
<td style="text-align:left;">
open
</td>
<td style="text-align:center;">
Rp.
</td>
<td style="text-align:center;">
14/09/2021
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0012
</td>
<td style="text-align:left;">
[NCRMP - CNMI and
Guam](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:NCRMP-StRS-Images-Marianas)
</td>
<td style="text-align:left;">
open
</td>
<td style="text-align:center;">
Rp.
</td>
<td style="text-align:center;">
12/10/2018
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0013
</td>
<td style="text-align:left;">
[NCRMP -
Hawaii](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:NCRMP-StRS-Images-HI)
</td>
<td style="text-align:left;">
open
</td>
<td style="text-align:center;">
Rp.
</td>
<td style="text-align:center;">
11/11/2022
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0014
</td>
<td style="text-align:left;">
[NCRMP -
PRIA](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:NCRMP-StRS-Images-PRIA)
</td>
<td style="text-align:left;">
open
</td>
<td style="text-align:center;">
Rp.
</td>
<td style="text-align:center;">
30/07/2021
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0015
</td>
<td style="text-align:left;">
[ReefCheck -
Indo-Pacific](https://www.reefcheck.org/tropical-program/tropical-monitoring-instruction/)
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Db.
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0016
</td>
<td style="text-align:left;">
Biosphere Foundation
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0017
</td>
<td style="text-align:left;">
KNS
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
27/12/2022
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0018
</td>
<td style="text-align:left;">
Kiribati
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
05/03/2020
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0019
</td>
<td style="text-align:left;">
SLN
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
12/05/2022
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0020
</td>
<td style="text-align:left;">
[PACN](https://www.nps.gov/im/pacn/benthic.htm)
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0021
</td>
<td style="text-align:left;">
RORC
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0022
</td>
<td style="text-align:left;">
[MCRMP](https://micronesiareefmonitoring.com/)
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0023
</td>
<td style="text-align:left;">
PA-NC
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0024
</td>
<td style="text-align:left;">
Laurent WANTIEZ
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0025
</td>
<td style="text-align:left;">
[2011_Southern
Bua](https://dashboard.datamermaid.org/?project=2011_Southern%20Bua)
</td>
<td style="text-align:left;">
open (summary)
</td>
<td style="text-align:center;">
Me.
</td>
<td style="text-align:center;">
08/09/2021
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0026
</td>
<td style="text-align:left;">
[2012_Western
Bua](https://dashboard.datamermaid.org/?project=2012_Western%20Bua)
</td>
<td style="text-align:left;">
open (summary)
</td>
<td style="text-align:center;">
Me.
</td>
<td style="text-align:center;">
10/09/2021
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0027
</td>
<td style="text-align:left;">
[2009-2011_Kubulau](https://dashboard.datamermaid.org/?project=2009-2011_Kubulau)
</td>
<td style="text-align:left;">
open (summary)
</td>
<td style="text-align:center;">
Me.
</td>
<td style="text-align:center;">
08/09/2021
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0028
</td>
<td style="text-align:left;">
[C<sub>2</sub>O Pacific](https://c2o.net.au/our-work-in-the-pacific/)
</td>
<td style="text-align:left;">
upon request
</td>
<td style="text-align:center;">
Sh.
</td>
<td style="text-align:center;">
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0029
</td>
<td style="text-align:left;">
[2022_BAF and
WISH](https://dashboard.datamermaid.org/?project=2022_BAF%20and%20WISH%20coral%20reef%20surveys%20in%20Tailevu_Ovalau)
</td>
<td style="text-align:left;">
open (summary)
</td>
<td style="text-align:center;">
Me.
</td>
<td style="text-align:center;">
06/06/2022
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0030
</td>
<td style="text-align:left;">
[PNG BAF
2019](https://dashboard.datamermaid.org/?project=PNG%20BAF%202019)
</td>
<td style="text-align:left;">
open (summary)
</td>
<td style="text-align:center;">
Me.
</td>
<td style="text-align:center;">
31/10/2019
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0031
</td>
<td style="text-align:left;">
[2017_Northern�Lau](https://dashboard.datamermaid.org/?project=2017_Northern%20Lau)
</td>
<td style="text-align:left;">
open (summary)
</td>
<td style="text-align:center;">
Me.
</td>
<td style="text-align:center;">
08/02/2021
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0032
</td>
<td style="text-align:left;">
[2013-2014_Vatu-i-Ra](https://dashboard.datamermaid.org/?project=2013-2014_Vatu-i-Ra)
</td>
<td style="text-align:left;">
open (summary)
</td>
<td style="text-align:center;">
Me.
</td>
<td style="text-align:center;">
08/02/2021
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0033
</td>
<td style="text-align:left;">
[2019_Dama�Bureta](https://dashboard.datamermaid.org/?project=2019_Dama%20Bureta%20Waibula%20and%20Dawasamu-WISH%20ecological%20survey)
</td>
<td style="text-align:left;">
open (summary)
</td>
<td style="text-align:center;">
Me.
</td>
<td style="text-align:center;">
12/08/2020
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0034
</td>
<td style="text-align:left;">
[2020_NamenaAndVatuira](https://dashboard.datamermaid.org/?project=2020_NamenaAndVatuira%20coral%20reef%20surveys)
</td>
<td style="text-align:left;">
open (summary)
</td>
<td style="text-align:center;">
Me.
</td>
<td style="text-align:center;">
12/10/2020
</td>
<td style="text-align:center;">
JW
</td>
</tr>
<tr>
<td style="text-align:center;">
0035
</td>
<td style="text-align:left;">
[Lau�Seascape�Surveys](https://dashboard.datamermaid.org/?project=Lau%20Seascape%20Surveys%20March%202022)
</td>
<td style="text-align:left;">
open (summary)
</td>
<td style="text-align:center;">
Me.
</td>
<td style="text-align:center;">
18/04/2022
</td>
<td style="text-align:center;">
JW
</td>
</tr>
</tbody>
</table>

## 6. Description of the synthetic dataset

On the 2023-07-19, the `gcrmndb_benthos` synthetic dataset contains a
total of **805,539 observations** (*i.e* rows) representing **9,432
sites** and **21,786 surveys**.

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

<table>
<thead>
<tr>
<th style="text-align:right;">
GCRMN region
</th>
<th style="text-align:right;">
Sites (n)
</th>
<th style="text-align:right;">
Surveys (n)
</th>
<th style="text-align:right;">
Datasets (n)
</th>
<th style="text-align:center;">
First year
</th>
<th style="text-align:center;">
Last year
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
Australia
</td>
<td style="text-align:right;">
546
</td>
<td style="text-align:right;">
4175
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
1995
</td>
<td style="text-align:center;">
2019
</td>
</tr>
<tr>
<td style="text-align:right;">
Caribbean
</td>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
236
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
1987
</td>
<td style="text-align:center;">
2021
</td>
</tr>
<tr>
<td style="text-align:right;">
EAS
</td>
<td style="text-align:right;">
2378
</td>
<td style="text-align:right;">
5232
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2022
</td>
</tr>
<tr>
<td style="text-align:right;">
ETP
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1998
</td>
<td style="text-align:center;">
2004
</td>
</tr>
<tr>
<td style="text-align:right;">
Pacific
</td>
<td style="text-align:right;">
6199
</td>
<td style="text-align:right;">
11580
</td>
<td style="text-align:right;">
31
</td>
<td style="text-align:center;">
1987
</td>
<td style="text-align:center;">
2023
</td>
</tr>
<tr>
<td style="text-align:right;">
South Asia
</td>
<td style="text-align:right;">
151
</td>
<td style="text-align:right;">
217
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2022
</td>
</tr>
<tr>
<td style="text-align:right;">
WIO
</td>
<td style="text-align:right;">
145
</td>
<td style="text-align:right;">
341
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2019
</td>
</tr>
</tbody>
</table>

**Table 7.** Summary of the content of the `gcrmndb_benthos` synthetic
dataset per country and territory. The total number of datasets
integrated within the `gcrmndb_benthos` can differ from the sum of the
column `Datasets (n)`, as some datasets includes sites in different
territories.

<table>
<thead>
<tr>
<th style="text-align:right;">
Country
</th>
<th style="text-align:left;">
Territory
</th>
<th style="text-align:right;">
Sites (n)
</th>
<th style="text-align:right;">
Surveys (n)
</th>
<th style="text-align:right;">
Datasets (n)
</th>
<th style="text-align:center;">
First year
</th>
<th style="text-align:center;">
Last year
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
Australia
</td>
<td style="text-align:left;">
Australia
</td>
<td style="text-align:right;">
524
</td>
<td style="text-align:right;">
4113
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
1995
</td>
<td style="text-align:center;">
2019
</td>
</tr>
<tr>
<td style="text-align:right;">
Australia
</td>
<td style="text-align:left;">
Christmas Island
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
13
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2003
</td>
<td style="text-align:center;">
2007
</td>
</tr>
<tr>
<td style="text-align:right;">
Australia
</td>
<td style="text-align:left;">
Cocos Islands
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:right;">
49
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2008
</td>
</tr>
<tr>
<td style="text-align:right;">
Bangladesh
</td>
<td style="text-align:left;">
Bangladesh
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2005
</td>
<td style="text-align:center;">
2006
</td>
</tr>
<tr>
<td style="text-align:right;">
Brunei
</td>
<td style="text-align:left;">
Brunei
</td>
<td style="text-align:right;">
38
</td>
<td style="text-align:right;">
45
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2016
</td>
</tr>
<tr>
<td style="text-align:right;">
Cambodia
</td>
<td style="text-align:left;">
Cambodia
</td>
<td style="text-align:right;">
91
</td>
<td style="text-align:right;">
98
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1998
</td>
<td style="text-align:center;">
2013
</td>
</tr>
<tr>
<td style="text-align:right;">
China
</td>
<td style="text-align:left;">
China
</td>
<td style="text-align:right;">
100
</td>
<td style="text-align:right;">
366
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2012
</td>
</tr>
<tr>
<td style="text-align:right;">
Colombia
</td>
<td style="text-align:left;">
Colombia
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1998
</td>
<td style="text-align:center;">
1999
</td>
</tr>
<tr>
<td style="text-align:right;">
Costa Rica
</td>
<td style="text-align:left;">
Costa Rica
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2004
</td>
<td style="text-align:center;">
2004
</td>
</tr>
<tr>
<td style="text-align:right;">
East Timor
</td>
<td style="text-align:left;">
East Timor
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
12
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2004
</td>
<td style="text-align:center;">
2017
</td>
</tr>
<tr>
<td style="text-align:right;">
Fiji
</td>
<td style="text-align:left;">
Fiji
</td>
<td style="text-align:right;">
584
</td>
<td style="text-align:right;">
921
</td>
<td style="text-align:right;">
11
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2022
</td>
</tr>
<tr>
<td style="text-align:right;">
France
</td>
<td style="text-align:left;">
Europa Island
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2002
</td>
<td style="text-align:center;">
2002
</td>
</tr>
<tr>
<td style="text-align:right;">
France
</td>
<td style="text-align:left;">
French Polynesia
</td>
<td style="text-align:right;">
150
</td>
<td style="text-align:right;">
2000
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:center;">
1987
</td>
<td style="text-align:center;">
2022
</td>
</tr>
<tr>
<td style="text-align:right;">
France
</td>
<td style="text-align:left;">
Mayotte
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:right;">
87
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2003
</td>
<td style="text-align:center;">
2017
</td>
</tr>
<tr>
<td style="text-align:right;">
France
</td>
<td style="text-align:left;">
New Caledonia
</td>
<td style="text-align:right;">
721
</td>
<td style="text-align:right;">
3056
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2023
</td>
</tr>
<tr>
<td style="text-align:right;">
France
</td>
<td style="text-align:left;">
Réunion
</td>
<td style="text-align:right;">
32
</td>
<td style="text-align:right;">
133
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2003
</td>
<td style="text-align:center;">
2016
</td>
</tr>
<tr>
<td style="text-align:right;">
India
</td>
<td style="text-align:left;">
India
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1998
</td>
<td style="text-align:center;">
1998
</td>
</tr>
<tr>
<td style="text-align:right;">
Indonesia
</td>
<td style="text-align:left;">
Indonesia
</td>
<td style="text-align:right;">
547
</td>
<td style="text-align:right;">
907
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2022
</td>
</tr>
<tr>
<td style="text-align:right;">
Japan
</td>
<td style="text-align:left;">
Japan
</td>
<td style="text-align:right;">
44
</td>
<td style="text-align:right;">
102
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2015
</td>
</tr>
<tr>
<td style="text-align:right;">
Kenya
</td>
<td style="text-align:left;">
Kenya
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2003
</td>
<td style="text-align:center;">
2004
</td>
</tr>
<tr>
<td style="text-align:right;">
Kiribati
</td>
<td style="text-align:left;">
Gilbert Islands
</td>
<td style="text-align:right;">
18
</td>
<td style="text-align:right;">
18
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
2011
</td>
<td style="text-align:center;">
2018
</td>
</tr>
<tr>
<td style="text-align:right;">
Madagascar
</td>
<td style="text-align:left;">
Madagascar
</td>
<td style="text-align:right;">
42
</td>
<td style="text-align:right;">
54
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2001
</td>
<td style="text-align:center;">
2019
</td>
</tr>
<tr>
<td style="text-align:right;">
Malaysia
</td>
<td style="text-align:left;">
Malaysia
</td>
<td style="text-align:right;">
621
</td>
<td style="text-align:right;">
2174
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2021
</td>
</tr>
<tr>
<td style="text-align:right;">
Maldives
</td>
<td style="text-align:left;">
Maldives
</td>
<td style="text-align:right;">
145
</td>
<td style="text-align:right;">
211
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2022
</td>
</tr>
<tr>
<td style="text-align:right;">
Marshall Islands
</td>
<td style="text-align:left;">
Marshall Islands
</td>
<td style="text-align:right;">
71
</td>
<td style="text-align:right;">
85
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
2002
</td>
<td style="text-align:center;">
2020
</td>
</tr>
<tr>
<td style="text-align:right;">
Micronesia
</td>
<td style="text-align:left;">
Micronesia
</td>
<td style="text-align:right;">
168
</td>
<td style="text-align:right;">
385
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
2000
</td>
<td style="text-align:center;">
2020
</td>
</tr>
<tr>
<td style="text-align:right;">
Mozambique
</td>
<td style="text-align:left;">
Mozambique
</td>
<td style="text-align:right;">
13
</td>
<td style="text-align:right;">
14
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2006
</td>
</tr>
<tr>
<td style="text-align:right;">
Myanmar
</td>
<td style="text-align:left;">
Myanmar
</td>
<td style="text-align:right;">
22
</td>
<td style="text-align:right;">
29
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2001
</td>
<td style="text-align:center;">
2013
</td>
</tr>
<tr>
<td style="text-align:right;">
New Zealand
</td>
<td style="text-align:left;">
Cook Islands
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
2005
</td>
<td style="text-align:center;">
2019
</td>
</tr>
<tr>
<td style="text-align:right;">
Palau
</td>
<td style="text-align:left;">
Palau
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
16
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2006
</td>
</tr>
<tr>
<td style="text-align:right;">
Papua New Guinea
</td>
<td style="text-align:left;">
Papua New Guinea
</td>
<td style="text-align:right;">
74
</td>
<td style="text-align:right;">
90
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
1998
</td>
<td style="text-align:center;">
2019
</td>
</tr>
<tr>
<td style="text-align:right;">
Philippines
</td>
<td style="text-align:left;">
Philippines
</td>
<td style="text-align:right;">
472
</td>
<td style="text-align:right;">
703
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2020
</td>
</tr>
<tr>
<td style="text-align:right;">
Republic of Mauritius
</td>
<td style="text-align:left;">
Republic of Mauritius
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
12
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1999
</td>
<td style="text-align:center;">
2003
</td>
</tr>
<tr>
<td style="text-align:right;">
Samoa
</td>
<td style="text-align:left;">
Samoa
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2013
</td>
<td style="text-align:center;">
2019
</td>
</tr>
<tr>
<td style="text-align:right;">
Seychelles
</td>
<td style="text-align:left;">
Seychelles
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2001
</td>
</tr>
<tr>
<td style="text-align:right;">
Solomon Islands
</td>
<td style="text-align:left;">
Solomon Islands
</td>
<td style="text-align:right;">
67
</td>
<td style="text-align:right;">
164
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
2005
</td>
<td style="text-align:center;">
2013
</td>
</tr>
<tr>
<td style="text-align:right;">
South Africa
</td>
<td style="text-align:left;">
South Africa
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2001
</td>
<td style="text-align:center;">
2005
</td>
</tr>
<tr>
<td style="text-align:right;">
Sri Lanka
</td>
<td style="text-align:left;">
Sri Lanka
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2003
</td>
<td style="text-align:center;">
2003
</td>
</tr>
<tr>
<td style="text-align:right;">
Taiwan
</td>
<td style="text-align:left;">
Taiwan
</td>
<td style="text-align:right;">
103
</td>
<td style="text-align:right;">
195
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2020
</td>
</tr>
<tr>
<td style="text-align:right;">
Tanzania
</td>
<td style="text-align:left;">
Tanzania
</td>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2008
</td>
</tr>
<tr>
<td style="text-align:right;">
Thailand
</td>
<td style="text-align:left;">
Thailand
</td>
<td style="text-align:right;">
148
</td>
<td style="text-align:right;">
245
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1998
</td>
<td style="text-align:center;">
2022
</td>
</tr>
<tr>
<td style="text-align:right;">
Tonga
</td>
<td style="text-align:left;">
Tonga
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
2002
</td>
<td style="text-align:center;">
2019
</td>
</tr>
<tr>
<td style="text-align:right;">
United Kingdom
</td>
<td style="text-align:left;">
Pitcairn
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2009
</td>
<td style="text-align:center;">
2018
</td>
</tr>
<tr>
<td style="text-align:right;">
United States
</td>
<td style="text-align:left;">
American Samoa
</td>
<td style="text-align:right;">
826
</td>
<td style="text-align:right;">
886
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2019
</td>
</tr>
<tr>
<td style="text-align:right;">
United States
</td>
<td style="text-align:left;">
Guam
</td>
<td style="text-align:right;">
301
</td>
<td style="text-align:right;">
353
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2021
</td>
</tr>
<tr>
<td style="text-align:right;">
United States
</td>
<td style="text-align:left;">
Hawaii
</td>
<td style="text-align:right;">
1725
</td>
<td style="text-align:right;">
1915
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:center;">
1997
</td>
<td style="text-align:center;">
2021
</td>
</tr>
<tr>
<td style="text-align:right;">
United States
</td>
<td style="text-align:left;">
Howland and Baker islands
</td>
<td style="text-align:right;">
150
</td>
<td style="text-align:right;">
150
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2015
</td>
<td style="text-align:center;">
2017
</td>
</tr>
<tr>
<td style="text-align:right;">
United States
</td>
<td style="text-align:left;">
Jarvis Island
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2015
</td>
<td style="text-align:center;">
2017
</td>
</tr>
<tr>
<td style="text-align:right;">
United States
</td>
<td style="text-align:left;">
Johnston Atoll
</td>
<td style="text-align:right;">
46
</td>
<td style="text-align:right;">
46
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2015
</td>
<td style="text-align:center;">
2015
</td>
</tr>
<tr>
<td style="text-align:right;">
United States
</td>
<td style="text-align:left;">
Northern Mariana Islands
</td>
<td style="text-align:right;">
679
</td>
<td style="text-align:right;">
840
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:center;">
1999
</td>
<td style="text-align:center;">
2020
</td>
</tr>
<tr>
<td style="text-align:right;">
United States
</td>
<td style="text-align:left;">
Palmyra Atoll
</td>
<td style="text-align:right;">
186
</td>
<td style="text-align:right;">
186
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2015
</td>
<td style="text-align:center;">
2015
</td>
</tr>
<tr>
<td style="text-align:right;">
United States
</td>
<td style="text-align:left;">
United States Virgin Islands
</td>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
236
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
1987
</td>
<td style="text-align:center;">
2021
</td>
</tr>
<tr>
<td style="text-align:right;">
United States
</td>
<td style="text-align:left;">
Wake Island
</td>
<td style="text-align:right;">
146
</td>
<td style="text-align:right;">
146
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
2014
</td>
<td style="text-align:center;">
2017
</td>
</tr>
<tr>
<td style="text-align:right;">
Vanuatu
</td>
<td style="text-align:left;">
Vanuatu
</td>
<td style="text-align:right;">
51
</td>
<td style="text-align:right;">
77
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:center;">
2004
</td>
<td style="text-align:center;">
2019
</td>
</tr>
<tr>
<td style="text-align:right;">
Vietnam
</td>
<td style="text-align:left;">
Vietnam
</td>
<td style="text-align:right;">
182
</td>
<td style="text-align:right;">
356
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:center;">
1998
</td>
<td style="text-align:center;">
2011
</td>
</tr>
</tbody>
</table>

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
    [1] LC_COLLATE=French_France.utf8  LC_CTYPE=French_France.utf8    LC_MONETARY=French_France.utf8
    [4] LC_NUMERIC=C                   LC_TIME=French_France.utf8    

    time zone: Europe/Paris
    tzcode source: internal

    attached base packages:
    [1] stats     graphics  grDevices utils     datasets  methods   base     

    other attached packages:
     [1] mermaidr_0.6.4    knitr_1.43        kableExtra_1.3.4  plotly_4.10.2     rmarkdown_2.23    sf_1.0-14        
     [7] taxize_0.9.100    leaflet_2.1.2     DT_0.28           formattable_0.2.1 lubridate_1.9.2   forcats_1.0.0    
    [13] stringr_1.5.0     dplyr_1.1.2       purrr_1.0.1       readr_2.1.4       tidyr_1.3.0       tibble_3.2.1     
    [19] ggplot2_3.4.2     tidyverse_2.0.0   extrafont_0.19   

    loaded via a namespace (and not attached):
     [1] DBI_1.1.3          rlang_1.1.1        magrittr_2.0.3     e1071_1.7-13       compiler_4.3.1     systemfonts_1.0.4 
     [7] vctrs_0.6.3        rvest_1.0.3        httpcode_0.3.0     pkgconfig_2.0.3    crayon_1.5.2       fastmap_1.1.1     
    [13] ellipsis_0.3.2     labeling_0.4.2     utf8_1.2.3         promises_1.2.0.1   tzdb_0.4.0         ragg_1.2.5        
    [19] bit_4.0.5          xfun_0.39          cachem_1.0.8       jsonlite_1.8.7     later_1.3.1        highr_0.10        
    [25] uuid_1.1-0         parallel_4.3.1     R6_2.5.1           bslib_0.5.0        stringi_1.7.12     extrafontdb_1.0   
    [31] jquerylib_0.1.4    Rcpp_1.0.11        iterators_1.0.14   zoo_1.8-12         httpuv_1.6.11      timechange_0.2.0  
    [37] tidyselect_1.2.0   rstudioapi_0.15.0  yaml_2.3.7         codetools_0.2-19   curl_5.0.1         lattice_0.21-8    
    [43] withr_2.5.0        evaluate_0.21      units_0.8-2        proxy_0.4-27       xml2_1.3.5         pillar_1.9.0      
    [49] KernSmooth_2.23-21 foreach_1.5.2      generics_0.1.3     vroom_1.6.3        hms_1.1.3          munsell_0.5.0     
    [55] scales_1.2.1       class_7.3-22       glue_1.6.2         lazyeval_0.2.2     tools_4.3.1        data.table_1.14.8 
    [61] webshot_0.5.5      grid_4.3.1         bold_1.3.0         ape_5.7-1          Rttf2pt1_1.3.12    crosstalk_1.2.0   
    [67] colorspace_2.1-0   nlme_3.1-162       conditionz_0.1.0   cli_3.6.1          textshaping_0.3.6  fansi_1.0.4       
    [73] viridisLite_0.4.2  svglite_2.1.1      gtable_0.3.3       sass_0.4.6         digest_0.6.33      classInt_0.4-9    
    [79] crul_1.4.0         htmlwidgets_1.6.2  farver_2.1.1       htmltools_0.5.5    lifecycle_1.0.3    prettydoc_0.4.1   
    [85] httr_1.4.6         bit64_4.0.5       
