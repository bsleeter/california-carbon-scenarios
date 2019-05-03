#-----------------------------------------------------------------------------------
# R Scripts used to build a LUCAS Model for the State of California
# Script 1 of 4
# Define SyncroSim project and create Project Definitions

#-----------------------------------------------------------------------------------
# Created by: Benjamin M. Sleeter
# U.S. Geological Survey, Western Geographic Science Center
# bsleeter@usgs.gov
# Date of creation: December 5, 2017


#-----------------------------------------------------------------------------------
# Load packages
library(tidyverse)
library(raster)
library(rasterVis)
library(rsyncrosim)


#-----------------------------------------------------------------------------------
# Set the Syncro Sim program directory
programFolder = "C:/Program Files/SyncroSim" # Set this to location of SyncroSim installation

# Start a SyncroSim session
mySession = session(programFolder) # Start a session with SyncroSim


#-----------------------------------------------------------------------------------
# Set the current working directory
setwd("D:/california-carbon-futures/build") # Check this is correct for your computer!
getwd() # Show the current working directory


#-----------------------------------------------------------------------------------
# Create and setup a new Library
myLibrary = ssimLibrary(name = "ccf_v4", model = "stsim", session = mySession)
list.files() # Check that the new library was created on disk

# Display internal names of all the library's datasheets - corresponds to the the 'File-Library Properties' menu in SyncroSim
datasheet(myLibrary, summary = T)

# Get the current values for the Library's Backup Datasheet
sheetData = datasheet(myLibrary, name = "SSim_Backup", empty = T) # Get the current backup settings for the library
sheetData

# Modify the values for the Library's Backup Datasheet
sheetData = addRow(sheetData, data.frame(IncludeInput = TRUE, IncludeOutput = FALSE)) # Add a new row to this dataframe
saveDatasheet(myLibrary, data = sheetData, name = "SSim_Backup") # Save the new dataframe back to the library
datasheet(myLibrary, "SSim_Backup")

# Get the current values for the Library's Modules
module(mySession)

# Check if stock flow add-on is enabled for the library
addon(myLibrary)

# Enable stock flow add-on
enableAddon(myLibrary, 'stsim-stockflow') # Enable to Stock and Flow module
#enableAddon(myLibrary, 'stsim-ecodep') # Enable the ecological departure modeule
addon(myLibrary)


#-----------------------------------------------------------------------------------
# Create or open a new project
myProject = project(myLibrary, project = "ccf_v4") # Also creates a new project (if it doesn't exist already)
project(myLibrary, summary = TRUE)




#-----------------------------------------------------------------------------------
# Edit the Project Properties - corresponds to the 'Project-Properties' menu in SyncroSim

# Display internal names of all the project's datasheets - corresponds to the Project Properties in SyncroSim
projectSheetNames = datasheet(myProject, summary = T)
projectSheetNames

# Terminology
sheetData = datasheet(myProject, "STSim_Terminology")
sheetData
sheetData$AmountLabel[1] = "Area"
sheetData$AmountUnits[1] = "Square Kilometers"
sheetData$StateLabelX[1] = "LULC Class"
sheetData$StateLabelY[1] = "Subclass"
sheetData$PrimaryStratumLabel[1] = "Ecoregion"
sheetData$SecondaryStratumLabel[1] = "County"
sheetData$TertiaryStratumLabel[1] = "Ownership"
sheetData$TimestepUnits[1] = "Year"
saveDatasheet(myProject, sheetData, "STSim_Terminology")
datasheet(myProject, "STSim_Terminology")


#-----------------------------------------------------------------------------------
# Strata Project Definitions

# Define Primary Stratum (Ecoregions)
sheetData = datasheet(myProject, "STSim_Stratum", empty = T, optional = T) # Returns empty dataframe with only required column(s)
ecoregions = read.csv("R Inputs/Ecoregion.csv", header = T) # Read in a list of ecoregions and unique ID's
saveDatasheet(myProject, ecoregions, "STSim_Stratum", force = T, append = F)
datasheet(myProject, "STSim_Stratum", optional = T) # Returns entire dataframe, including optional columns

# Define Secondary Stratum (Counties)
sheetData = datasheet(myProject, "STSim_SecondaryStratum", empty = T, optional = T) # Returns empty dataframe with only required column(s)
counties = read.csv("R Inputs/County.csv", header = T) # Read in a list of counties and unique ID's
saveDatasheet(myProject, counties, "STSim_SecondaryStratum", force = T, append = F)
datasheet(myProject, "STSim_SecondaryStratum", optional = T) # Returns entire dataframe, including optional columns

# Define Tertiary Stratum (Ownership)
sheetData = datasheet(myProject, "STSim_TertiaryStratum", empty = T, optional = T) # Returns empty dataframe with only required column(s)
sheetData = addRow(sheetData, data.frame(Name = "Federal", ID = 1))
sheetData = addRow(sheetData, data.frame(Name = "Non Federal", ID = 2))
sheetData = addRow(sheetData, data.frame(Name = "Private", ID = 3))
saveDatasheet(myProject, sheetData, "STSim_TertiaryStratum", force = T, append = F)
datasheet(myProject, "STSim_TertiaryStratum", optional = T) # Returns entire dataframe, including optional columns


#-----------------------------------------------------------------------------------
# State Class Project Definitions

# First State Class Label (LULC Class)
sheetData = datasheet(myProject, "STSim_StateLabelX", empty = T, optional = T)
lulcTypes = c("Water", "Developed", "Barren", "Grassland", "Forest", "Shrubland", "Wetland", "SnowIce", "Agriculture")
saveDatasheet(myProject, data.frame(Name = lulcTypes), "STSim_StateLabelX", force = T, append = F)

# Second State Class Label (Subclass)
sheetData = datasheet(myProject, "STSim_StateLabelY", empty = T, optional = T)
subclassTypes = c("All", "Perennial", "Annual", "Transportation", "Agroforestry", "Covercrop", "PostFire", "Treated (Thinned)", "Treated (Prescribed)", "CFM")
saveDatasheet(myProject, data.frame(Name = subclassTypes), "STSim_StateLabelY", force = T, append = F)

# State Classes
stateClasses = datasheet(myProject, name = "STSim_StateClass", empty = T, optional = T)
stateClasses = addRow(stateClasses, data.frame(Name = "Water:All", StateLabelXID = "Water", StateLabelYID = "All", ID = 1))
stateClasses = addRow(stateClasses, data.frame(Name = "SnowIce:All", StateLabelXID = "SnowIce", StateLabelYID = "All", ID = 11))
stateClasses = addRow(stateClasses, data.frame(Name = "Wetland:All", StateLabelXID = "Wetland", StateLabelYID = "All", ID = 9))
stateClasses = addRow(stateClasses, data.frame(Name = "Barren:All", StateLabelXID = "Barren", StateLabelYID = "All", ID = 5))
stateClasses = addRow(stateClasses, data.frame(Name = "Grassland:All", StateLabelXID = "Grassland", StateLabelYID = "All", ID = 7))
stateClasses = addRow(stateClasses, data.frame(Name = "Shrubland:All", StateLabelXID = "Shrubland", StateLabelYID = "All", ID = 10))
stateClasses = addRow(stateClasses, data.frame(Name = "Forest:All", StateLabelXID = "Forest", StateLabelYID = "All", ID = 6))
stateClasses = addRow(stateClasses, data.frame(Name = "Developed:All", StateLabelXID = "Developed", StateLabelYID = "All", ID = 2))
stateClasses = addRow(stateClasses, data.frame(Name = "Developed:Transportation", StateLabelXID = "Developed", StateLabelYID = "Transportation", ID = 3))
stateClasses = addRow(stateClasses, data.frame(Name = "Agriculture:Annual", StateLabelXID = "Agriculture", StateLabelYID = "Annual", ID = 8))
stateClasses = addRow(stateClasses, data.frame(Name = "Agriculture:Perennial", StateLabelXID = "Agriculture", StateLabelYID = "Perennial", ID = 12))
stateClasses = addRow(stateClasses, data.frame(Name = "Shrubland:PostFire", StateLabelXID = "Shrubland", StateLabelYID = "PostFire", ID = 15)) # Post-fire (high severity) class
stateClasses = addRow(stateClasses, data.frame(Name = "Forest:Treated (Thinned)", StateLabelXID = "Forest", StateLabelYID = "Treated (Thinned)", ID = 61)) # Interventions - Thinning from below
stateClasses = addRow(stateClasses, data.frame(Name = "Forest:Treated (Prescribed)", StateLabelXID = "Forest", StateLabelYID = "Treated (Prescribed)", ID = 62)) # Interventions - Prescribed fire
stateClasses = addRow(stateClasses, data.frame(Name = "Forest:CFM", StateLabelXID = "Forest", StateLabelYID = "CFM", ID = 63)) # Interventions - Changes to Forest Management Class
stateClasses = addRow(stateClasses, data.frame(Name = "Agriculture:Agroforestry", StateLabelXID = "Agriculture", StateLabelYID = "Agroforestry", ID = 13)) # Interventions - Agroforestry
stateClasses = addRow(stateClasses, data.frame(Name = "Agriculture:Covercrop", StateLabelXID = "Agriculture", StateLabelYID = "Covercrop", ID = 14)) # Interventions - Covercrops
saveDatasheet(myProject, stateClasses, "STSim_StateClass", force = T, append = F)


#-----------------------------------------------------------------------------------
# Transition Project Definitions

# Transition Types
transitionTypes = datasheet(myProject, name = "STSim_TransitionType", empty = T, optional = T)
# Ag Change
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL CHANGE: Annual->Perennial", ID = "1"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL CHANGE: Perennial->Annual", ID = "2"))
# Agricultural Contraction
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL CONTRACTION: Annual->Forest", ID = "10"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL CONTRACTION: Annual->Grassland", ID = "12"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL CONTRACTION: Annual->Shrubland", ID = "13"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL CONTRACTION: Annual->Wetland", ID = "14"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL CONTRACTION: Perennial->Forest", ID = "15"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL CONTRACTION: Perennial->Grassland", ID = "17"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL CONTRACTION: Perennial->Shrubland", ID = "18"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL CONTRACTION: Perennial->Wetland", ID = "19"))
# Agricultural Expansion
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL EXPANSION: Forest->Annual", ID = "20"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL EXPANSION: Forest->Perennial", ID = "23"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL EXPANSION: Grassland->Annual", ID = "24"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL EXPANSION: Grassland->Perennial", ID = "25"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL EXPANSION: Shrubland->Annual", ID = "26"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL EXPANSION: Shrubland->Perennial", ID = "27"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL EXPANSION: Wetland->Annual", ID = "28"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "AGRICULTURAL EXPANSION: Wetland->Perennial", ID = "29"))
# Urbanization
transitionTypes = addRow(transitionTypes, data.frame(Name = "URBANIZATION: Annual->Developed", ID = "30"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "URBANIZATION: Forest->Developed", ID = "31"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "URBANIZATION: Grassland->Developed", ID = "33"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "URBANIZATION: Perennial->Developed", ID = "34"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "URBANIZATION: Shrubland->Developed", ID = "35"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "URBANIZATION: Wetland->Developed", ID = "36"))
# Wildfire and Disturbance
transitionTypes = addRow(transitionTypes, data.frame(Name = "FIRE: Forest High Severity", ID = "40"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "FIRE: Forest Medium Severity", ID = "41"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "FIRE: Forest Low Severity", ID = "42"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "FIRE: Grassland High Severity", ID = "43"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "FIRE: Grassland Medium Severity", ID = "44"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "FIRE: Grassland Low Severity", ID = "45"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "FIRE: Shrubland High Severity", ID = "46"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "FIRE: Shrubland Medium Severity", ID = "47"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "FIRE: Shrubland Low Severity", ID = "48"))
# Insect and Drought Mortality
transitionTypes = addRow(transitionTypes, data.frame(Name = "DROUGHT: High Severity", ID = "50"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "DROUGHT: Medium Severity", ID = "51"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "DROUGHT: Low Severity", ID = "52"))
# Management Actions
transitionTypes = addRow(transitionTypes, data.frame(Name = "MANAGEMENT: Forest Clearcut", ID = "60"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "MANAGEMENT: Forest Selection", ID = "61"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "MANAGEMENT: Orchard Removal", ID = "62"))
# Intervention Activities
transitionTypes = addRow(transitionTypes, data.frame(Name = "INTERVENTION: Reforestation", ID = "100")) # Only applied for areas that experience a type converison to shrubland post high severity fire
transitionTypes = addRow(transitionTypes, data.frame(Name = "INTERVENTION: Thinning From Below", ID = "101"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "INTERVENTION: Prescribed Fire", ID = "102"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "INTERVENTION: Woodland Restoration", ID = "103")) # focused on oak woodland restoration
transitionTypes = addRow(transitionTypes, data.frame(Name = "INTERVENTION: Agroforestry", ID = "104")) # Pathways added for both perennial and annual, need new NPP rates...
transitionTypes = addRow(transitionTypes, data.frame(Name = "INTERVENTION: Covercrop", ID = "105")) # Pathways added for both perennial and annual, change straw removal rates
transitionTypes = addRow(transitionTypes, data.frame(Name = "INTERVENTION: Riparian Restoration", ID = "106")) # Pathways added for both perennial and annual, change straw removal rates
transitionTypes = addRow(transitionTypes, data.frame(Name = "INTERVENTION: Wetland Restoration", ID = "107")) # Conversion of ag to wetland
transitionTypes = addRow(transitionTypes, data.frame(Name = "INTERVENTION: CFM", ID = "108")) # Conversion to alternative forest management class
# Successional Pathways
transitionTypes = addRow(transitionTypes, data.frame(Name = "SUCCESSION: Post Fire Recovery", ID = "120"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "SUCCESSION: Thinning From Below", ID = "121"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "SUCCESSION: Prescribed Fire", ID = "122")) # Transition from "Shrubland:PostFire" to "Forest" based on adjacency and recovery rates. Data from Thorne makes some cells "0" which can never recover to forest
transitionTypes = addRow(transitionTypes, data.frame(Name = "SUCCESSION: Permanent Shrub Conversion", ID = "123"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "SUCCESSION: From CFM", ID = "124")) # Conversion back from alternative forest management class
saveDatasheet(myProject, transitionTypes, "STSim_TransitionType", force = T, append = F)

#-----------------------------------------------------------------------------------
# Transition Groups
transitionGroups = datasheet(myProject, name = "STSim_TransitionGroup", empty = F, optional = T)
transitionGroups = addRow(transitionGroups, data.frame(Name = "AGRICULTURAL CHANGE"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "AGRICULTURAL EXPANSION"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "AGRICULTURAL CONTRACTION"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "URBANIZATION"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "FIRE"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "FIRE: Forest"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "FIRE: Grassland"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "FIRE: Shrubland"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "FIRE: High Severity"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "FIRE: Medium Severity"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "FIRE: Low Severity"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "DROUGHT"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "HARVEST"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "INTERVENTION"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "SUCCESSION"))
saveDatasheet(myProject, transitionGroups, "STSim_TransitionGroup", force = T, append = F)



#-----------------------------------------------------------------------------------
# Transition Types by Groups  - assign each Type to its Group
transitionTypebyGroup = datasheet(myProject, name = "STSim_TransitionTypeGroup", empty = T, optional = T)
# Ag Change
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL CHANGE: Annual->Perennial", TransitionGroupID = "AGRICULTURAL CHANGE"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL CHANGE: Perennial->Annual", TransitionGroupID = "AGRICULTURAL CHANGE"))
# Ag Contraction
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL CONTRACTION: Annual->Forest", TransitionGroupID = "AGRICULTURAL CONTRACTION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL CONTRACTION: Annual->Grassland", TransitionGroupID = "AGRICULTURAL CONTRACTION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL CONTRACTION: Annual->Shrubland", TransitionGroupID = "AGRICULTURAL CONTRACTION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL CONTRACTION: Annual->Wetland", TransitionGroupID = "AGRICULTURAL CONTRACTION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL CONTRACTION: Perennial->Forest", TransitionGroupID = "AGRICULTURAL CONTRACTION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL CONTRACTION: Perennial->Grassland", TransitionGroupID = "AGRICULTURAL CONTRACTION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL CONTRACTION: Perennial->Shrubland", TransitionGroupID = "AGRICULTURAL CONTRACTION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL CONTRACTION: Perennial->Wetland", TransitionGroupID = "AGRICULTURAL CONTRACTION"))
# Ag Expansion
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL EXPANSION: Forest->Annual", TransitionGroupID = "AGRICULTURAL EXPANSION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL EXPANSION: Grassland->Annual", TransitionGroupID = "AGRICULTURAL EXPANSION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL EXPANSION: Shrubland->Annual", TransitionGroupID = "AGRICULTURAL EXPANSION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL EXPANSION: Wetland->Annual", TransitionGroupID = "AGRICULTURAL EXPANSION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL EXPANSION: Forest->Perennial", TransitionGroupID = "AGRICULTURAL EXPANSION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL EXPANSION: Grassland->Perennial", TransitionGroupID = "AGRICULTURAL EXPANSION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL EXPANSION: Shrubland->Perennial", TransitionGroupID = "AGRICULTURAL EXPANSION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "AGRICULTURAL EXPANSION: Wetland->Perennial", TransitionGroupID = "AGRICULTURAL EXPANSION"))
# Urbanization
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "URBANIZATION: Annual->Developed", TransitionGroupID = "URBANIZATION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "URBANIZATION: Perennial->Developed", TransitionGroupID = "URBANIZATION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "URBANIZATION: Grassland->Developed", TransitionGroupID = "URBANIZATION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "URBANIZATION: Shrubland->Developed", TransitionGroupID = "URBANIZATION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "URBANIZATION: Wetland->Developed", TransitionGroupID = "URBANIZATION"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "URBANIZATION: Forest->Developed", TransitionGroupID = "URBANIZATION"))
# Fire
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Forest High Severity", TransitionGroupID = "FIRE"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Forest Medium Severity", TransitionGroupID = "FIRE"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Forest Low Severity", TransitionGroupID = "FIRE"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Grassland High Severity", TransitionGroupID = "FIRE"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Grassland Medium Severity", TransitionGroupID = "FIRE"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Grassland Low Severity", TransitionGroupID = "FIRE"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Shrubland High Severity", TransitionGroupID = "FIRE"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Shrubland Medium Severity", TransitionGroupID = "FIRE"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Shrubland Low Severity", TransitionGroupID = "FIRE"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Forest High Severity", TransitionGroupID = "FIRE: Forest"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Forest Medium Severity", TransitionGroupID = "FIRE: Forest"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Forest Low Severity", TransitionGroupID = "FIRE: Forest"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Grassland High Severity", TransitionGroupID = "FIRE: Grassland"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Grassland Medium Severity", TransitionGroupID = "FIRE: Grassland"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Grassland Low Severity", TransitionGroupID = "FIRE: Grassland"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Shrubland High Severity", TransitionGroupID = "FIRE: Shrubland"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Shrubland Medium Severity", TransitionGroupID = "FIRE: Shrubland"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Shrubland Low Severity", TransitionGroupID = "FIRE: Shrubland"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Forest High Severity", TransitionGroupID = "FIRE: High Severity"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Grassland High Severity", TransitionGroupID = "FIRE: High Severity"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Shrubland High Severity", TransitionGroupID = "FIRE: High Severity"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Forest Medium Severity", TransitionGroupID = "FIRE: Medium Severity"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Grassland Medium Severity", TransitionGroupID = "FIRE: Medium Severity"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Shrubland Medium Severity", TransitionGroupID = "FIRE: Medium Severity"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Forest Low Severity", TransitionGroupID = "FIRE: Low Severity"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Grassland Low Severity", TransitionGroupID = "FIRE: Low Severity"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "FIRE: Shrubland Low Severity", TransitionGroupID = "FIRE: Low Severity"))
# Insects
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "DROUGHT: High Severity", TransitionGroupID = "DROUGHT"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "DROUGHT: Medium Severity", TransitionGroupID = "DROUGHT"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "DROUGHT: Low Severity", TransitionGroupID = "DROUGHT"))
# Forest Harvest
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "MANAGEMENT: Forest Clearcut", TransitionGroupID = "HARVEST"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "MANAGEMENT: Forest Selection", TransitionGroupID = "HARVEST"))

saveDatasheet(myProject, transitionTypebyGroup, "STSim_TransitionTypeGroup", append = F)


#-----------------------------------------------------------------------------------
# Transition Simulation Group
transitionSimulationGroup = datasheet(myProject, name="STSim_TransitionSimulationGroup", empty = F, optional = T)
transitionSimulationGroup = addRow(transitionSimulationGroup, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION"))
transitionSimulationGroup = addRow(transitionSimulationGroup, data.frame(TransitionGroupID = "AGRICULTURAL EXPANSION"))
transitionSimulationGroup = addRow(transitionSimulationGroup, data.frame(TransitionGroupID = "URBANIZATION"))
transitionSimulationGroup = addRow(transitionSimulationGroup, data.frame(TransitionGroupID = "FIRE"))
saveDatasheet(myProject, transitionSimulationGroup, "STSim_TransitionSimulationGroup", force = T, append = F)

#-----------------------------------------------------------------------------------
# Age Project Definitions

# Ages are being turned off here due to increases in ssim output database - un-comment in order to turn on and re-run models 
#ageFrequency = 20
#ageMax = 500
#ageGroups = c(20, 40, 60, 80, 100, 120, 140, 160, 180, 200)
#saveDatasheet(myProject, data.frame(Frequency = ageFrequency, MaximumAge = ageMax), "STSim_AgeType", force = T)
#saveDatasheet(myProject, data.frame(MaximumAge = ageGroups), "STSim_AgeGroup", force = T)




#-----------------------------------------------------------------------------------
# Attributes Project Definitions

# Attribute Groups
attributeGroup = datasheet(myProject, name = "STSim_AttributeGroup", empty = T, optional = F)
attributeGroup = c("Adjacency", "Albedo", "Carbon Initial Conditions", "Carbon NPP", "Demographic", "Forest Age")
saveDatasheet(myProject, data.frame(Name = attributeGroup), "STSim_AttributeGroup", force = T, append = F)

# Attribute Types
attributeType = datasheet(myProject, name = "STSim_StateAttributeType", empty = T, optional = T)
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Agriculture", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Agroforestry", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Annual", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Covercrop", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Perennial", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Barren", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Developed", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Transportation", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Forest", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Forest Prescribed", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Forest Thinned", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Forest CFM", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Grassland", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Shrubland", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-ShrubPostFire", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Wetland", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Water", AttributeGroupID = "Adjacency", Units = "km2"))


attributeType = addRow(attributeType, data.frame(Name = "Albedo", AttributeGroupID = "Albedo", Units = "Percent"))
attributeType = addRow(attributeType, data.frame(Name = "Households", AttributeGroupID = "Demographic", Units = "Households"))
attributeType = addRow(attributeType, data.frame(Name = "Population", AttributeGroupID = "Demographic", Units = "Persons"))
attributeType = addRow(attributeType, data.frame(Name = "Initial Conditions: Living Biomass", AttributeGroupID = "Carbon Initial Conditions", Units = "kgC/m2"))
attributeType = addRow(attributeType, data.frame(Name = "Initial Conditions: Standing Deadwood", AttributeGroupID = "Carbon Initial Conditions", Units = "kgC/m2"))
attributeType = addRow(attributeType, data.frame(Name = "Initial Conditions: Down Deadwood", AttributeGroupID = "Carbon Initial Conditions", Units = "kgC/m2"))
attributeType = addRow(attributeType, data.frame(Name = "Initial Conditions: Litter", AttributeGroupID = "Carbon Initial Conditions", Units = "kgC/m2"))
attributeType = addRow(attributeType, data.frame(Name = "Initial Conditions: Soil", AttributeGroupID = "Carbon Initial Conditions", Units = "kgC/m2"))
attributeType = addRow(attributeType, data.frame(Name = "NPP", AttributeGroupID = "Carbon NPP", Units = "kgC/m2"))
saveDatasheet(myProject, attributeType, "STSim_StateAttributeType", force = T, append = F)





#-----------------------------------------------------------------------------------
# Distributions and External Variables Project Definitions

# Distributions
distributions = datasheet(myProject, name = "STime_DistributionType", empty = T, optional = T)
distributions = c("Historical Rate: Ag Contraction", "Historical Rate: Ag Expansion", "Historical Rate: Fire", "Historical Rate: Forest Clearcut", "Historical Rate: Forest Selection", "Historical Rate: Forest Harvest",
                  "Historical Rate: Urbanization", "Historical Rate: Drought High Severity", "Historical Rate: Drought Medium Severity", "Historical Rate: Drought Low Severity")
saveDatasheet(myProject, data.frame(Name = distributions), "STime_DistributionType", force = T, append = F)

# External Variables
externalVariables = datasheet(myProject, name = "STime_ExternalVariableType", empty = T, optional = T)
externalVariables = c("Historical Year: Ag Change", "Historical Year: Ag Contraction", "Historical Year: Ag Expansion", "Historical Year: All Change", "Historical Year: Fire",
                      "Historical Year: Forest Harvest", "Historical Year: Land Use Change", "Historical Year: Urbanization", "Historical Year: Drought")
saveDatasheet(myProject, data.frame(Name = externalVariables), "STime_ExternalVariableType", force = T, append = F)





#-----------------------------------------------------------------------------------
# Stock and Flow Project Definitions

# Stock Flow Terminology
sheetData = datasheet(myProject, name = "SF_Terminology", optional = T)
saveDatasheet(myProject, data.frame(StockUnits = "Kilotons"), "SF_Terminology", force = T)

# Stock Groups
stockGroup = datasheet(myProject, name = "SF_StockGroup", empty = T, optional = T)
stockGroup = c("Harvested Wood Products", "Total Deadwood", "DOM", "Total Ecosystem Carbon")
saveDatasheet(myProject, data.frame(Name = stockGroup), "SF_StockGroup", force = T, append = F)

# Stock Types
stockType = datasheet(myProject, name = "SF_StockType", empty = T, optional = T)
stockType = c("Aquatic", "Atmosphere", "Down Deadwood", "Grain", "HWP (Extracted)", "Litter", "Living Biomass", "Soil", "Standing Deadwood", "Straw")
saveDatasheet(myProject, data.frame(Name = stockType), "SF_StockType", force = T, append = F)

# Flow Groups
flowGroup = datasheet(myProject, name = "SF_FlowGroup", empty = T, optional = T)
flowGroup = c("Decay", "Decomposition", "Deadfall", "Emission", "Emission (biomass)", "Emission (grain)", "Emission (litter)", "Emission (soil)", "Emission (straw)", "Growth", "Harvest",
              "Harvest (grain)", "Harvest (straw)", "Leaching", "Litterfall", "Mortality", "Mortality (drought high)", "Mortality (drought medium)", "Mortality (drought low)", 
              "Net Biome Productivity (NBP)", "Net Ecosystem Productivity (NEP)", "Net Primary Productivity (NPP)")
saveDatasheet(myProject, data.frame(Name = flowGroup), "SF_FlowGroup", force = T, append = F)

# Flow Types
flowType = datasheet(myProject, name = "SF_FlowType", empty = T, optional = T)
flowType = c("Decay", "Decomposition", "Deadfall", "Emission", "Emission (biomass)", "Emission (grain)", "Emission (litter)", "Emission (soil)", "Emission (straw)", "Growth", "Harvest",
             "Harvest (grain)", "Harvest (straw)", "Leaching", "Litterfall", "Mortality", "Mortality (drought high)", "Mortality (drought medium)", "Mortality (drought low)")
saveDatasheet(myProject, data.frame(Name = flowType), "SF_FlowType", force = T, append = F)




# Display the internal names of all the scenario datasheets
scenarioSheetNames = datasheet(myScenario, summary = T)
scenarioSheetNames

