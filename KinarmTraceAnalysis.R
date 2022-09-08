require(ggplot2)
require(psych)

setwd("~/Downloads/AHA_piloting/AHA_PilotingBehavior/Pilot04/Trace")
files = list.files()
data = read.csv(files[8], header = T)

bins = rep(0,18)
endbins = rep(0,18)
bins = which(data$Event.name == "Hand Velocity Reached", arr.ind=TRUE)
endbins = which(data$Event.name == "Trial is over", arr.ind=TRUE)


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



df$TARGET_X = as.numeric(df$TARGET_X)
df$TARGET_Y = as.numeric(df$TARGET_Y)
df$Right..Hand.position.X = as.numeric(df$Right..Hand.position.X)
df$Right..Hand.position.Y = as.numeric(df$Right..Hand.position.Y)

df$distance = sqrt((df$TARGET_X - df$Right..Hand.position.X)^2 +(df$TARGET_Y - df$Right..Hand.position.Y)^2 )

tapply(df$distance, list(df$trial),mean)


if(!exists("masterdata")){
  masterdata = df
}
if(exists("masterdata")){
  masterdata = rbind(masterdata, df)
}

write.csv(masterdata,"MasterData_Pilot04.csv", row.names = F)

mdata = read.csv("MasterData_pilot04.csv", header = T)

sumdat = aggregate(mdata$distance, by = list(mdata$trial, mdata$vision, mdata$limb), mean)

ggplot(data = sumdat, aes(x = sumdat$Group.3, y = sumdat$x, color = sumdat$Group.2)) + geom_dotplot(binaxis='y', stackdir='center', dotsize=1)

