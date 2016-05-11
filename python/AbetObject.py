# -*- coding: utf-8 -*-
"""
AbetObject class:
    Allows to read exported Abet csv files and transforms them into a format that is
    more convenient for subsequent data analysis
"""
import csv
import os
import sys

class AbetObject:
    columnNames = {'ResponseCount': 4, 'RTCount': 5, 'CollectCount':6, 'ScreenPokeCount':7,
                   'FrontbeamCount':8, 'BackbeamCount':9, 'RewardTrayCount':10}
    filename = ''
    dataPath = '';
    excludedSchedules = set()
    availableSchedules = set()
    
    maxResponseCount = 0
    maxRTCount = 0
    maxCollectCount = 0
    maxScreenpokeCount = 0
    maxFrontbeamCount = 0
    maxBackbeamCount = 0
    maxRewardpokeCount = 0
    
    rawData = []
    errorMessage= ''
    isGood = True
    def __init__(self):
        self.Reset()
        
    # Resets the data
    def Reset(self):
        self.filename = ''
        self.dataPath = ''
        self.maxResponseCount = 0
        self.maxRTCount = 0
        self.maxCollectCount = 0
        self.maxScreenpokeCount = 0
        self.maxFrontbeamCount = 0
        self.maxBackbeamCount = 0
        self.maxRewardpokeCount = 0
        self.rawData = []
        
    # Loads the raw csv file into memory
    def ReadFile(self,filename, delim = ',', quote ='"'):
        self.Reset()
        fileObject = open(filename, 'rb')
        if fileObject.closed:
            return        
        
        # To avoid problems with different csv format, we try to extract the format
        # before parsing the file
        self.rawData = []
        self.availableSchedules = set()
        self.isGood = True
        try:
            csvDialect = csv.Sniffer().sniff(fileObject.read(1024))
            fileObject.seek(0)
            abetReader = csv.reader(fileObject, csvDialect)        
            abetReader.next()
            
            for row in abetReader:
                self.availableSchedules.add(row[0])
                self.rawData.append(row)
            fileObject.close()
            self.dataPath = os.path.dirname(filename)
        except:
            if not fileObject.closed:
                fileObject.close()
            self.isGood = False
            self.errorMessage = sys.exc_info()[0]
        
    def GetAvailableSchedules(self):
        return list(self.availableSchedules)
        
    def ParseFile(self):
        # First pass through the data to collect largest number of collected data
        # This is needed to calculate the correct offset when extracting individual data rows
        for row in self.rawData:
            rowResponseCount = row[self.columnNames['ResponseCount']].replace(" ", "")
            rowRTCount = row[self.columnNames['RTCount']].replace(" ", "")
            rowCollectCount = row[self.columnNames['CollectCount']].replace(" ", "")
            rowScreenpokeCount = row[self.columnNames['ScreenPokeCount']].replace(" ", "")
            rowFrontbeamCount = row[self.columnNames['FrontbeamCount']].replace(" ", "")
            rowBackbeamCount = row[self.columnNames['BackbeamCount']].replace(" ", "")
            rowRewardpokeCount = row[self.columnNames['RewardTrayCount']].replace(" ", "")
            
            self.maxResponseCount = max(self.maxResponseCount,int(float(rowResponseCount)))
            self.maxRTCount = max(self.maxRTCount,int(float(rowRTCount)))
            self.maxCollectCount = max(self.maxCollectCount,int(float(rowCollectCount)))
            self.maxScreenpokeCount = max(self.maxScreenpokeCount,int(float(rowScreenpokeCount)))
            self.maxFrontbeamCount = max(self.maxFrontbeamCount,int(float(rowFrontbeamCount)))
            self.maxBackbeamCount = max(self.maxBackbeamCount,int(float(rowBackbeamCount)))
            self.maxRewardpokeCount = max(self.maxRewardpokeCount,int(float(rowRewardpokeCount)))
            
        # Second pass through the data. This collects the individual data and exports the results to a file
        for row in self.rawData:
            scheduleName = row[0]
            if scheduleName in self.excludedSchedules:
                continue
            scheduleDate = self.ParseDateString(row[1])
            
            # Assign default numbers in case this number is not filled in            
            if len(row[2]) == 0:
                animalID = '999'
            else:
                animalID = row[2]
            if len(row[3]) == 0:
                groupID = '999'
            else:
                groupID = row[3]
            
            # Count indivual data points
            responseCount = int(float(row[self.columnNames['ResponseCount']].replace(" ", "")))
            rtCount = int(float(row[self.columnNames['RTCount']].replace(" ", "")))
            collectCount = int(float(row[self.columnNames['CollectCount']].replace(" ", "")))
            screenpokeCount = int(float(row[self.columnNames['ScreenPokeCount']].replace(" ", "")))
            frontbeamCount = int(float(row[self.columnNames['FrontbeamCount']].replace(" ", "")))
            backbeamCount = int(float(row[self.columnNames['BackbeamCount']].replace(" ", "")))
            rewardpokeCount = int(float(row[self.columnNames['RewardTrayCount']].replace(" ", "")))
            
            # Consistency check, the number of responses should equal the number of reaction times
            # If no response is registered, the session is skipped
            if responseCount != rtCount:
                print "Mismatch between detected responses and detected reaction times"
                print scheduleDate + ": " + scheduleName +  " " + str(animalID) + ", " + str(groupID)
                            
            if responseCount == 0:
                continue
            
            # Collect response data in separate lists
            responseOffset = 11
            try:
                responseTimestamps = [float(row[i]) for i in range(responseOffset,responseOffset+responseCount)]
                responseEvaluations= [int(float(row[i])) for i in range(responseOffset+ self.maxResponseCount*1, responseOffset+self.maxResponseCount*1 + responseCount)]
                correctPositions   = [int(float(row[i])) for i in range(responseOffset+ self.maxResponseCount*2, responseOffset+self.maxResponseCount*2 + responseCount)]
                targetIndex        = [int(float(row[i])) for i in range(responseOffset+ self.maxResponseCount*3, responseOffset+self.maxResponseCount*3 + responseCount)]
                distractorIndex    = [int(float(row[i])) for i in range(responseOffset+ self.maxResponseCount*4, responseOffset+self.maxResponseCount*4 + responseCount)]
                correctionTrial    = [int(float(row[i])) for i in range(responseOffset+ self.maxResponseCount*5, responseOffset+self.maxResponseCount*5 + responseCount)]
            except ValueError:
                print animalID
                print groupID
                print scheduleName
                print scheduleDate
                continue
            
            rtOffset = responseOffset + 6*self.maxResponseCount
            reactionTimes = [float(row[i]) for i in range(rtOffset,rtOffset + rtCount)]
            
            # Collect additional data in separate lists. If...else checks handles situtations
            # in which there is no data recorded for a specific measure
            collectOffset = rtOffset + self.maxRTCount
            if self.maxCollectCount == 0:
                collectOffset = collectOffset + 1
                collectTimes = []
            else:
                collectTimes =[float(row[i]) for i in range(collectOffset, collectOffset + collectCount)]
            
            screenpokeOffset = collectOffset + self.maxCollectCount
            if self.maxScreenpokeCount == 0:
                screenpokeOffset = screenpokeOffset + 1
                screenpokeTimes = []
            else:
                screenpokeTimes = [float(row[i]) for i in range(screenpokeOffset, screenpokeOffset + screenpokeCount)]
            
            frontbeamOffset = screenpokeOffset + self.maxScreenpokeCount
            if self.maxFrontbeamCount == 0:
                frontbeamTimes = []
                frontbeamOffset = frontbeamOffset + 1
            else:
                frontbeamTimes = [float(row[i]) for i in range(frontbeamOffset, frontbeamOffset + frontbeamCount)]
            
            backbeamOffset = frontbeamOffset + self.maxFrontbeamCount
            if self.maxBackbeamCount == 0:
                backbeamOffset = backbeamOffset + 1
                backbeamTimes = []
            else:
                backbeamTimes  = [float(row[i]) for i in range(backbeamOffset, backbeamOffset + backbeamCount)]
            
            rewardpokeOffset = backbeamOffset + self.maxBackbeamCount
            rewardpokeTimes = [float(row[i]) for i in range(rewardpokeOffset, rewardpokeOffset + rewardpokeCount)]
            
            # responses are initially coded ass 19 for correct and 10 for incorrect. We recode this into 0 and 1
            # for incorrect and correct responses respetively
            answerPositions = [0]*responseCount
            correctResponses = 0
            for i in range(0,responseCount):
                if responseEvaluations[i] == 19:
                    responseEvaluations[i] = 1
                    answerPositions[i] = correctPositions[i]
                    correctResponses = correctResponses + 1
                else:
                    responseEvaluations[i] = 0
                    if correctPositions[i] == 1:
                        answerPositions[i] = 2
                    else:
                        answerPositions[i] = 1
                        
            # We create a list in which reward collection times are matched at the position where
            # a correct response occurs. In the case where a trial is started but the session ends
            # before the trial is completed we will not be able to collect a collect time
            rewardCollectionTimes = [0]*responseCount
            correctCounter = 0
            for i in range(0,responseCount):
                if correctCounter == collectCount:
                    break
                if responseEvaluations[i] == 1:
                    rewardCollectionTimes[i] = collectTimes[correctCounter]
                    correctCounter = correctCounter + 1
            
            # During the ISI, we count number of back and frontbeam crosses,
            # screen pokes and reward pokes
            isiScreenpokeCount = [0]*responseCount
            isiFrontbeamCount  = [0]*responseCount
            isiBackbeamCount   = [0]*responseCount
            isiRewardpokeCount = [0]*responseCount
            for i in range(1,responseCount):
                isiStart = responseTimestamps[i-1] + rewardCollectionTimes[i]
                isiEnd   = responseTimestamps[i] - reactionTimes[i]
                
                isiScreenpokeCount[i] = sum(1 for i in range(0,screenpokeCount) if screenpokeTimes[i] > isiStart and screenpokeTimes[i] < isiEnd)               
                isiFrontbeamCount[i] = sum(1 for i in range(0,frontbeamCount) if frontbeamTimes[i] > isiStart and frontbeamTimes[i] < isiEnd)
                isiBackbeamCount[i] = sum(1 for i in range(0,backbeamCount) if backbeamTimes[i] > isiStart and backbeamTimes[i] < isiEnd)
                isiRewardpokeCount[i] = sum(1 for i in range(0,rewardpokeCount) if rewardpokeTimes[i] > isiStart and rewardpokeTimes[i] < isiEnd)
                
            
            # Save the result to a file
            outputPath = self.dataPath + '\\' + scheduleName + '\\' + groupID + '\\' + animalID
            if not os.path.exists(outputPath):
                os.makedirs(outputPath)       
            outputFile = outputPath + '\\' + scheduleDate + '.csv'
            fileObject = open(outputFile, 'w')
        
            fileObject.write("trial,targetIdx,distracterIdx,correctResponse,correctPosition,responsePosition,"+
                             "correctionTrial,responseTimestamp,reactionTime,rewardCollectionTime,isiScreenpokes,"+
                             "isiFrontbeamCounts,isiBackbeamCounts, isiRewardpokeCounts" + "\n")
            for i in range(0,responseCount):
                fileObject.write(str(i+1) + ',' + str(targetIndex[i]) + ',' + str(distractorIndex[i]) + ',' +
                    str(responseEvaluations[i]) + ',' + str(correctPositions[i]) + ',' + str(answerPositions[i]) + ',' +
                    str(correctionTrial[i]) + ',' + str(responseTimestamps[i]) + ',' + str(reactionTimes[i]) + ',' + 
                    str(rewardCollectionTimes[i]) + ',' + str(isiScreenpokeCount[i]) + ',' +
                    str(isiFrontbeamCount[i]) + ',' + str(isiBackbeamCount[i]) + ',' + str(isiRewardpokeCount[i]) + '\n')
                    
            fileObject.close()
    
    # Gets the date string for when the experiment was conducted and transforms it into a format
    # that can be used as a filename
    def ParseDateString(self,dateString):
        dateComponents = dateString.split('/')
        month = dateComponents[0]
        day = dateComponents[1]
        year = dateComponents[2][0:4]
        if len(month) == 1:
            month = '0' + month
        if len(day) == 1:
            day = '0' + day
                
        parsedDate = year+month+day
        return parsedDate