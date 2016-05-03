import Tkinter as Tk
import tkFileDialog 
import AbetObject as AO


abetObject = AO.AbetObject()

########################
# GUI callback functions
########################
def LoadButtonCallback():
    global filenameEntry
    global availableSchedules
    
    filename = tkFileDialog.askopenfilename(defaultextension = '.csv',filetypes=[('Csv file','*.csv')])
    
    if not filename:
        return
        
    filenameEntry.insert(0,filename)    
    abetObject.ReadFile(filename)
    if abetObject.isGood:
        PopulateListbox()

def PopulateListbox():
    global availableSchedulesdir
    global selectedSchedules
    
    availableSchedules.delete(0,Tk.END)
    selectedSchedules.delete(0,Tk.END)
    
    scheduleList = abetObject.GetAvailableSchedules()
    for schedule in scheduleList:
        availableSchedules.insert(Tk.END,schedule)
        
def ProcessButtonCallback():
    if abetObject.isGood:
        abetObject.ParseFile()
    pass

################
# GUI Components
################    
appRoot = Tk.Tk()
appRoot.title('Abet conversion tool')
appRoot.geometry('400x230')
appRoot.resizable(width = Tk.FALSE, height = Tk.FALSE)
topFrame = Tk.Frame(appRoot)
middleFrame =Tk. Frame(appRoot)
bottomFrame = Tk.Frame(appRoot)

topFrame.pack(side = Tk.TOP, expand = Tk.YES, fill = Tk.X)
middleFrame.pack(expand = Tk.YES, fill = Tk.X)
bottomFrame.pack(side = Tk.BOTTOM)

filenameLabel = Tk.Label(topFrame, text="File ")
filenameEntry = Tk.Entry(topFrame)
filenameButton = Tk.Button(topFrame, text ="Load", command = LoadButtonCallback)
filenameLabel.pack(side = Tk.LEFT,)
filenameEntry.pack(side=Tk.LEFT,expand = Tk.YES, fill = Tk.X)
filenameButton.pack(side = Tk.RIGHT)

availableSchedules = Tk.Listbox(middleFrame)
selectedSchedules  = Tk.Listbox(middleFrame)
availableSchedules.pack(side = Tk.LEFT,expand = Tk.YES, fill = Tk.X)
selectedSchedules.pack(side = Tk.RIGHT,expand = Tk.YES, fill = Tk.X)

processButton = Tk.Button(bottomFrame, text="Process", command = ProcessButtonCallback)
processButton.pack()

appRoot.mainloop()

