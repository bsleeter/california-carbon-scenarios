#-----------------------------------------------------------------------------------
# R Scripts used to build a LUCAS Model for the State of California
# Script 1 of 4
# Define SyncroSim project and create Project Definitions

#-----------------------------------------------------------------------------------
# Created by: Benjamin M. Sleeter
# U.S. Geological Survey, Western Geographic Science Center
# bsleeter@usgs.gov
# Date of creation: December 5, 2017

# -----------------------------------------------------------------------------------#
# Setup Model Library and Project
# -----------------------------------------------------------------------------------#
# Load packages-----------------------------------------------------------------------------------
# 
library(tidyverse)
library(raster)
library(rasterVis)
library(rsyncrosim)


# Set the Syncro Sim program directory-----------------------------------------------------------------------------------
programFolder = "C:/Program Files/SyncroSim" # Set this to location of SyncroSim installation

# Start a SyncroSim session
mySession = session(programFolder) # Start a session with SyncroSim

# Set the current working directory
setwd("D:/california-carbon-futures/build") # Check this is correct for your computer!
getwd() # Show the current working directory

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

# Create or open a new project
myProject = project(myLibrary, project = "ccf_v4") # Also creates a new project (if it doesn't exist already)
project(myLibrary, summary = TRUE)




# Edit the Project Properties -----------------------------------------------------------------------------------
# orresponds to the 'Project-Properties' menu in SyncroSim

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



# -----------------------------------------------------------------------------------#
# Create Project Definitions
# -----------------------------------------------------------------------------------#
# Strata Project Definitions -----------------------------------------------------------------------------------

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


# State Class Project Definitions-----------------------------------------------------------------------------------

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


# Transition Project Definitions-----------------------------------------------------------------------------------

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

# Transition Groups-----------------------------------------------------------------------------------
# 
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



# Transition Types by Groups-----------------------------------------------------------------------------------
# Assign each Type to its Group
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


# Transition Simulation Group-----------------------------------------------------------------------------------
# 
transitionSimulationGroup = datasheet(myProject, name="STSim_TransitionSimulationGroup", empty = F, optional = T)
transitionSimulationGroup = addRow(transitionSimulationGroup, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION"))
transitionSimulationGroup = addRow(transitionSimulationGroup, data.frame(TransitionGroupID = "AGRICULTURAL EXPANSION"))
transitionSimulationGroup = addRow(transitionSimulationGroup, data.frame(TransitionGroupID = "URBANIZATION"))
transitionSimulationGroup = addRow(transitionSimulationGroup, data.frame(TransitionGroupID = "FIRE"))
saveDatasheet(myProject, transitionSimulationGroup, "STSim_TransitionSimulationGroup", force = T, append = F)

# Age Project Definitions-----------------------------------------------------------------------------------
# 

# Ages are being turned off here due to increases in ssim output database - un-comment in order to turn on and re-run models 
#ageFrequency = 20
#ageMax = 500
#ageGroups = c(20, 40, 60, 80, 100, 120, 140, 160, 180, 200)
#saveDatasheet(myProject, data.frame(Frequency = ageFrequency, MaximumAge = ageMax), "STSim_AgeType", force = T)
#saveDatasheet(myProject, data.frame(MaximumAge = ageGroups), "STSim_AgeGroup", force = T)




# Attributes Project Definitions-----------------------------------------------------------------------------------
# 

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





# Distributions and External Variables Project Definitions-----------------------------------------------------------------------------------
# 

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





# Stock and Flow Project Definitions-----------------------------------------------------------------------------------
# 

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





# -----------------------------------------------------------------------------------#
# Create Sub Scenarios
# -----------------------------------------------------------------------------------#

# Run Control-----------------------------------------------------------------------------------
# 
runControl = scenario(myProject, "Run Control [100TS; 100MC]", overwrite = T)
sheetName = "STSim_RunControl"
sheetData = datasheet(myProject, sheetName, scenario = "Run Control [100TS; 1MC]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(MaximumIteration = 100, MinimumTimestep = 2001, MaximumTimestep = 2101, IsSpatial = T))
saveDatasheet(runControl, sheetData, sheetName, append = F)

runControl = scenario(myProject, "Run Control [100TS; 1MC]", overwrite = T)
sheetName = "STSim_RunControl"
sheetData = datasheet(myProject, sheetName, scenario = "Run Control [100TS; 1MC]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(MaximumIteration = 1, MinimumTimestep = 2001, MaximumTimestep = 2101, IsSpatial = T))
saveDatasheet(runControl, sheetData, sheetName, append = F)




# Pathway Diagrams-----------------------------------------------------------------------------------
# 
pathways = scenario(myProject, "Pathways", overwrite = F)

# States
sheetName = "STSim_DeterministicTransition"
sheetData = datasheet(myProject, sheetName, scenario = "Pathways", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Water:All", StateClassIDDest = "Water:All", Location = "B4"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Barren:All", StateClassIDDest = "Barren:All", Location = "C4"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "SnowIce:All", StateClassIDDest = "SnowIce:All", Location = "D4"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Wetland:All", StateClassIDDest = "Wetland:All", Location = "A2"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Grassland:All", Location = "B2"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Shrubland:All", Location = "C2"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", Location = "D2"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Thinned)", StateClassIDDest = "Forest:Treated (Thinned)", Location = "C3"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Prescribed)", StateClassIDDest = "Forest:Treated (Prescribed)", Location = "D3"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:All", StateClassIDDest = "Developed:All", Location = "A1"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:Transportation", StateClassIDDest = "Developed:Transportation", Location = "A4"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Agriculture:Annual", Location = "C1"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Agriculture:Perennial", Location = "D1"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Covercrop", StateClassIDDest = "Agriculture:Covercrop", Location = "E1"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Agroforestry", StateClassIDDest = "Agriculture:Agroforestry", Location = "F1"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:PostFire", StateClassIDDest = "Shrubland:PostFire", Location = "F3"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", Location = "B3"))

saveDatasheet(pathways, sheetData, sheetName, append = F)

# Probabilistic Transitions
sheetName = "STSim_Transition"
sheetData = datasheet(myProject, sheetName, scenario = "Pathways", optional = T, empty = T)
# Ag Change
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Agriculture:Perennial", TransitionTypeID = "AGRICULTURAL CHANGE: Annual->Perennial", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Agriculture:Annual", TransitionTypeID = "AGRICULTURAL CHANGE: Perennial->Annual", Probability = 1.0, AgeMax = 1, TSTMax = 1))
# Ag Contraction
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Grassland:All", TransitionTypeID = "AGRICULTURAL CONTRACTION: Annual->Grassland", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Shrubland:All", TransitionTypeID = "AGRICULTURAL CONTRACTION: Annual->Shrubland", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Forest:All", TransitionTypeID = "AGRICULTURAL CONTRACTION: Annual->Forest", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Wetland:All", TransitionTypeID = "AGRICULTURAL CONTRACTION: Annual->Wetland", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Grassland:All", TransitionTypeID = "AGRICULTURAL CONTRACTION: Perennial->Grassland", Probability = 1.0, AgeMax = 1, TSTMax = 1))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Shrubland:All", TransitionTypeID = "AGRICULTURAL CONTRACTION: Perennial->Shrubland", Probability = 1.0, AgeMax = 1, TSTMax = 1))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Forest:All", TransitionTypeID = "AGRICULTURAL CONTRACTION: Perennial->Forest", Probability = 1.0, AgeMax = 1, TSTMax = 1))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Wetland:All", TransitionTypeID = "AGRICULTURAL CONTRACTION: Perennial->Wetland", Probability = 1.0, AgeMax = 1, TSTMax = 1))
# Ag Expansion
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Agriculture:Annual", TransitionTypeID = "AGRICULTURAL EXPANSION: Grassland->Annual", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Agriculture:Annual", TransitionTypeID = "AGRICULTURAL EXPANSION: Shrubland->Annual", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Agriculture:Annual", TransitionTypeID = "AGRICULTURAL EXPANSION: Forest->Annual", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Wetland:All", StateClassIDDest = "Agriculture:Annual", TransitionTypeID = "AGRICULTURAL EXPANSION: Wetland->Annual", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Agriculture:Perennial", TransitionTypeID = "AGRICULTURAL EXPANSION: Grassland->Perennial", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Agriculture:Perennial", TransitionTypeID = "AGRICULTURAL EXPANSION: Shrubland->Perennial", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Agriculture:Perennial", TransitionTypeID = "AGRICULTURAL EXPANSION: Forest->Perennial", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Wetland:All", StateClassIDDest = "Agriculture:Perennial", TransitionTypeID = "AGRICULTURAL EXPANSION: Wetland->Perennial", Probability = 1.0))
# Urbanization
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Developed:All", TransitionTypeID = "URBANIZATION: Grassland->Developed", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Developed:All", TransitionTypeID = "URBANIZATION: Shrubland->Developed", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Developed:All", TransitionTypeID = "URBANIZATION: Forest->Developed", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Wetland:All", StateClassIDDest = "Developed:All", TransitionTypeID = "URBANIZATION: Wetland->Developed", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Developed:All", TransitionTypeID = "URBANIZATION: Annual->Developed", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Developed:All", TransitionTypeID = "URBANIZATION: Perennial->Developed", Probability = 1.0))
# Fire
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Grassland:All", TransitionTypeID = "FIRE: Grassland High Severity", Probability = 1.0, Proportion = 0.1016, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Grassland:All", TransitionTypeID = "FIRE: Grassland Medium Severity", Probability = 1.0, Proportion = 0.2285, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Grassland:All", TransitionTypeID = "FIRE: Grassland Low Severity", Probability = 1.0, Proportion = 0.6699, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Shrubland:All", TransitionTypeID = "FIRE: Shrubland High Severity", Probability = 1.0, Proportion = 0.1016, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Shrubland:All", TransitionTypeID = "FIRE: Shrubland Medium Severity", Probability = 1.0, Proportion = 0.2285, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Shrubland:All", TransitionTypeID = "FIRE: Shrubland Low Severity", Probability = 1.0, Proportion = 0.6699, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "FIRE: Forest High Severity", Probability = 1.0, Proportion = 0.1016, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "FIRE: Forest Medium Severity", Probability = 1.0, Proportion = 0.2285, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "FIRE: Forest Low Severity", Probability = 1.0, Proportion = 0.6699, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Thinned)", StateClassIDDest = "Forest:Treated (Thinned)", TransitionTypeID = "FIRE: Forest Medium Severity", Probability = 1.0, Proportion = 0.2793, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Thinned)", StateClassIDDest = "Forest:Treated (Thinned)", TransitionTypeID = "FIRE: Forest Low Severity", Probability = 1.0, Proportion = 0.7207, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Prescribed)", StateClassIDDest = "Forest:Treated (Prescribed)", TransitionTypeID = "FIRE: Forest Medium Severity", Probability = 1.0, Proportion = 0.2793, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Prescribed)", StateClassIDDest = "Forest:Treated (Prescribed)", TransitionTypeID = "FIRE: Forest Low Severity", Probability = 1.0, Proportion = 0.7207, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Shrubland:PostFire", TransitionTypeID = "FIRE: Forest High Severity", Probability = 1.0, Proportion = 0.1016, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", TransitionTypeID = "FIRE: Forest Medium Severity", Probability = 1.0, Proportion = 0.2285, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", TransitionTypeID = "FIRE: Forest Low Severity", Probability = 1.0, Proportion = 0.6699, AgeReset = F))
# Insects
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "DROUGHT: High Severity", Probability = 1.0, AgeReset = T, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "DROUGHT: Medium Severity", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "DROUGHT: Low Severity", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:All", TransitionTypeID = "DROUGHT: High Severity", Probability = 1.0, AgeReset = T, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", TransitionTypeID = "DROUGHT: Medium Severity", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", TransitionTypeID = "DROUGHT: Low Severity", Probability = 1.0, AgeReset = F, AgeMin = 20))
# Harvest
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "MANAGEMENT: Forest Clearcut", Probability = 1.0, AgeReset = T, AgeMin = 40))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "MANAGEMENT: Forest Selection", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", TransitionTypeID = "MANAGEMENT: Forest Clearcut", Probability = 1.0, AgeReset = T, AgeMin = 50, AgeMax = 60))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", TransitionTypeID = "MANAGEMENT: Forest Selection", Probability = 1.0, AgeReset = F, AgeMin = 20))
# Management
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Agriculture:Perennial", TransitionTypeID = "MANAGEMENT: Orchard Removal", Probability = 1.0, AgeReset = T, AgeMin = 20))
# Intervention
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:PostFire", StateClassIDDest = "Forest:All", TransitionTypeID = "INTERVENTION: Reforestation", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:Treated (Thinned)", TransitionTypeID = "INTERVENTION: Thinning From Below", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Thinned)", StateClassIDDest = "Forest:Treated (Prescribed)", TransitionTypeID = "INTERVENTION: Prescribed Fire", Probability = 1.0, AgeReset = F, TSTMin = 5, TSTMax = 10))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Forest:All", TransitionTypeID = "INTERVENTION: Woodland Restoration", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Agriculture:Agroforestry", TransitionTypeID = "INTERVENTION: Agroforestry", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Agriculture:Covercrop", TransitionTypeID = "INTERVENTION: Covercrop", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Forest:All", TransitionTypeID = "INTERVENTION: Riparian Restoration", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Forest:All", TransitionTypeID = "INTERVENTION: Riparian Restoration", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Forest:All", TransitionTypeID = "INTERVENTION: Riparian Restoration", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Wetland:All", TransitionTypeID = "INTERVENTION: Wetland Restoration", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:CFM", TransitionTypeID = "INTERVENTION: CFM", Probability = 1.0, AgeReset = F, AgeMin = 20))

# Succession
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:PostFire", StateClassIDDest = "Forest:All", TransitionTypeID = "SUCCESSION: Post Fire Recovery", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Thinned)", StateClassIDDest = "Forest:All", TransitionTypeID = "SUCCESSION: Thinning From Below", Probability = 1.0, AgeReset = F, TSTMin = 10))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Prescribed)", StateClassIDDest = "Forest:All", TransitionTypeID = "SUCCESSION: Prescribed Fire", Probability = 1.0, AgeReset = F, TSTMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:PostFire", StateClassIDDest = "Shrubland:All", TransitionTypeID = "SUCCESSION: Permanent Shrub Conversion", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:All", TransitionTypeID = "SUCCESSION: From CFM", Probability = 1.0, AgeReset = F, AgeMin = 20))

saveDatasheet(pathways, sheetData, sheetName, append = F)






# Initial Conditions-----------------------------------------------------------------------------------
# 
initialConditions = scenario(myProject, "Initial Conditions", overwrite = F)

# Check rasters (for initial conditions)
rPrimaryStratum = raster("R Inputs/Initial Conditions/new/IC_Ecoregions_1km.tif")
rSecondaryStratum = raster("R Inputs/Initial Conditions/new/IC_Counties_1km.tif")
rSclass = raster("R Inputs/Initial Conditions/new/IC_StateClass_1km.tif")
rAge = raster("R Inputs/Initial Conditions/new/IC_Age_1km.tif")
rOwnership = raster("R Inputs/Initial Conditions/new/IC_Ownership_1km.tif")

crs = "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"

crs(rPrimaryStratum) = crs
crs(rSecondaryStratum) = crs
crs(rSclass) = crs
crs(rAge) = crs
crs(rOwnership)

writeRaster(rPrimaryStratum, "R Inputs/Initial Conditions/IC_Ecoregions_1km.tif", format = "GTiff", overwrite = T, dataType = "INT1U")
writeRaster(rSecondaryStratum, "R Inputs/Initial Conditions/IC_Counties_1km.tif", format = "GTiff", overwrite = T, dataType = "INT2U")
writeRaster(rSclass, "R Inputs/Initial Conditions/IC_StateClass_1km.tif", format = "GTiff", overwrite = T, dataType = "INT1U")
writeRaster(rAge, "R Inputs/Initial Conditions/IC_Age_1km.tif", format = "GTiff", overwrite = T, dataType = "INT2U")
writeRaster(rOwnership, "R Inputs/Initial Conditions/IC_Ownership_1km.tif", format = "GTiff", overwrite = T, dataType = "INT1U")


# Set Spatial initial conditions
initialConditions = scenario(myProject, "Initial Conditions", overwrite = F)
sheetName = "STSim_InitialConditionsSpatial"
names(datasheet(myProject, name = sheetName, scenario = "Initial Conditions"))
sheetData = data.frame(StratumFileName = "R Inputs/Initial Conditions/IC_Ecoregions_1km.tif",
                       SecondaryStratumFileName = "R Inputs/Initial Conditions/IC_Counties_1km.tif",
                       TertiaryStratumFileName = "R Inputs/Initial Conditions/IC_Ownership_1km.tif",
                       StateClassFileName = "R Inputs/Initial Conditions/IC_StateClass_1km.tif",
                       AgeFileName = "R Inputs/Initial Conditions/IC_Age_1km.tif")
saveDatasheet(initialConditions, sheetData, sheetName, append = F)





# Output Options-----------------------------------------------------------------------------------
# 
outputOptions = scenario(myProject, "Output Options", overwrite = F)

sheetName = "STSim_OutputOptions"
sheetData = datasheet(myProject, name = sheetName, scenario = "Output Options", optional = T, empty = F)
sheetData = data.frame(SummaryOutputSC = T, SummaryOutputSCTimesteps = 1,
                       SummaryOutputTR = T, SummaryOutputTRTimesteps = 1,
                       SummaryOutputTRSC = T, SummaryOutputTRSCTimesteps = 1,
                       SummaryOutputSA = T, SummaryOutputSATimesteps = 1,
                       SummaryOutputTA = F, SummaryOutputTATimesteps = 100,
                       SummaryOutputOmitSS = T,
                       SummaryOutputOmitTS = T, 
                       RasterOutputSC = T, RasterOutputSCTimesteps = 10,
                       RasterOutputTR = F, RasterOutputTRTimesteps = 100,
                       RasterOutputAge = F, RasterOutputAgeTimesteps = 10,
                       RasterOutputTST = F, RasterOutputTSTTimesteps = 100,
                       RasterOutputST = F, RasterOutputSTTimesteps = 100,
                       RasterOutputSA = F, RasterOutputSATimesteps = 100,
                       RasterOutputTA = F, RasterOutputTATimesteps = 100,
                       RasterOutputAATP = T, RasterOutputAATPTimesteps = 10)
saveDatasheet(outputOptions, sheetData, sheetName, append = F)






# Transition Multipliers-----------------------------------------------------------------------------------
# Transition Multipliers for Control Scenario
transitionMultipliers = scenario(myProject, "Transition Multipliers", overwrite = F)

sheetName = "STSim_TransitionMultiplierValue"

# Base model parameters (fixed assumptions)
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Multipliers", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "AGRICULTURAL CHANGE: Perennial->Annual [Type]", Amount = 0.05, DistributionType = "Uniform", DistributionFrequencyID = "Iteration and Timestep", DistributionMin = 0.025, DistributionMax = 0.075))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "MANAGEMENT: Orchard Removal [Type]", Amount = 0.0589, DistributionType = "Uniform", DistributionFrequencyID = "Iteration and Timestep", DistributionMin = 0.0228, DistributionMax = 0.095))

# Interventions (turn on/off based on scenario)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "INTERVENTION: Agroforestry [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "INTERVENTION: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "INTERVENTION: Covercrop [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "INTERVENTION: Prescribed Fire [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "INTERVENTION: Reforestation [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "INTERVENTION: Riparian Restoration [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "INTERVENTION: Thinning From Below [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "INTERVENTION: Wetland Restoration [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "INTERVENTION: Woodland Restoration [Type]", Amount = 0.0))

# Succession (fixed assumptions)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "SUCCESSION: From CFM [Type]", Amount = 0.01))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "SUCCESSION: Permanent Shrub Conversion [Type]", Amount = 1.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "SUCCESSION: Post Fire Recovery [Type]", Amount = 0.027))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "SUCCESSION: Prescribed Fire [Type]", Amount = 1.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "SUCCESSION: Thinning From Below [Type]", Amount = 1.0))

saveDatasheet(transitionMultipliers, sheetData, sheetName, append = F)





# Transition Size Distribution-----------------------------------------------------------------------------------
# Transition Size Distribution (constant across all scenarios)
# Calculated based on fire perimeters from the California fire database located at http://.....

transitionSizeDistribution = scenario(myProject, "Transition Size Distribution", overwrite = F)

sheetName = "STSim_TransitionSizeDistribution"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Size Distribution", optional = T, empty = F)
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "FIRE", MaximumArea = 1.0, RelativeAmount = 0.7047))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "FIRE", MaximumArea = 5, RelativeAmount = 0.1647))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "FIRE", MaximumArea = 10.0, RelativeAmount = 0.0418))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "FIRE", MaximumArea = 20.0, RelativeAmount = 0.0288))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "FIRE", MaximumArea = 50.0, RelativeAmount = 0.0257))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "FIRE", MaximumArea = 100.0, RelativeAmount = 0.0163))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "FIRE", MaximumArea = 200.0, RelativeAmount = 0.0104))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "FIRE", MaximumArea = 500.0, RelativeAmount = 0.0048))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "FIRE", MaximumArea = 2500.0, RelativeAmount = 0.0028))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Low Severity [Type]", MaximumArea = 1, RelativeAmount = 0.9420))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Low Severity [Type]", MaximumArea = 5, RelativeAmount = 0.0480))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Low Severity [Type]", MaximumArea = 10, RelativeAmount = 0.0065))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Low Severity [Type]", MaximumArea = 20, RelativeAmount = 0.0025))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Low Severity [Type]", MaximumArea = 50, RelativeAmount = 0.0008))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Low Severity [Type]", MaximumArea = 100, RelativeAmount = 0.0001))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Low Severity [Type]", MaximumArea = 200, RelativeAmount = 0.0001))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Medium Severity [Type]", MaximumArea = 1, RelativeAmount = 0.9162))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Medium Severity [Type]", MaximumArea = 5, RelativeAmount = 0.0631))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Medium Severity [Type]", MaximumArea = 10, RelativeAmount = 0.0132))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Medium Severity [Type]", MaximumArea = 20, RelativeAmount = 0.0051))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Medium Severity [Type]", MaximumArea = 50, RelativeAmount = 0.0021))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Medium Severity [Type]", MaximumArea = 100, RelativeAmount = 0.0002))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: Medium Severity [Type]", MaximumArea = 200, RelativeAmount = 0.0001))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: High Severity [Type]", MaximumArea = 1, RelativeAmount = 0.8424))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: High Severity [Type]", MaximumArea = 5, RelativeAmount = 0.1233))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: High Severity [Type]", MaximumArea = 10, RelativeAmount = 0.0211))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: High Severity [Type]", MaximumArea = 20, RelativeAmount = 0.0095))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: High Severity [Type]", MaximumArea = 50, RelativeAmount = 0.0035))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: High Severity [Type]", MaximumArea = 100, RelativeAmount = 0.0002))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "DROUGHT: High Severity [Type]", MaximumArea = 200, RelativeAmount = 0.0000))
saveDatasheet(transitionSizeDistribution, sheetData, sheetName, append = F)





# Time Since Transition-----------------------------------------------------------------------------------
# 
# Time Since Transition
tst = scenario(myProject, "Time Since Transition", overwrite = T)

# Time Since Transition Groups
sheetName = "STSim_TimeSinceTransitionGroup"
sheetData = datasheet(myProject, name = sheetName, scenario = "Time Since Transition", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "AGRICULTURAL CHANGE: Perennial->Annual", TransitionGroupID = "MANAGEMENT: Orchard Removal [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "AGRICULTURAL CONTRACTION: Perennial->Forest", TransitionGroupID = "MANAGEMENT: Orchard Removal [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "AGRICULTURAL CONTRACTION: Perennial->Grassland", TransitionGroupID = "MANAGEMENT: Orchard Removal [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "AGRICULTURAL CONTRACTION: Perennial->Shrubland", TransitionGroupID = "MANAGEMENT: Orchard Removal [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "AGRICULTURAL CONTRACTION: Perennial->Wetland", TransitionGroupID = "MANAGEMENT: Orchard Removal [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "INTERVENTION: Prescribed Fire", TransitionGroupID = "INTERVENTION: Thinning From Below [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "SUCCESSION: Thinning From Below", TransitionGroupID = "INTERVENTION: Thinning From Below [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "SUCCESSION: Prescribed Fire", TransitionGroupID = "INTERVENTION: Prescribed Fire [Type]"))

saveDatasheet(tst, sheetData, sheetName, append = F)

# Time Since Transition Randomize
sheetName = "STSim_TimeSinceTransitionRandomize"
sheetData = datasheet(myProject, name = sheetName, scenario = "Time Since Transition", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "MANAGEMENT: Orchard Removal [Type]", StateClassID = "Agriculture:Perennial", MinInitialTST = 1, MaxInitialTST = 5))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "INTERVENTION: Thinning From Below [Type]", StateClassID = "Forest:All", MinInitialTST = 5, MaxInitialTST = 10))

saveDatasheet(tst, sheetData, sheetName, append = F)




# Adjacency Multipliers-----------------------------------------------------------------------------------
# 
adjacency = scenario(myProject, "Adjacency Multipliers", overwrite = F)

# Adjacency Settings
radius = 1500
frequency = 5
sheetName = "STSim_TransitionAdjacencySetting"
sheetData = datasheet(myProject, name = sheetName, scenario = "Adjacency Multipliers", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CHANGE: Perennial->Annual [Type]", StateAttributeTypeID = "ADJ-Annual", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CHANGE: Annual->Perennial [Type]", StateAttributeTypeID = "ADJ-Perennial", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Annual->Forest [Type]", StateAttributeTypeID = "ADJ-Forest", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Perennial->Forest [Type]", StateAttributeTypeID = "ADJ-Forest", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Annual->Grassland [Type]", StateAttributeTypeID = "ADJ-Grassland", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Perennial->Grassland [Type]", StateAttributeTypeID = "ADJ-Grassland", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Annual->Shrubland [Type]", StateAttributeTypeID = "ADJ-Shrubland", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Perennial->Shrubland [Type]", StateAttributeTypeID = "ADJ-Shrubland", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Annual->Wetland [Type]", StateAttributeTypeID = "ADJ-Wetland", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Perennial->Wetland [Type]", StateAttributeTypeID = "ADJ-Wetland", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL EXPANSION", StateAttributeTypeID = "ADJ-Agriculture", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "URBANIZATION", StateAttributeTypeID = "ADJ-Developed", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "SUCCESSION: Post Fire Recovery [Type]", StateAttributeTypeID = "ADJ-Forest", NeighborhoodRadius = radius, UpdateFrequency = frequency)) # Need to update radius and frequency to represent rate of regeneration
saveDatasheet(adjacency, sheetData, sheetName, append = F)

# Adjacency Transition Multipliers
minValue = 0.0
minAmount = 0.0
maxValue = 0.88
maxAmount = 1.0
sheetName = "STSim_TransitionAdjacencyMultiplier"
sheetData = datasheet(myProject, name = sheetName, scenario = "Adjacency Multipliers", optional = F, empty = T)
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CHANGE: Annual->Perennial [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CHANGE: Annual->Perennial [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CHANGE: Perennial->Annual [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CHANGE: Perennial->Annual [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Annual->Forest [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Annual->Forest [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Annual->Grassland [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Annual->Grassland [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Annual->Shrubland [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Annual->Shrubland [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Annual->Wetland [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Annual->Wetland [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Perennial->Forest [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Perennial->Forest [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Perennial->Grassland [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Perennial->Grassland [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Perennial->Shrubland [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Perennial->Shrubland [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Perennial->Wetland [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL CONTRACTION: Perennial->Wetland [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL EXPANSION", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "AGRICULTURAL EXPANSION", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "URBANIZATION", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "URBANIZATION", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "SUCCESSION: Post Fire Recovery [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "SUCCESSION: Post Fire Recovery [Type]", AttributeValue = maxValue, Amount = maxAmount))
saveDatasheet(adjacency, sheetData, sheetName, append = F)





# State Attributes-----------------------------------------------------------------------------------
# 
stateAttributes = scenario(myProject, "State Attributes", overwrite = F)

attributesAdjacency = read.csv("R Inputs/Attributes/Attributes-adjacency.csv", header = T)
attributesAlbedo = read.csv("R Inputs/Attributes/Attributes-albedo.csv", header = T)
attributesCarbon1 = read.csv("R Inputs/Attributes/Attributes-carbon.csv", header = T)
attributesCarbon2 = read.csv("R Inputs/Attributes/Attributes-carbon-prescribed.csv", header = T)
attributesCarbon3 = read.csv("R Inputs/Attributes/Attributes-carbon-thinning.csv", header = T)
attributesCarbon4 = read.csv("R Inputs/Attributes/Attributes-carbon-shrubPostFire.csv", header = T)
attributesNpp = read.csv("R Inputs/Attributes/Attributes-npp.csv", header = T)
attributesPopulation = read.csv("R Inputs/Attributes/Attributes-population.csv", header = T)
attributes = rbind(attributesAdjacency, attributesAlbedo, attributesCarbon1, attributesCarbon2, attributesCarbon3, attributesCarbon4, attributesNpp, attributesPopulation)
head(attributes)

sheetName = "STSim_StateAttributeValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "State Attributes", optional = T, empty = T)
sheetData = data.frame(Iteration = attributes$Iteration,
                       Timestep = attributes$Timestep,
                       StratumID = attributes$StratumID,
                       SecondaryStratumID = attributes$SecondaryStratumID,
                       TertiaryStratumID = attributes$TertiaryStratumID,
                       StateClassID = attributes$StateClassID,
                       StateAttributeTypeID = attributes$StateAttributeTypeID,
                       AgeMin = attributes$AgeMin,
                       AgeMax = attributes$AgeMax,
                       Value = attributes$Value)
saveDatasheet(stateAttributes, sheetData, sheetName, append = F)







# Distributions-----------------------------------------------------------------------------------
# 
# Land use changes calculated based historical data from California Farmland Mapping and Monitoring Program located at http://.....
# Forest harvest calculated based historical data from Landfire located at http://.....
# Wildfire probabilities calculated from California Fire Perimeters database located at http://.....
# Land use projections based on Sleeter et al., Earth's Future, DOI:.....
# All values assumed to be +/-30%

distributions = scenario(myProject, "Historical Distributions", overwrite = F)

distributionLandUse = read.csv("R Inputs/Distributions/Distribution-land-use.csv", header = T)
distributionFire = read.csv("R Inputs/Distributions/Distribution-fire.csv", header = T)
distributionDrought = read.csv("R Inputs/Distributions/Distribution-drought.csv", header = T)
distributionHarvest = read.csv("R Inputs/Distributions/Distribution-harvest.csv", header = T)
distributionData = rbind(distributionLandUse, distributionFire, distributionDrought, distributionHarvest)
sheetName = "STSim_DistributionValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "Historical Distributions", optional = T, empty = T)
sheetData = data.frame(StratumID = distributionData$StratumID,
                       SecondaryStratumID = distributionData$SecondaryStratumID,
                       DistributionTypeID = distributionData$DistributionTypeID,
                       ExternalVariableTypeID = distributionData$ExternalVariableTypeID,
                       ExternalVariableMin = distributionData$ExternalVariableMin,
                       ExternalVariableMax = distributionData$ExternalVariableMax,
                       Value = distributionData$Value,
                       ValueDistributionFrequency = distributionData$ValueDistributionFrequency,
                       ValueDistributionSD = distributionData$ValueDistributionSD)
tail(sheetData)
saveDatasheet(distributions, sheetData, sheetName, append = T)




# External Variables-----------------------------------------------------------------------------------
# External Variables (Low Scenarios)
externalVariablesLow = scenario(myProject, "External Variables [Low]", overwrite = F)

sheetName = "STime_ExternalVariableValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "External Variables [Low]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2003, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2003))
sheetData = addRow(sheetData, data.frame(Timestep = 2004, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2004))
sheetData = addRow(sheetData, data.frame(Timestep = 2005, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2005))
sheetData = addRow(sheetData, data.frame(Timestep = 2006, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2006))
sheetData = addRow(sheetData, data.frame(Timestep = 2007, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2007))
sheetData = addRow(sheetData, data.frame(Timestep = 2008, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2008))
sheetData = addRow(sheetData, data.frame(Timestep = 2009, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2009))
sheetData = addRow(sheetData, data.frame(Timestep = 2010, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2010))
sheetData = addRow(sheetData, data.frame(Timestep = 2011, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2011))
sheetData = addRow(sheetData, data.frame(Timestep = 2012, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2012))
sheetData = addRow(sheetData, data.frame(Timestep = 2013, ExternalVariableTypeID = "Historical Year: Land Use Change", DistributionTypeID = "Uniform Integer", DistributionFrequency = "Iteration and Timestep", DistributionMin = 1993, DistributionMax = 1996))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2003, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2003))
sheetData = addRow(sheetData, data.frame(Timestep = 2004, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2004))
sheetData = addRow(sheetData, data.frame(Timestep = 2005, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2005))
sheetData = addRow(sheetData, data.frame(Timestep = 2006, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2006))
sheetData = addRow(sheetData, data.frame(Timestep = 2007, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2007))
sheetData = addRow(sheetData, data.frame(Timestep = 2008, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2008))
sheetData = addRow(sheetData, data.frame(Timestep = 2009, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2009))
sheetData = addRow(sheetData, data.frame(Timestep = 2010, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2010))
sheetData = addRow(sheetData, data.frame(Timestep = 2013, ExternalVariableTypeID = "Historical Year: Forest Harvest", DistributionTypeID = "Uniform Integer", DistributionFrequency = "Iteration and Timestep", DistributionMin = 2010, DistributionMax = 2014))
saveDatasheet(externalVariablesLow, sheetData, sheetName, append = F)

# External Variables (Medium and BAU Scenarios)
externalVariablesMed = scenario(myProject, "External Variables [Medium/BAU]", overwrite = F)

sheetName = "STime_ExternalVariableValue"
sheetData = datasheet(myProject, sheetName, scenario = "External Variables [Medium/BAU]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2003, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2003))
sheetData = addRow(sheetData, data.frame(Timestep = 2004, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2004))
sheetData = addRow(sheetData, data.frame(Timestep = 2005, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2005))
sheetData = addRow(sheetData, data.frame(Timestep = 2006, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2006))
sheetData = addRow(sheetData, data.frame(Timestep = 2007, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2007))
sheetData = addRow(sheetData, data.frame(Timestep = 2008, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2008))
sheetData = addRow(sheetData, data.frame(Timestep = 2009, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2009))
sheetData = addRow(sheetData, data.frame(Timestep = 2010, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2010))
sheetData = addRow(sheetData, data.frame(Timestep = 2011, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2011))
sheetData = addRow(sheetData, data.frame(Timestep = 2012, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2012))
sheetData = addRow(sheetData, data.frame(Timestep = 2013, ExternalVariableTypeID = "Historical Year: Land Use Change", DistributionTypeID = "Uniform Integer", DistributionFrequency = "Iteration and Timestep", DistributionMin = 1993, DistributionMax = 2012))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2003, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2003))
sheetData = addRow(sheetData, data.frame(Timestep = 2004, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2004))
sheetData = addRow(sheetData, data.frame(Timestep = 2005, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2005))
sheetData = addRow(sheetData, data.frame(Timestep = 2006, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2006))
sheetData = addRow(sheetData, data.frame(Timestep = 2007, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2007))
sheetData = addRow(sheetData, data.frame(Timestep = 2008, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2008))
sheetData = addRow(sheetData, data.frame(Timestep = 2009, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2009))
sheetData = addRow(sheetData, data.frame(Timestep = 2010, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2010))
sheetData = addRow(sheetData, data.frame(Timestep = 2013, ExternalVariableTypeID = "Historical Year: Forest Harvest", DistributionTypeID = "Uniform Integer", DistributionFrequency = "Iteration and Timestep", DistributionMin = 1999, DistributionMax = 2014))
saveDatasheet(externalVariablesMed, sheetData, sheetName, append = F)

# External Variables (High Scenarios)
externalVariablesHigh = scenario(myProject, "External Variables [High]", overwrite = F)

sheetName = "STime_ExternalVariableValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "External Variables [High]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2003, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2003))
sheetData = addRow(sheetData, data.frame(Timestep = 2004, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2004))
sheetData = addRow(sheetData, data.frame(Timestep = 2005, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2005))
sheetData = addRow(sheetData, data.frame(Timestep = 2006, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2006))
sheetData = addRow(sheetData, data.frame(Timestep = 2007, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2007))
sheetData = addRow(sheetData, data.frame(Timestep = 2008, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2008))
sheetData = addRow(sheetData, data.frame(Timestep = 2009, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2009))
sheetData = addRow(sheetData, data.frame(Timestep = 2010, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2010))
sheetData = addRow(sheetData, data.frame(Timestep = 2011, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2011))
sheetData = addRow(sheetData, data.frame(Timestep = 2012, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2012))
sheetData = addRow(sheetData, data.frame(Timestep = 2013, ExternalVariableTypeID = "Historical Year: Land Use Change", DistributionTypeID = "Uniform Integer", DistributionFrequency = "Iteration and Timestep", DistributionMin = 1997, DistributionMax = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2003, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2003))
sheetData = addRow(sheetData, data.frame(Timestep = 2004, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2004))
sheetData = addRow(sheetData, data.frame(Timestep = 2005, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2005))
sheetData = addRow(sheetData, data.frame(Timestep = 2006, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2006))
sheetData = addRow(sheetData, data.frame(Timestep = 2007, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2007))
sheetData = addRow(sheetData, data.frame(Timestep = 2008, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2008))
sheetData = addRow(sheetData, data.frame(Timestep = 2009, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2009))
sheetData = addRow(sheetData, data.frame(Timestep = 2010, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2010))
sheetData = addRow(sheetData, data.frame(Timestep = 2013, ExternalVariableTypeID = "Historical Year: Forest Harvest", DistributionTypeID = "Uniform Integer", DistributionFrequency = "Iteration and Timestep", DistributionMin = 2002, DistributionMax = 2009))
saveDatasheet(externalVariablesHigh, sheetData, sheetName, append = F)





# Stocks Diagram-----------------------------------------------------------------------------------

flowPathways = scenario(myProject, "SF Flow Pathways", overwrite = F)

sheetName = "SF_FlowPathwayDiagram"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Flow Pathways", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(StockTypeID = "Aquatic", Location = "C4"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Atmosphere", Location = "B1"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Down Deadwood", Location = "C3"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Grain", Location = "A2"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "HWP (Extracted)", Location = "A1"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Litter", Location = "B3"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Living Biomass", Location = "B2"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Soil", Location = "B4"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Standing Deadwood", Location = "C2"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Straw", Location = "A3"))
saveDatasheet(flowPathways, sheetData, sheetName, append = F)

# Flow Pathways-----------------------------------------------------------------------------------
flowPathwaysData = read.csv("R Inputs/Flows/Flow-Pathways.csv", header = T)

sheetName = "SF_FlowPathway"
sheetData = datasheet(myProject, sheetName, scenario = "SF Flow Pathways", optional = T, empty = T)
sheetData = data.frame(Iteration = flowPathwaysData$Iteration,
                       Timestep = flowPathwaysData$Timestep,
                       FromStratumID = flowPathwaysData$FromStratumID,
                       FromStateClassID = flowPathwaysData$FromStateClassID,
                       FromAgeMin = flowPathwaysData$FromAgeMin,
                       FromStockTypeID = flowPathwaysData$FromStockTypeID,
                       ToStratumID = flowPathwaysData$ToStratumID,
                       ToStateClassID = flowPathwaysData$ToStateClassID,
                       ToAgeMin = flowPathwaysData$ToAgeMin,
                       ToStockTypeID = flowPathwaysData$ToStockTypeID,
                       TransitionGroupID = flowPathwaysData$TransitionGroupID,
                       StateAttributeTypeID = flowPathwaysData$StateAttributeTypeID,
                       FlowTypeID = flowPathwaysData$FlowTypeID,
                       Multiplier = flowPathwaysData$Multiplier)
saveDatasheet(flowPathways, sheetData, sheetName, append = F)



# Initial Stocks-----------------------------------------------------------------------------------
# 

isBiomass = raster("R Inputs/Initial Stocks/new/IS_LivingBiomass_1km.tif")
isDownDead = raster("R Inputs/Initial Stocks/new/IS_DownDeadwood_1km.tif")
isLitter = raster("R Inputs/Initial Stocks/new/IS_Litter_1km.tif")
isStandDead = raster("R Inputs/Initial Stocks/new/IS_StandingDeadwood_1km.tif")
isSoil = raster("R Inputs/Initial Stocks/new/IS_Soil_1km.tif")

crs = "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"
crs(isBiomass) = crs
crs(isDownDead) = crs
crs(isLitter) = crs
crs(isStandDead) = crs
crs(isSoil) = crs

isBiomass[is.na(isBiomass[])] = 0
isDownDead[is.na(isDownDead[])] = 0
isLitter[is.na(isLitter[])] = 0
isStandDead[is.na(isStandDead[])] = 0
isSoil[is.na(isSoil[])] = 0

writeRaster(isBiomass, "R Inputs/Initial Stocks/IS_LivingBiomass_1km.tif", format = "GTiff", overwrite = T, dataType = "FLT4S")
writeRaster(isDownDead, "R Inputs/Initial Stocks/IS_DownDeadwood_1km.tif", format = "GTiff", overwrite = T, dataType = "FLT4S")
writeRaster(isLitter, "R Inputs/Initial Stocks/IS_Litter_1km.tif", format = "GTiff", overwrite = T, dataType = "FLT4S")
writeRaster(isStandDead, "R Inputs/Initial Stocks/IS_StandingDeadwood_1km.tif", format = "GTiff", overwrite = T, dataType = "FLT4S")
writeRaster(isSoil, "R Inputs/Initial Stocks/IS_Soil_1km.tif", format = "GTiff", overwrite = T, dataType = "FLT4S")

levelplot(isBiomass)


initialStocks = scenario(myProject, "SF Initial Stocks [Spatial]", overwrite = F)

sheetName = "SF_InitialStockSpatial"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Initial Stocks [Spatial]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(StockTypeID = "Down Deadwood", RasterFileName = "R Inputs/Initial Stocks/IS_DownDeadwood_1km.tif"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Litter", RasterFileName = "R Inputs/Initial Stocks/IS_Litter_1km.tif"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Living Biomass", RasterFileName = "R Inputs/Initial Stocks/IS_LivingBiomass_1km.tif"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Soil", RasterFileName = "R Inputs/Initial Stocks/IS_Soil_1km.tif"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Standing Deadwood", RasterFileName = "R Inputs/Initial Stocks/IS_StandingDeadwood_1km.tif"))
saveDatasheet(initialStocks, sheetData, sheetName, append = F)


# Stock Flow Output Options-----------------------------------------------------------------------------------
# 
stockflowOutputOptions = scenario(myProject, "SF Output Options", overwrite = F)

sheetName = "SF_OutputOptions"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Output Options", optional = T, empty = T)
sheetData = data.frame(SummaryOutputST = T, SummaryOutputSTTimesteps = 1,
                       SummaryOutputFL = T, SummaryOutputFLTimesteps = 1,
                       SpatialOutputST = T, SpatialOutputSTTimesteps = 10,
                       SpatialOutputFL = F, SpatialOutputFLTimesteps = 10)
saveDatasheet(stockflowOutputOptions, sheetData, sheetName, append = F)


# Stock Group Membership-----------------------------------------------------------------------------------
# 
stockGroupMembership = scenario(myProject, "SF Stock Group Membership", overwrite = T)

sheetName = "SF_StockTypeGroupMembership"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Stock Group Membership", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(StockTypeID = "Down Deadwood", StockGroupID = "Total Deadwood", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Standing Deadwood", StockGroupID = "Total Deadwood", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Down Deadwood", StockGroupID = "DOM", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Standing Deadwood", StockGroupID = "DOM", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Litter", StockGroupID = "DOM", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Down Deadwood", StockGroupID = "Total Ecosystem Carbon", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Standing Deadwood", StockGroupID = "Total Ecosystem Carbon", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Litter", StockGroupID = "Total Ecosystem Carbon", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Living Biomass", StockGroupID = "Total Ecosystem Carbon", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Soil", StockGroupID = "Total Ecosystem Carbon", Value = 1.0))
saveDatasheet(stockGroupMembership, sheetData, sheetName, append = F)





# Flow Group Membership-----------------------------------------------------------------------------------
# 
flowGroupMembership = scenario(myProject, "SF Flow Group Membership", overwrite = T)

sheetName = "SF_FlowTypeGroupMembership"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Flow Group Membership", optional = T, empty = T)
# NPP
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Growth", FlowGroupID = "Net Primary Productivity (NPP)", Value = 1.0))
# NEP
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Growth", FlowGroupID = "Net Ecosystem Productivity (NEP)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (soil)", FlowGroupID = "Net Ecosystem Productivity (NEP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (litter)", FlowGroupID = "Net Ecosystem Productivity (NEP)", Value = -1.0))
# NBP
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Growth", FlowGroupID = "Net Biome Productivity (NBP)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (soil)", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (litter)", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (biomass)", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest (grain)", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest (straw)", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Leaching", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
# Emissions
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (soil)", FlowGroupID = "Emission", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (litter)", FlowGroupID = "Emission", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (biomass)", FlowGroupID = "Emission", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission", FlowGroupID = "Emission", Value = 1.0))
# Mortality
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (drought high)", FlowGroupID = "Mortality", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (drought medium)", FlowGroupID = "Mortality", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (drought low)", FlowGroupID = "Mortality", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality", FlowGroupID = "Mortality", Value = 1.0))

# Types as Groups
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality", FlowGroupID = "Mortality", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Litterfall", FlowGroupID = "Litterfall", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (drought high)", FlowGroupID = "Mortality (drought high)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (drought medium)", FlowGroupID = "Mortality (drought medium)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (drought low)", FlowGroupID = "Mortality (drought low)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Leaching", FlowGroupID = "Leaching", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest (straw)", FlowGroupID = "Harvest (straw)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest (grain)", FlowGroupID = "Harvest (grain)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest", FlowGroupID = "Harvest", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Growth", FlowGroupID = "Growth", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (straw)", FlowGroupID = "Emission (straw)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (soil)", FlowGroupID = "Emission (soil)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (litter)", FlowGroupID = "Emission (litter)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (grain)", FlowGroupID = "Emission (grain)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (biomass)", FlowGroupID = "Emission (biomass)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission", FlowGroupID = "Emission", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Decomposition", FlowGroupID = "Decomposition", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Deadfall", FlowGroupID = "Deadfall", Value = 1.0))
saveDatasheet(flowGroupMembership, sheetData, sheetName, append = F)


# Flow Order-----------------------------------------------------------------------------------
# 
flowOrder = scenario(myProject, "SF Flow Order", overwrite = T)

sheetName = "SF_FlowOrder"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Flow Order", optional = T, empty = T, lookupsAsFactors = F)
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Litterfall", Order = 1))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Growth", Order = 2))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission", Order = 3))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality", Order = 3))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest (straw)", Order = 3))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest (grain)", Order = 3))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest", Order = 3))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (biomass)", Order = 3))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Deadfall", Order = 4))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Decay", Order = 5))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (litter)", Order = 6))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Decomposition", Order = 6))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Leaching", Order = 7))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (soil)", Order = 7))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (straw)", Order = 10))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (grain)", Order = 10))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (drought high)", Order = 10))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (drought medium)", Order = 10))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (drought low)", Order = 10))
saveDatasheet(flowOrder, sheetData, sheetName, append = F)

# Flow Order Options
sheetName = "SF_FlowOrderOptions"
sheetdata = datasheet(myProject, name = sheetName, scenario = "SF Flow Order", optional = T, empty = T)
sheetData = data.frame(ApplyBeforeTransitions = T, ApplyEquallyRankedSimultaneously = T)
saveDatasheet(flowOrder, sheetData, sheetName, append = F)



# Flow Spatial Multipliers-----------------------------------------------------------------------------------
# 
flowSpatialMultipliers = scenario(myProject, "SF Flow Multipliers [Spatial]", overwrite = T)

sheetName = "SF_FlowSpatialMultiplier"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Flow Multipliers [Spatial]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Growth", MultiplierFileName = "R Inputs/Flow Multipliers/SM_Growth_1km.tif"))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Decay", MultiplierFileName = "R Inputs/Flow Multipliers/SM_Q10SlowMultiplier_1km.tif"))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Decomposition", MultiplierFileName = "R Inputs/Flow Multipliers/SM_Q10SlowMultiplier_1km.tif"))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Emission (litter)", MultiplierFileName = "R Inputs/Flow Multipliers/SM_Q10FastMultiplier_1km.tif"))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Emission (soil)", MultiplierFileName = "R Inputs/Flow Multipliers/SM_SoilEmission-Q10SlowMultiplier_1km.tif"))
saveDatasheet(flowSpatialMultipliers, sheetData, sheetName, append = F)




# Flow Temporal Multipliers-----------------------------------------------------------------------------------
# 
gcm = "CanESM2"
rcp = "rcp45"
myData = read.csv(paste("R Inputs/Flow Multipliers/FlowMultipliers", gcm, rcp, "csv", sep = "."), header = T)
myScenario = scenario(myProject, "SF Flow Multipliers [CanESM2.rcp45]", overwrite = F)
sheetData = data.frame(Timestep = myData$Timestep, StratumID = myData$StratumID, FlowGroupID = myData$FlowGroupID, Value = myData$Value)
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier", append = F)
sheetData = datasheet(myProject, name = "SF_FlowMultiplier", scenario = paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), optional = T, empty = F)
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought high)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.5, DistributionMax = 1.0))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought medium)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.1, DistributionMax = 0.5))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought low)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.01, DistributionMax = 0.1))
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier")

gcm = "CanESM2"
rcp = "rcp85"
myData = read.csv(paste("R Inputs/Flow Multipliers/FlowMultipliers", gcm, rcp, "csv", sep = "."), header = T)
myScenario = scenario(myProject, "SF Flow Multipliers [CanESM2.rcp85]", overwrite = F)
sheetData = data.frame(Timestep = myData$Timestep, StratumID = myData$StratumID, FlowGroupID = myData$FlowGroupID, Value = myData$Value)
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier", append = F)
sheetData = datasheet(myProject, name = "SF_FlowMultiplier", scenario = paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), optional = T, empty = F)
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought high)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.5, DistributionMax = 1.0))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought medium)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.1, DistributionMax = 0.5))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought low)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.01, DistributionMax = 0.1))
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier")

gcm = "CNRM-CM5"
rcp = "rcp45"
myData = read.csv(paste("R Inputs/Flow Multipliers/FlowMultipliers", gcm, rcp, "csv", sep = "."), header = T)
myScenario = scenario(myProject, "SF Flow Multipliers [CNRM-CM5.rcp45]", overwrite = F)
sheetData = data.frame(Timestep = myData$Timestep, StratumID = myData$StratumID, FlowGroupID = myData$FlowGroupID, Value = myData$Value)
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier", append = F)
sheetData = datasheet(myProject, name = "SF_FlowMultiplier", scenario = paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), optional = T, empty = F)
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought high)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.5, DistributionMax = 1.0))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought medium)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.1, DistributionMax = 0.5))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought low)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.01, DistributionMax = 0.1))
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier")

gcm = "CNRM-CM5"
rcp = "rcp85"
myData = read.csv(paste("R Inputs/Flow Multipliers/FlowMultipliers", gcm, rcp, "csv", sep = "."), header = T)
myScenario = scenario(myProject, "SF Flow Multipliers [CNRM-CM5.rcp85]", overwrite = F)
sheetData = data.frame(Timestep = myData$Timestep, StratumID = myData$StratumID, FlowGroupID = myData$FlowGroupID, Value = myData$Value)
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier", append = F)
sheetData = datasheet(myProject, name = "SF_FlowMultiplier", scenario = paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), optional = T, empty = F)
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought high)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.5, DistributionMax = 1.0))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought medium)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.1, DistributionMax = 0.5))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought low)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.01, DistributionMax = 0.1))
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier")

gcm = "HadGEM2-ES"
rcp = "rcp45"
myData = read.csv(paste("R Inputs/Flow Multipliers/FlowMultipliers", gcm, rcp, "csv", sep = "."), header = T)
myScenario = scenario(myProject, "SF Flow Multipliers [HadGEM2-ES.rcp45]", overwrite = F)
sheetData = data.frame(Timestep = myData$Timestep, StratumID = myData$StratumID, FlowGroupID = myData$FlowGroupID, Value = myData$Value)
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier", append = F)
sheetData = datasheet(myProject, name = "SF_FlowMultiplier", scenario = paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), optional = T, empty = F)
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought high)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.5, DistributionMax = 1.0))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought medium)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.1, DistributionMax = 0.5))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought low)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.01, DistributionMax = 0.1))
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier")

gcm = "HadGEM2-ES"
rcp = "rcp85"
myData = read.csv(paste("R Inputs/Flow Multipliers/FlowMultipliers", gcm, rcp, "csv", sep = "."), header = T)
myScenario = scenario(myProject, "SF Flow Multipliers [HadGEM2-ES.rcp85]", overwrite = F)
sheetData = data.frame(Timestep = myData$Timestep, StratumID = myData$StratumID, FlowGroupID = myData$FlowGroupID, Value = myData$Value)
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier", append = F)
sheetData = datasheet(myProject, name = "SF_FlowMultiplier", scenario = paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), optional = T, empty = F)
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought high)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.5, DistributionMax = 1.0))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought medium)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.1, DistributionMax = 0.5))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought low)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.01, DistributionMax = 0.1))
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier")

gcm = "MIROC5"
rcp = "rcp45"
myData = read.csv(paste("R Inputs/Flow Multipliers/FlowMultipliers", gcm, rcp, "csv", sep = "."), header = T)
myScenario = scenario(myProject, "SF Flow Multipliers [MIROC5.rcp45]", overwrite = F)
sheetData = data.frame(Timestep = myData$Timestep, StratumID = myData$StratumID, FlowGroupID = myData$FlowGroupID, Value = myData$Value)
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier", append = F)
sheetData = datasheet(myProject, name = "SF_FlowMultiplier", scenario = paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), optional = T, empty = F)
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought high)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.5, DistributionMax = 1.0))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought medium)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.1, DistributionMax = 0.5))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought low)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.01, DistributionMax = 0.1))
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier")

gcm = "MIROC5"
rcp = "rcp85"
myData = read.csv(paste("R Inputs/Flow Multipliers/FlowMultipliers", gcm, rcp, "csv", sep = "."), header = T)
myScenario = scenario(myProject, "SF Flow Multipliers [MIROC5.rcp85]", overwrite = F)
sheetData = data.frame(Timestep = myData$Timestep, StratumID = myData$StratumID, FlowGroupID = myData$FlowGroupID, Value = myData$Value)
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier", append = F)
sheetData = datasheet(myProject, name = "SF_FlowMultiplier", scenario = paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), optional = T, empty = F)
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought high)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.5, DistributionMax = 1.0))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought medium)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.1, DistributionMax = 0.5))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (drought low)", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.01, DistributionMax = 0.1))
saveDatasheet(myScenario, sheetData, name = "SF_FlowMultiplier")






# Transition Targets Parameters -----------------------------------------------------------------------------------

# Base Transition Targets
dir = "R Inputs/Transition Targets/"
typeBase = "TransitionTargetsBase"
typePop = "TransitionTargetsPop"
typeFire = "TransitionTargetsFire"
typeInsects = "TransitionTargetsInsects"

transitionTargetsBase = read.csv("R Inputs/Transition Targets/TransitionTargetsBase.csv", header = T)
head(transitionTargetsBase)


# BAU Scenarios
# 
lulc = "BAU"
gcm = "CanESM2"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "BAU"
gcm = "CanESM2"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "BAU"
gcm = "CNRM-CM5"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "BAU"
gcm = "CNRM-CM5"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "BAU"
gcm = "HadGEM2-ES"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "BAU"
gcm = "HadGEM2-ES"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "BAU"
gcm = "MIROC5"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "BAU"
gcm = "MIROC5"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

# High Population Scenarios
# 
lulc = "High"
gcm = "CanESM2"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario


lulc = "High"
gcm = "CanESM2"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "High"
gcm = "CNRM-CM5"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "High"
gcm = "CNRM-CM5"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "High"
gcm = "HadGEM2-ES"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "High"
gcm = "HadGEM2-ES"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "High"
gcm = "MIROC5"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "High"
gcm = "MIROC5"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario






# Medium Population Scenarios
# 
lulc = "Medium"
gcm = "CanESM2"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Medium"
gcm = "CanESM2"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Medium"
gcm = "CNRM-CM5"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Medium"
gcm = "CNRM-CM5"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Medium"
gcm = "HadGEM2-ES"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Medium"
gcm = "HadGEM2-ES"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Medium"
gcm = "MIROC5"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Medium"
gcm = "MIROC5"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario








# Low Population Scenarios

lulc = "Low"
gcm = "CanESM2"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Low"
gcm = "CanESM2"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Low"
gcm = "CNRM-CM5"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Low"
gcm = "CNRM-CM5"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Low"
gcm = "HadGEM2-ES"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Low"
gcm = "HadGEM2-ES"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Low"
gcm = "MIROC5"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario

lulc = "Low"
gcm = "MIROC5"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
fireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the fire data based on gcm and rcp
urbData = read.csv(paste(dir, typePop, ".", lulc, ".csv", sep = ""), header = T) # Reads in urbanization targets (not used for BAU scenario)
mortalityData = read.csv(paste(dir, typeInsects, ".", gcm, ".", rcp, ".csv", sep = ""), header = T) # Reads in the Insect mortality data based on gcm and rcp
saveDatasheet(myScenario, fireData, name = "STSim_TransitionTarget", append = F) # Loads fire data into scenario
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = T) # Appends the insect data into scenario
saveDatasheet(myScenario, transitionTargetsBase, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario
saveDatasheet(myScenario, urbData, name = "STSim_TransitionTarget", append = T) # Appends the base transition data into the scenario





# Spatial Multipliers-----------------------------------------------------------------------------------
# 
myScenario = scenario(myProject, "Spatial Multipliers [CanESM2.rcp45]", overwrite = F)

# Base Spatial Multipliers
smBase = data.frame(Timestep = 2002,
                    TransitionGroupID = c("AGRICULTURAL CONTRACTION", "AGRICULTURAL EXPANSION", "MANAGEMENT: Forest Clearcut [Type]", "MANAGEMENT: Forest Selection [Type]", "URBANIZATION"),
                    MultiplierFileName = c("R Inputs/Spatial Multipliers/SM_AgContraction_1km.tif", "R Inputs/Spatial Multipliers/SM_AgExpansion_1km.tif", "R Inputs/Spatial Multipliers/SM_Harvest_v2_Ecomask_1km.tif", "R Inputs/Spatial Multipliers/SM_Harvest_v2_Ecomask_1km.tif", "R Inputs/Spatial Multipliers/SM_Urbanization_1km.tif"))


# Base Fire Spatial Multipliers (2002-2016)
timestepList = seq(2002, 2016, 1)
transitionList = rep("FIRE", 15)
fileList = paste("R Inputs/Spatial Multipliers/SM_fire", timestepList, "_1km.tif", sep = "")
smFire = data.frame(Timestep = timestepList,
                    TransitionGroupID = transitionList,
                    MultiplierFileName = fileList)


# Base Drought Spatial Multipliers (2002-2016)
timestepList = seq(2002, 2016, 1)
transitionList = rep("DROUGHT: High Severity [Type]", 15)
fileList = paste("R Inputs/Spatial Multipliers/SM_insects_high.", timestepList, "_1km.tif", sep = "")
smInsectHigh = data.frame(Timestep = timestepList,
                          TransitionGroupID = transitionList,
                          MultiplierFileName = fileList)

transitionList = rep("DROUGHT: Medium Severity [Type]", 15)
fileList = paste("R Inputs/Spatial Multipliers/SM_insects_med.", timestepList, "_1km.tif", sep = "")
smInsectMed = data.frame(Timestep = timestepList,
                         TransitionGroupID = transitionList,
                         MultiplierFileName = fileList)

transitionList = rep("DROUGHT: Low Severity [Type]", 15)
fileList = paste("R Inputs/Spatial Multipliers/SM_insects_low.", timestepList, "_1km.tif", sep = "")
smInsectLow = data.frame(Timestep = timestepList,
                         TransitionGroupID = transitionList,
                         MultiplierFileName = fileList)

smInsects = rbind(smInsectHigh, smInsectMed, smInsectLow)


# Merge the base spatial multipliers used over historical period

smBaseAll = rbind(smFire, smInsects, smBase)
head(smBaseAll)



# Projected Fire Spatial Multipliers (2017-2101)
fileseq = seq(1, 84, 1)
projYears = seq(2017, 2100, 1)
projTrans = rep("FIRE", 84)
projInsHigh = rep("DROUGHT: High Severity [Type]", 84)
projInsMed = rep("DROUGHT: Medium Severity [Type]", 84)
projInsLow = rep("DROUGHT: Low Severity [Type]", 84)

gcm = "CanESM2"
rcp = "rcp45"
projFiles = paste("R Inputs/Spatial Multipliers/Westerling/1km/", gcm, ".", rcp, "/", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsHigh = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityHigh", "_", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsMed = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityMedium", "_", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsLow = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityLow", "_", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYears, TransitionGroupID = projTrans, MultiplierFileName = projFiles)
smInsHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesInsHigh)
smInsMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesInsMed)
smInsLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesInsLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F)
sheetData = rbind(smBaseAll, smFireProj, smInsHighProj, smInsMedProj, smInsLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)


gcm = "CanESM2"
rcp = "rcp85"
projFiles = paste("R Inputs/Spatial Multipliers/Westerling/1km/", gcm, ".", rcp, "/", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsHigh = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityHigh", "_", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsMed = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityMedium", "_", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsLow = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityLow", "_", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYears, TransitionGroupID = projTrans, MultiplierFileName = projFiles)
smInsHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesInsHigh)
smInsMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesInsMed)
smInsLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesInsLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F)
sheetData = rbind(smBaseAll, smFireProj, smInsHighProj, smInsMedProj, smInsLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)


gcm = "CNRM-CM5"
rcp = "rcp45"
projFiles = paste("R Inputs/Spatial Multipliers/Westerling/1km/", gcm, ".", rcp, "/", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsHigh = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityHigh", "_", "CNRM.CM5", ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsMed = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityMedium", "_", "CNRM.CM5", ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsLow = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityLow", "_", "CNRM.CM5", ".", rcp, "_", fileseq, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYears, TransitionGroupID = projTrans, MultiplierFileName = projFiles)
smInsHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesInsHigh)
smInsMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesInsMed)
smInsLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesInsLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F)
sheetData = rbind(smBaseAll, smFireProj, smInsHighProj, smInsMedProj, smInsLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)


gcm = "CNRM-CM5"
rcp = "rcp85"
projFiles = paste("R Inputs/Spatial Multipliers/Westerling/1km/", gcm, ".", rcp, "/", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsHigh = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityHigh", "_", "CNRM.CM5", ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsMed = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityMedium", "_", "CNRM.CM5", ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsLow = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityLow", "_", "CNRM.CM5", ".", rcp, "_", fileseq, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYears, TransitionGroupID = projTrans, MultiplierFileName = projFiles)
smInsHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesInsHigh)
smInsMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesInsMed)
smInsLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesInsLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F)
sheetData = rbind(smBaseAll, smFireProj, smInsHighProj, smInsMedProj, smInsLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)


gcm = "HadGEM2-ES"
rcp = "rcp45"
projFiles = paste("R Inputs/Spatial Multipliers/Westerling/1km/", gcm, ".", rcp, "/", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsHigh = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityHigh", "_", "HadGEM2.ES", ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsMed = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityMedium", "_", "HadGEM2.ES", ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsLow = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityLow", "_", "HadGEM2.ES", ".", rcp, "_", fileseq, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYears, TransitionGroupID = projTrans, MultiplierFileName = projFiles)
smInsHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesInsHigh)
smInsMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesInsMed)
smInsLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesInsLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F)
sheetData = rbind(smBaseAll, smFireProj, smInsHighProj, smInsMedProj, smInsLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)


gcm = "HadGEM2-ES"
rcp = "rcp85"
projFiles = paste("R Inputs/Spatial Multipliers/Westerling/1km/", gcm, ".", rcp, "/", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsHigh = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityHigh", "_", "HadGEM2.ES", ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsMed = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityMedium", "_", "HadGEM2.ES", ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsLow = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityLow", "_", "HadGEM2.ES", ".", rcp, "_", fileseq, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYears, TransitionGroupID = projTrans, MultiplierFileName = projFiles)
smInsHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesInsHigh)
smInsMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesInsMed)
smInsLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesInsLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F)
sheetData = rbind(smBaseAll, smFireProj, smInsHighProj, smInsMedProj, smInsLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)

gcm = "MIROC5"
rcp = "rcp45"
projFiles = paste("R Inputs/Spatial Multipliers/Westerling/1km/", gcm, ".", rcp, "/", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsHigh = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityHigh", "_", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsMed = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityMedium", "_", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsLow = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityLow", "_", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYears, TransitionGroupID = projTrans, MultiplierFileName = projFiles)
smInsHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesInsHigh)
smInsMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesInsMed)
smInsLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesInsLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F)
sheetData = rbind(smBaseAll, smFireProj, smInsHighProj, smInsMedProj, smInsLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)


gcm = "MIROC5"
rcp = "rcp85"
projFiles = paste("R Inputs/Spatial Multipliers/Westerling/1km/", gcm, ".", rcp, "/", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsHigh = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityHigh", "_", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsMed = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityMedium", "_", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
projFilesInsLow = paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/", "MortalityLow", "_", gcm, ".", rcp, "_", fileseq, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYears, TransitionGroupID = projTrans, MultiplierFileName = projFiles)
smInsHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesInsHigh)
smInsMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesInsMed)
smInsLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesInsLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F)
sheetData = rbind(smBaseAll, smFireProj, smInsHighProj, smInsMedProj, smInsLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)




x = raster("R Inputs/Spatial Multipliers/SM_Harvest_1km.tif")
y = raster("R Inputs/Spatial Multipliers/SM_Harvest_v2_1km.tif")
z = raster("R Inputs/Spatial Multipliers/SM_Harvest_v2_Ecomask_1km.tif")
plot(x)
plot(y)
plot(z)












# -----------------------------------------------------------------------------------#
# Create Final Scenarios
# -----------------------------------------------------------------------------------#

# Create STSM Constants Sub-Scenario------------------------------------------

stsmConstants = scenario(myProject, "STSM Constants [1MC]", overwrite = F)
dependency(stsmConstants, dependency = c("Output Options", "Transition Multipliers", "Transition Size Distribution", "Time Since Transition",
                                         "Adjacency Multipliers", "State Attributes", "Historical Distributions", "Pathways", "Initial Conditions", "Run Control [100TS; 1MC]"))

stsmConstants = scenario(myProject, "STSM Constants", overwrite = F)
dependency(stsmConstants, dependency = c("Output Options", "Transition Multipliers", "Transition Size Distribution", "Time Since Transition",
                                         "Adjacency Multipliers", "State Attributes", "Historical Distributions", "Pathways", "Initial Conditions", "Run Control [100TS; 100MC]"))

# Create SF Constants Sub-Scenario------------------------------------------

sfConstants = scenario(myProject, "SF Constants", overwrite = F)
dependency(sfConstants, dependency = c("SF Flow Pathways", "SF Initial Stocks [Spatial]", "SF Output Options", "SF Stock Group Membership", "SF Flow Group Membership",
                                       "SF Flow Order", "SF Flow Multipliers [Spatial]"))

# Create a Test 1 MC Scenario-----------------------------------------------------------------------------------

lulc = "BAU"
exvar = "External Variables [Medium/BAU]"

gcm = "CanESM2"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants [1MC]", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))


# Create BAU Scenarios-----------------------------------------------------------------------------------
# 
lulc = "BAU"
exvar = "External Variables [Medium/BAU]"

gcm = "CanESM2"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "CanESM2"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "CNRM-CM5"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "CNRM-CM5"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "HadGEM2-ES"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "HadGEM2-ES"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "MIROC5"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "MIROC5"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))



# Create High Scenarios-----------------------------------------------------------------------------------
# 
lulc = "High"
exvar = "External Variables [High]"

gcm = "CanESM2"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "CanESM2"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "CNRM-CM5"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "CNRM-CM5"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "HadGEM2-ES"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "HadGEM2-ES"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "MIROC5"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "MIROC5"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))













# Create Medium Scenarios-----------------------------------------------------------------------------------
# 
lulc = "Medium"
exvar = "External Variables [Medium/BAU]"

gcm = "CanESM2"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "CanESM2"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "CNRM-CM5"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "CNRM-CM5"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "HadGEM2-ES"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "HadGEM2-ES"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "MIROC5"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "MIROC5"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))



# Create Low Scenarios-------------------------------------------------------------
lulc = "Low"
exvar = "External Variables [Low]"

gcm = "CanESM2"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "CanESM2"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "CNRM-CM5"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "CNRM-CM5"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "HadGEM2-ES"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "HadGEM2-ES"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "MIROC5"
rcp = "rcp45"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))

gcm = "MIROC5"
rcp = "rcp85"
myScenario = scenario(myProject, paste(lulc, gcm, rcp, sep = "."), overwrite = F)
dependency(myScenario, dependency = c("STSM Constants", "SF Constants", exvar, paste("SF Flow Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))








# -----------------------------------------------------------------------------------#
# Run Scenarios
# -----------------------------------------------------------------------------------#

# Run test scenario
run(myProject, scenario = 81, summary = F, jobs = 1, forceElements = F)












