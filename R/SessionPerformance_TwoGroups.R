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
# 1. Performance on the first session of pairwise discrimination
# 2. Performance on the last session of pairwise discrimination
# 3. Performance on the first session of reversal learning
# 4. Performance on the last session of reversal learning
# 
# The script assumes that there is data for each group in both
# the pairwise folder and the reversal folder
# And that each group has the same number of animals
includeCorrection = TRUE
pcFirst_Pairwise    = vector(mode = "numeric",length=0)
pcLast_Pairwise  = vector(mode = "numeric",length=0)
pcFirst_Reversal   = vector(mode = "numeric", length=0)
pcLast_Reversal = vector(mode = "numeric", length=0)

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
  
  # For each animal in this group we read the performance in the first
  # and last session of pairwise discrimination learning
  for (animal in animals_Pairwise)
  {
    currentAnimalFolder = paste(currentGroupFolder_Pairwise,animal,sep = '\\')
    csvFiles = list.files(path=currentAnimalFolder)
    nFiles = length(csvFiles)
    dataFirst = read.csv(paste(currentAnimalFolder,csvFiles[1],sep='\\'), header = TRUE)
    dataLast = read.csv(paste(currentAnimalFolder,csvFiles[nFiles],sep='\\'), header = TRUE)
    names(dataFirst) = c('trialID','targetID','distractorID','responseEvaluation','correctPosition','answerPosition','correction','time','rt', 'collectionTime', 'isiScreenPokeCount','isiFBCrossingCount','isiBBCrossingCount','isiRewardPokeCount')
    names(dataLast) = c('trialID','targetID','distractorID','responseEvaluation','correctPosition','answerPosition','correction','time','rt', 'collectionTime', 'isiScreenPokeCount','isiFBCrossingCount','isiBBCrossingCount','isiRewardPokeCount')
    
    # Get the performance for the first session of pairwise discrimination
    if (includeCorrection == TRUE)
    {
      correctCount = length(which(dataFirst$responseEvaluation == 1))
      trialCount = length(dataFirst$responseEvaluation)
    }
    else
    {
      correctCount = length(which(dataFirst$responseEvaluation == 1 & dataFirst$correction == 0))
      trialCount = length(which(dataFirst$correction == 0))
    }
    pcFirst_Pairwise = append(pcFirst_Pairwise,correctCount/trialCount)
    
    # Get the performance for the last session of pairwise discrimination
    if (includeCorrection == TRUE)
    {
      correctCount = length(which(dataLast$responseEvaluation == 1))
      trialCount = length(dataLast$responseEvaluation)
    }
    else
    {
      correctCount = length(which(dataLast$responseEvaluation == 1 & dataLast$correction == 0))
      trialCount = length(which(dataLast$correction == 0))
    }
    pcLast_Pairwise  = append(pcLast_Pairwise, correctCount/trialCount)
    
    # Store animal and genotype data
    animalVector_Pairwise = append(animalVector_Pairwise,animal)
    if (length(which(wildtypeAnimals == animal)) > 0)
      genotypeVector_Pairwise = append(genotypeVector_Pairwise,"wildtype")
    else
      genotypeVector_Pairwise = append(genotypeVector_Pairwise,"knockout")
  }
  
  # For each animal in this group we read the performance in the first
  # and last session of pairwise discrimination learning
  for (animal in animals_Reversal)
  {
    currentAnimalFolder = paste(currentGroupFolder_Reversal,animal,sep = '\\')
    csvFiles = list.files(path=currentAnimalFolder)
    nFiles = length(csvFiles)
    dataFirst = read.csv(paste(currentAnimalFolder,csvFiles[1],sep='\\'), header = TRUE)
    dataLast = read.csv(paste(currentAnimalFolder,csvFiles[nFiles],sep='\\'), header = TRUE)
    names(dataFirst) = c('trialID','targetID','distractorID','responseEvaluation','correctPosition','answerPosition','correction','time','rt', 'collectionTime', 'isiScreenPokeCount','isiFBCrossingCount','isiBBCrossingCount','isiRewardPokeCount')
    names(dataLast) = c('trialID','targetID','distractorID','responseEvaluation','correctPosition','answerPosition','correction','time','rt', 'collectionTime', 'isiScreenPokeCount','isiFBCrossingCount','isiBBCrossingCount','isiRewardPokeCount')
    
    # Get the mean reaction time on each trial
    # Get the performance
    if (includeCorrection == TRUE)
    {
      correctCount = length(which(dataFirst$responseEvaluation == 1))
      trialCount = length(dataFirst$responseEvaluation)
    }
    else
    {
      correctCount = length(which(dataFirst$responseEvaluation == 1 & dataFirst$correction == 0))
      trialCount = length(which(dataFirst$correction == 0))
    }
    pcFirst_Reversal = append(pcFirst_Reversal,correctCount/trialCount)
    
    if (includeCorrection == TRUE)
    {
      correctCount = length(which(dataLast$responseEvaluation == 1))
      trialCount = length(dataLast$responseEvaluation)
    }
    else
    {
      correctCount = length(which(dataLast$responseEvaluation == 1 & dataLast$correction == 0))
      trialCount = length(which(dataLast$correction == 0))
    }
    pcLast_Reversal  = append(pcLast_Reversal, correctCount/trialCount)
    
    # Store animal and genotype data
    animalVector_Reversal = append(animalVector_Reversal,animal)
    if (length(which(wildtypeAnimals == animal)) > 0)
      genotypeVector_Reversal = append(genotypeVector_Reversal,"wildtype")
    else
      genotypeVector_Reversal = append(genotypeVector_Reversal,"knockout")
  }
}

###########################################################################
# We put the collected data vectors in a data frame to make further
# analysis and plotting more easy
###########################################################################
pairwise_Results = data.frame(Y = c(pcFirst_Pairwise,pcLast_Pairwise),
                              Genotype = c(genotypeVector_Pairwise,genotypeVector_Pairwise),
                              Session = c(rep("First",length(pcFirst_Pairwise)), rep("Last",length(pcLast_Pairwise))),
                              Subject = c(animalVector_Pairwise,animalVector_Pairwise))

reversal_Results = data.frame(Y = c(pcFirst_Reversal, pcLast_Reversal),
                              Genotype = c(genotypeVector_Reversal, genotypeVector_Reversal),
                              Session = c(rep("First", length(pcFirst_Reversal)), rep("Last", length(pcLast_Reversal))),
                              Subject = c(animalVector_Reversal, animalVector_Reversal))

###########################################################################
# Plot the results
###########################################################################
p1 = ggplot(pairwise_Results,aes(x = Session, y = Y, fill = Genotype)) +
  geom_boxplot(outlier.shape = NA) + 
  geom_point(position = position_jitterdodge(jitter.width = 0.2, dodge.width=0.75)) +
  scale_fill_discrete(limits=c("wildtype","knockout"),labels=c("wildtype","knock-in")) +
  ylim(0,1)+geom_hline(yintercept=0.5,linetype="dashed")+
  ggtitle('Boxplot Discrimination Performance') + xlab('Pairwise discrimination session') + ylab('Mean performance')

p2 = ggplot(reversal_Results,aes(x = Session, y = Y, fill = Genotype)) +
  geom_boxplot(outlier.shape = NA) + 
  geom_point(position = position_jitterdodge(jitter.width = 0.2, dodge.width=0.75)) +
  scale_fill_discrete(limits=c("wildtype","knockout"),labels=c("wildtype","knock-in")) +
  ylim(0,1)+geom_hline(yintercept=0.5,linetype="dashed")+
  ggtitle('Boxplot Reversal Performance') + xlab('Reversal learning session') + ylab('Mean performance')

ggdraw() +
  draw_plot(p1,0.0 ,.0  ,.5,1) + 
  draw_plot(p2,0.5 ,0.0 ,.5,1) 

###########################################################################
# Performs an Anova for main effects of genotype and session as well as
# the interaction between genotype and session. Session is considered
# a within subject variable. In the case of an interaction, follow up t-tests
# can be conducted to further investigate the effects
###########################################################################
pairwise_AOV = aov(Y ~ Genotype*Session + Error(Subject/(Session)),data = pairwise_Results)
summary(pairwise_AOV)
reversal_AOV = aov(Y ~ Genotype*Session + Error(Subject/(Session)),data = reversal_Results)
summary(reversal_AOV)
t.test(pcFirst_Pairwise[genotypeVector_Pairwise == "knockout"],pcFirst_Pairwise[genotypeVector_Pairwise=="wildtype"])
t.test(pcLast_Pairwise[genotypeVector_Pairwise == "knockout"],pcLast_Pairwise[genotypeVector_Pairwise=="wildtype"])

t.test(pcFirst_Reversal[genotypeVector_Reversal == "knockout"],pcFirst_Reversal[genotypeVector_Reversal=="wildtype"])
t.test(pcLast_Reversal[genotypeVector_Reversal == "knockout"],pcLast_Reversal[genotypeVector_Reversal=="wildtype"])