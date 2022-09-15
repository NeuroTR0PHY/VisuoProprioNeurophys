#Load packages
require(ggplot2)
require(psych)

#set directory (need to change location), load all files, righ tnow have to change the value in files[x], but will make into a loop
setwd("~/Downloads/AHA_piloting/AHA_PilotingBehavior/Pilot04/Trace")
files = list.files()
data = read.csv(files[8], header = T)

bins = rep(0,18)
endbins = rep(0,18)
bins = which(data$Event.name == "Hand Velocity Reached", arr.ind=TRUE) #find start rows
endbins = which(data$Event.name == "Trial is over", arr.ind=TRUE) #find end rows

#need to change, used to label data ###will need to update to automatically loop through all participants
Limb = "Right" 
Vision = "VS"

df = data[bins[1]:endbins[1],]
df$trial = 1
df$vision = Vision
df$limb = Limb
for(i in 2:18){
  df2 = data[bins[i]:endbins[i],]
  df2$trial = i
  df2$vision = Vision
  df2$limb = Limb
  df = rbind(df, df2)
}


#determine distance and add to data frame
df$TARGET_X = as.numeric(df$TARGET_X)
df$TARGET_Y = as.numeric(df$TARGET_Y)
df$Right..Hand.position.X = as.numeric(df$Right..Hand.position.X)
df$Right..Hand.position.Y = as.numeric(df$Right..Hand.position.Y)

#actually calculates distance
df$distance = sqrt((df$TARGET_X - df$Right..Hand.position.X)^2 +(df$TARGET_Y - df$Right..Hand.position.Y)^2 )

#just to visualize the mean values per trial, should be 18 trials
tapply(df$distance, list(df$trial),mean)

#creates and then updates the masterdata dataframe
if(!exists("masterdata")){
  masterdata = df
}
if(exists("masterdata")){
  masterdata = rbind(masterdata, df)
}

#write all of the data to a .csv file
write.csv(masterdata,"MasterData_Pilot04.csv", row.names = F)

#read the .csv file
mdata = read.csv("MasterData_pilot04.csv", header = T)

#aggregate (mean) of error distance
sumdat = aggregate(mdata$distance, by = list(mdata$trial, mdata$vision, mdata$limb), mean)

#plot the data using ggplot
ggplot(data = sumdat, aes(x = sumdat$Group.3, y = sumdat$x, color = sumdat$Group.2)) + geom_dotplot(binaxis='y', stackdir='center', dotsize=1)


