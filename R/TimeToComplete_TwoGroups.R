##########################################
# Import relevant libaries
##########################################

library("ggplot2")
library("gridExtra")
library("cowplot")
library("grImport")

##################################################
# Specify filepath for pairwise discrimination and 
# reversal learning data
##################################################
pairwisePath = "G:\\Data\\Mouse reversal\\Amira\\Mouse Pairwise Discrimination v3\\"
reversalPath = "G:\\Data\\Mouse reversal\\Amira\\Mouse Reversal\\"

#################################################
# Specify the groups that you want to analyse
#################################################
groupFolders = c('999')

wildtypeAnimals = c('1GR','1RD','1RDGR','1WH','3GR','3RD','3RDGR','3WH','5GR','5RD','5RDGR','5WH')
knockoutAnimals = c('2GR','2RD','2RDGR','2WH','4GR','4RD','4RDGR','4WH','6GR','6RD','6RDGR','6WH')

##################################################
# Data collection happens here
# This script collects the following data:
# 1. Time to complete the pairwise discrimination learning phase
# 2. Time to complete 
# 
# The script assumes that there is data for each group in both
# the pairwise folder and the reversal folder
# And that each group has the same number of animals

time2Complete_Pairwise = vector(mode = "numeric",length=0)
time2Complete_Reversal = vector(mode = "numeric",length=0)
genotypeVector = vector(mode="character", length = 0)
animalVector   = vector(mode="character", length=  0)
for (group in groupFolders)
{
  pairwiseGroupFolder = paste(pairwisePath,group, sep = '')
  reversalGroupFolder = paste(reversalPath,group, sep = '')
  
  groupAnimals = dir(path=pairwiseGroupFolder)
  
  for (animal in groupAnimals)
  {
    pairwiseAnimalFolder = paste(pairwiseGroupFolder,animal,sep = '\\')
    sessionFiles = list.files(path=pairwiseAnimalFolder)
    nPairwiseSessions = length(sessionFiles)
    
    reversalAnimalFolder = paste(reversalGroupFolder, animal, sep = '\\')
    sessionFiles = list.files(path=reversalAnimalFolder)
    nReversalSessions = length(sessionFiles)
    
    time2Complete_Pairwise = append(time2Complete_Pairwise,nPairwiseSessions)
    time2Complete_Reversal  =append(time2Complete_Reversal,nReversalSessions)
    
    animalVector = append(animalVector,animal)
    animalCondition = which(wildtypeAnimals == animal)
    if ( length(animalCondition) > 0)
      genotypeVector = append(genotypeVector,"Wildtype")
    else
      genotypeVector = append(genotypeVector,"Knockout")
  }
}

###########################################################################
# This part constructs a dataframe in which all the session data is pooled
###########################################################################
nAnimals = length(time2Complete_Pairwise)
time2Complete_Results =data.frame(Phase= c(rep("Discrimination",nAnimals), rep("Reversal",nAnimals)), 
                                  Sessions = c(time2Complete_Pairwise,time2Complete_Reversal),
                                  Genotype = as.factor(genotypeVector),
                                  Subject = c(animalVector, animalVector))

###########################################################################
# Plot the results
###########################################################################
ggplot(data = time2Complete_Results,aes(x = Phase, y=Sessions, fill = Genotype)) + geom_boxplot(outlier.shape = NA) + 
  geom_point(position = position_jitterdodge(jitter.width = 0.2, dodge.width=0.75)) +
  ylab("Sessions (N)") + xlab("") + ggtitle("Time to complete schedule")

###########################################################################
# Performs an analysis of variance for main effect of Phase and Genotype
# and the interaction between the two. 
###########################################################################
aovResult = aov(Sessions ~ Phase*Genotype + Error(Subject/Phase),data = time2Complete_Results)
summary(aovResult)