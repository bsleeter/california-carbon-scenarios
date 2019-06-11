# Effects of 21st century climate, land use, and disturbances on ecosystem carbon balance in California

Projections of carbon storage and flux in California under 32 alternative futures

*Global Change Biology*: https://onlinelibrary.wiley.com/doi/10.1111/gcb.14677

#### Authors
Benjamin M. Sleeter<sup>1</sup>*, David C. Marvin<sup>2,3</sup>, D. Richard Cameron<sup>2</sup>, Paul C. Selmants<sup>4</sup>, Leroy Westerling<sup>5</sup>, Jason Kreitler<sup>6</sup>, Colin J. Daniel<sup>7</sup>, Jinxun Liu<sup>4</sup>, Tamara S. Wilson<sup>4</sup>

#### Affiliations
<sup>1</sup>U.S. Geological Survey, Seattle, WA, USA; bsleeter@usgs.gov; (253) 343-3363  
<sup>2</sup>The Nature Conservancy, San Francisco, CA, USA  
<sup>3</sup>Salo Sciences, San Francisco, CA, USA  
<sup>4</sup>U.S. Geological Survey, Menlo Park, CA, USA  
<sup>5</sup>University of California Merced, California, USA  
<sup>6</sup>U.S. Geological Survey, Boise, ID, USA  
<sup>7</sup>Apex Resource Management Solutions Ltd., Ottawa, ON, CAN  

**Keywords**: land use, climate change, carbon balance, California, scenarios, disturbance

## Abstract
Terrestrial ecosystems are an important sink for atmospheric carbon dioxide (CO<sub>2</sub>), sequestering ~30% of annual anthropogenic emissions and slowing the rise of atmospheric CO2. However, the future direction and magnitude of the land sink is highly uncertain. We examined how historical and projected changes in climate, land use, and ecosystem disturbances affect the carbon balance of terrestrial ecosystems in California over the period 2001-2100. We modeled 32 unique scenarios, spanning four land-use and two radiative forcing scenarios as simulated by four global climate models. Between 2001-2015 carbon storage in California’s terrestrial ecosystems declined by -188.4 Tg C, with a mean annual flux ranging from a source of -89.8 Tg C yr<sup>-1</sup> to sink of 60.1 Tg C yr<sup>-1</sup>. The large variability in the magnitude of the state’s carbon source/sink was primarily attributable to inter-annual variability in weather and climate, which affected the rate of carbon uptake in vegetation and the rate of ecosystem respiration. Under nearly all future scenarios, carbon storage in terrestrial ecosystems was projected to decline, with an average loss of -9.4% (-432.3 Tg C) by the year 2100 from current stocks. However, uncertainty in the magnitude of carbon loss was high, with individual scenario projections ranging from -916.2 Tg C to 121.2 Tg C and was largely driven by differences in future climate conditions projected by climate models. Moving from a high to a low radiative forcing scenario reduced net ecosystem carbon loss by 21% and when combined with reductions in land-use change (i.e. moving from a high to a low land use scenario), net carbon losses were reduced by 55% on average. However, reconciling large uncertainties associated with the effect of increasing atmospheric CO<sub>2</sub> is needed to better constrain models used to establish baseline conditions from which ecosystem-based climate mitigation strategies can be evaluated.

## Data Release
All output results from the 32 scenarios described in this report are available from the ScienceBase online repository. Each scenario includes an SQLite database (SyncroSim “.ssim” file) and a compressed folder with all spatial output. Tabular output are contained entirely within each SQLite database. Each database file is ~36 GB and the corresponding compressed spatial output maps are an additional ~18 GB. The entire library is ~1.7 Tb. Given the large volume of data, several intermediate products were generated from which all results present in the paper were derived.

#### Ecoregion Tabular Summaries

* State Class Area by Ecoregion and Scenario (Mean and 95% Confidence Intervals)
* Transition Area by Ecoregion and Scenario (Mean and 95% Confidence Intervals)
* Carbon Stocks by Ecoregion and Scenario (Mean and 95% Confidence Intervals)
* Carbon Fluxes by Ecoregion and Scenario (Mean and 95% Confidence Intervals)

#### State Tabular Summaries

* State Class Area by Scenario (Mean and 95% Confidence Intervals)
* Transition Area by Scenario (Mean and 95% Confidence Intervals)
* Carbon Stocks by Scenario (Mean and 95% Confidence Intervals)
* Carbon Fluxes by Scenario (Mean and 95% Confidence Intervals)

## Running the Model
The LUCAS model runs within the Syncro-Sim software application. All simulations were run using Syncro-Sim software version 2.0.18, under the Mono framework for Linux. The STSM and SF modules used in this study were version 3.1.18. We ran the simulations on the Comet system at the San Diego Super-computing Center under the NSF Extreme Science and Engineering Discovery Environment (XSEDE) program through allocation TG-DEB17001767.

The following steps are required to run the model used in this analysis:

* Download and install the latest Windows or LINUX version of the Syncro-Sim software, available at http://www.apexrms.com.
* Download and unzip the model files, including spatial input files and a “.ssim” (SQLite) database from the online repository (to be filled in upon publication).
* Use the Syncro-Sim software to open the “California Carbon Model.ssim” file and select a scenario to run.
* Alternatively, the model can be built from scratch using the R programming language with the rsyncrosim package installed. To follow this approach, download the “California Carbon Model R Code.zip” data package and run the necessary R scripts.

## Code and data availability
The model, source code, and data required to replicate this study, as well as the output data supporting the conclusions of the study are available through the USGS ScienceBase repository and archived in this GitHub repository. The repository has the following structure:

* The **"model-build"** folder contains all the files and R code to build the model from scratch. Users wishing to do this should run the two R scripts in order. The model can then be run using the Windows UI, from the Command Line, or directly from R using the rSyncroSim package.
* The **"global-change-biology"** folder contains all the files required to produce the final manuscript and its supplemental material. The manuscript was written using RMarkdown. 
* The **"base-model"** folder contains a ready-to-run model with all 32 scenarios available.



