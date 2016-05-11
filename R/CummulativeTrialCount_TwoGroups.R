# Import relevant libaries
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
setwd(pairwisePath)

#################################################
# Specify the groups that you want to analyse
#################################################
groupFolders = c('999')
wildtypeAnimals = c('1GR','1RD','1RDGR','1WH','3GR','3RD','3RDGR','3WH','5GR','5RD','5RDGR','5WH')
knockoutAnimals = c('2GR','2RD','2RDGR','2WH','4GR','4RD','4RDGR','4WH','6GR','6RD','6RDGR','6WH')

##################################################
# Data collection happens here
# This script collects the following data:
# 1. Cummulative trial count on the first session of pairwis discrimination
# 2. Cummulative trial count on the last session of pairwise discrimination
# 3. Cummulative trial count on the first session of reversal
# 4. Cummulative trial count on the last session of reversal

xTime = seq(2,60,2)
cTrialsFirst_Pairwise   = matrix(data = NA, nrow=0, ncol = length(xTime))
cTrialsLast_Pairwise    = matrix(data = NA, nrow=0, ncol = length(xTime))
cTrialsFirst_Reversal   = matrix(data = NA, nrow=0, ncol = length(xTime))
cTrialsLast_Reversal    = matrix(data = NA, nrow=0, ncol = length(xTime))

animalVector_Pairwise = vector(mode="character",length = 0)
genotypeVector_Pairwise = vector(mode = "character",length = 0)
animalVector_Reversal = vector(mode="character",length = 0)
genotypeVector_Reversal = vector(mode = "character",length = 0)

for (group in groupFolders)
{
  currentGroupFolder_Pairwise = paste(pairwisePath,group, sep = '')
  currentGroupFolder_Reversal = paste(reversalPath,group, sep = '')
  
  animals_Pairwise = dir(path=currentGroupFolder_Pairwise)
  animals_Reversal = dir(path=currentGroupFolder_Reversal)
  
  for (animal in animals_Pairwise)
  {
    # Read in data from the first and the last session
    currentAnimalFolder = paste(currentGroupFolder_Pairwise,animal,sep = '\\')
    csvFiles = list.files(path=currentAnimalFolder)
    nFiles = length(csvFiles)
    dataFirst = read.csv(paste(currentAnimalFolder,csvFiles[1],sep='\\'), header = TRUE)
    dataLast = read.csv(paste(currentAnimalFolder,csvFiles[nFiles],sep='\\'), header = TRUE)
    names(dataFirst) = c('trialID','targetID','distractorID','responseEvaluation','correctPosition','answerPosition','correction','time','rt', 'collectionTime', 'isiScreenPokeCount','isiFBCrossingCount','isiBBCrossingCount','isiRewardPokeCount')
    names(dataLast) = c('trialID','targetID','distractorID','responseEvaluation','correctPosition','answerPosition','correction','time','rt', 'collectionTime', 'isiScreenPokeCount','isiFBCrossingCount','isiBBCrossingCount','isiRewardPokeCount')
    
    # Calculate for the cummulative trial count
    firstVector = integer(length(xTime))
    lastVector = integer(length(xTime))
    for (i in seq(1,length(xTime)))
    {
      firstVector[i] = length(which(dataFirst$time < xTime[i]*60))
      lastVector[i] = length(which(dataLast$time < xTime[i]*60))
    }
    
    # Add to the data matrix
    cTrialsFirst_Pairwise = rbind(cTrialsFirst_Pairwise,firstVector)
    cTrialsLast_Pairwise = rbind(cTrialsLast_Pairwise,lastVector)
    
    # Store animal and genotype data
    animalVector_Pairwise = append(animalVector_Pairwise,animal)
    if (length(which(wildtypeAnimals == animal)) > 0)
      genotypeVector_Pairwise = append(genotypeVector_Pairwise,"wildtype")
    else
      genotypeVector_Pairwise = append(genotypeVector_Pairwise,"knock-in")
  }
  
  for (animal in animals_Reversal)
  {
    currentAnimalFolder = paste(currentGroupFolder_Reversal,animal,sep = '\\')
    csvFiles = list.files(path=currentAnimalFolder)
    nFiles = length(csvFiles)
    dataFirst = read.csv(paste(currentAnimalFolder,csvFiles[1],sep='\\'), header = TRUE)
    dataLast = read.csv(paste(currentAnimalFolder,csvFiles[nFiles],sep='\\'), header = TRUE)
    names(dataFirst) = c('trialID','targetID','distractorID','responseEvaluation','correctPosition','answerPosition','correction','time','rt', 'collectionTime', 'isiScreenPokeCount','isiFBCrossingCount','isiBBCrossingCount','isiRewardPokeCount')
    names(dataLast) = c('trialID','targetID','distractorID','responseEvaluation','correctPosition','answerPosition','correction','time','rt', 'collectionTime', 'isiScreenPokeCount','isiFBCrossingCount','isiBBCrossingCount','isiRewardPokeCount')
    
    # Get curves of cummulative trials completed
    firstVector = integer(length(xTime))
    lastVector = integer(length(xTime))
    for (i in seq(1,length(xTime)))
    {
      firstVector[i] = length(which(dataFirst$time < xTime[i]*60))
      lastVector[i] = length(which(dataLast$time < xTime[i]*60))
    }
    
    # Add to the data matrix
    cTrialsFirst_Reversal = rbind(cTrialsFirst_Reversal,firstVector)
    cTrialsLast_Reversal = rbind(cTrialsLast_Reversal,lastVector)
    
    # Store animal and genotype data
    animalVector_Reversal = append(animalVector_Reversal,animal)
    if (length(which(wildtypeAnimals == animal)) > 0)
      genotypeVector_Reversal = append(genotypeVector_Reversal,"wildtype")
    else
      genotypeVector_Reversal = append(genotypeVector_Reversal,"knock-in")
  }
}

##################################################
# Here we create summary variables based on the extracted data
# We calculate the mean and standard error for the first and last session
# of pairwise discrimination
# and for first and last session of the reversal protocol
#
pairwise_Results = data.frame(Time = integer(),
                              Mean = double(),
                              SE = double(),
                              Session = character(),
                              Genotype = character(),stringsAsFactors=FALSE)
reversal_Results = pairwise_Results
for (genotype in genotypeVector_Pairwise)
{
  genotypeIdx = which(genotypeVector_Pairwise == genotype)
  
  pairwise_Results = rbind(pairwise_Results, data.frame("Time" = xTime,
                                             "Mean" = colMeans(cTrialsFirst_Pairwise[genotypeIdx,]),
                                             "SE" = apply(cTrialsFirst_Pairwise[genotypeIdx,],2,sd)/sqrt(length(genotypeIdx)),
                                             "Session" = rep("first",length(xTime)),
                                             "Genotype" = rep(genotype,length(xTime))))
  
  pairwise_Results = rbind(pairwise_Results, data.frame("Time" = xTime,
                                                        "Mean" = colMeans(cTrialsLast_Pairwise[genotypeIdx,]),
                                                        "SE" = apply(cTrialsLast_Pairwise[genotypeIdx,],2,sd)/sqrt(length(genotypeIdx)),
                                                        "Session" = rep("last",length(xTime)),
                                                        "Genotype" = rep(genotype,length(xTime))))
}

for (genotype in genotypeVector_Reversal)
{
  genotypeIdx = which(genotypeVector_Reversal == genotype)
  reversal_Results = rbind(reversal_Results, data.frame("Time" = xTime,
                                                        "Mean" = colMeans(cTrialsFirst_Reversal[genotypeIdx,]),
                                                        "SE" = apply(cTrialsFirst_Reversal[genotypeIdx,],2,sd)/sqrt(length(genotypeIdx)),
                                                        "Session" = rep("first",length(xTime)),
                                                        "Genotype" = rep(genotype,length(xTime))))
  
  reversal_Results = rbind(reversal_Results, data.frame("Time" = xTime,
                                                        "Mean" = colMeans(cTrialsLast_Reversal[genotypeIdx,]),
                                                        "SE" = apply(cTrialsLast_Reversal[genotypeIdx,],2,sd)/sqrt(length(genotypeIdx)),
                                                        "Session" = rep("last",length(xTime)),
                                                        "Genotype" = rep(genotype,length(xTime))))
}

p1 = ggplot(pairwise_Results,aes(x=Time,y=Mean, fill = Genotype)) + facet_grid(.~ Session)+
  geom_line(aes(linetype=Genotype)) + geom_ribbon(aes(ymin=Mean-SE, ymax = Mean+SE,fill=Genotype),alpha=0.2) +
  ggtitle('Pairwise discrimination') + ylab("Cummulative trial count (N) + S.E.") + ylim(0,90) + 
  xlab("Time (minutes)")

p2 = ggplot(reversal_Results,aes(x=Time,y=Mean)) + facet_grid(.~ Session)+
  geom_line(aes(linetype=Genotype)) + geom_ribbon(aes(ymin=Mean-SE, ymax = Mean+SE,fill=Genotype),alpha=0.2) +
  ggtitle('Reversal learning') + ylab("Cummulative trial count (N) + S.E.") + ylim(0,90) + 
  xlab("Time (minutes)")


ggdraw() +
  draw_plot(p1,0.0 ,.0  ,.5,1) + 
  draw_plot(p2,0.5 ,0.0 ,.5,1) 
