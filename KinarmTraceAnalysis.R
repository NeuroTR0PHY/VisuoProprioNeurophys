#Load packages
require(ggplot2)
require(psych)
require(varhandle)
require(tidyr)
require (plotly)
require(forcats)

#set directory (need to change location), load all files, righ tnow have to change the value in files[x], but will make into a loop
sub = "NYA18"
setwd(paste0("/Volumes/MRIDRIVE/AHA_EEG/AHA_KinarmBehavioral/",sub,"/TRACE"))
files = list.files()

#summary function
## Summarizes data.
## Gives count, mean, standard deviation, standard error of the mean, and confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be summariezed
##   groupvars: a vector containing names of columns that contain grouping variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  library(plyr)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # Rename the "mean" column    
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}

#data = read.csv(files[1], header = T, skip = 247)
#names(data)
#df[which(df$team=='B', arr.ind=TRUE)[1],]
for(x in 1:8){
  if(x < 5 | x == 6){
    data = read.csv(files[x], header = T, skip = 247)
  }
  if(x > 4 & x != 6){
    data = read.csv(files[x], header = T, skip = 249)
  }

  print(paste0("Reading file number: ", x))
  
rowObjects = data$TP.Row[data$TP.Row != ""]
rowObjects2 = rowObjects[check.numeric(rowObjects) == T]
rowObjects = as.numeric(rowObjects2)
  
bins = rep(0,18)
endbins = rep(0,18)
bins = which(data$Event.name == "Hand Velocity Reached", arr.ind=TRUE) #find start rows
endbins = which(data$Event.name == "Trial is over", arr.ind=TRUE) #find end rows

#need to change, used to label data ###will need to update to automatically loop through all participants
Limb = c("Left", "Left", "Left", "Left", "Right", "Right", "Right", "Right")
Vision = c("NV", "VS", "NV", "VS", "NV", "VS", "NV", "VS")
Posture = c("Seat", "Seat", "Stand", "Stand", "Seat", "Seat", "Stand", "Stand")


df = data[bins[1]:endbins[1],]
df$trial = 1
df$vision = Vision[x]
df$limb = Limb[x]
df$posture = Posture[x]
#df$position = "Center"
if(rowObjects[1] < 4){
  df$position = "Center"
}
if(rowObjects[1]> 3 && rowObjects[1] < 7){
  df$position = "Left"
}
if(rowObjects[1] > 6 && rowObjects[1] < 10){
  df$position = "Right"
}
if(rowObjects[1] > 9 && rowObjects[1] < 13){
  df$position = "Center"
}
if(rowObjects[1]> 12 && rowObjects[1] < 16){
  df$position = "Left"
}
if(rowObjects[1] > 15){
  df$position = "Right"
}
for(i in 2:length(bins)){
  df2 = data[bins[i]:endbins[i],]
  df2$trial = i
  df2$vision = Vision[x]
  df2$limb = Limb[x]
  df2$posture = Posture[x]
  if(rowObjects[1] < 4){
    df$position = "Center"
  }
  if(rowObjects[1]> 3 && rowObjects[1] < 7){
    df2$position = "Left"
  }
  if(rowObjects[1] > 6 && rowObjects[1] < 10){
    df2$position = "Right"
  }
  if(rowObjects[1] > 9 && rowObjects[1] < 13){
    df2$position = "Center"
  }
  if(rowObjects[1]> 12 && rowObjects[1] < 16){
    df2$position = "Left"
  }
  if(rowObjects[1] > 15){
    df2$position = "Right"
  }
  #if(i == 2 | i == 3){
  #  df2$position = "Center"
 # }
 # if(i == 4 | i == 5 | i == 6){
  #  df2$position = "Left"
 # }
 # if(i == 7 | i == 8 | i == 9){
   # df2$position = "Right"
  #}
  print(i)
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
}

#write all of the data to a .csv file
write.csv(masterdata,paste0("MasterData_",sub,'.csv'), row.names = F)

#read the .csv file

#mdata = read.csv(paste0("MasterData_",sub,'.csv'), header = T)
mdata = masterdata
#plot raw data for trials
dattest = mdata[mdata$trial == 3 & mdata$posture == "Seat" & mdata$limb == "Right" & mdata$vision == "NV",]
ggplot(data = dattest, aes(x = dattest$Right..Hand.position.X, y = dattest$Right..Hand.position.Y)) + geom_point()

#aggregate (mean) of error distance
sumdat = aggregate(mdata$distance, by = list(mdata$trial, mdata$vision, mdata$limb, mdata$position, mdata$posture), mean)
sumdat$ID = sub
write.csv(sumdat,paste0("AggData_",sub,'.csv'), row.names = F)


#plot the data using ggplot
##Limb X Feedback
sumdat = read.csv(paste0("AggData_",sub,'.csv'), header = T)
plot = ggplot(data = sumdat, aes(x = sumdat$Group.5, y = sumdat$x * 100)) + geom_bar(position = "dodge", stat = "summary")+
  #geom_dotplot(binaxis='y', stackdir='center', dotsize=1) + 
  stat_summary(fun.data=mean_cl_normal, 
               geom="errorbar", color="red", width=0.2) + facet_wrap(~ Group.2 + Group.3) + ylab("Average Error (cm's)") +
  theme_minimal() + 
  theme(text = element_text(size = 18))

ggsave("SingleSubBar_noa02.tiff", plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

##Limb X Posture (NV only): Points
ggplot(data = sumdat[sumdat$Group.2 == "NV",], aes(x = Group.3, y = x, color = Group.5)) + geom_dotplot(binaxis='y', stackdir='center', dotsize=1)

##Limb X Posture (NV only): Bar + SE
sum2 = summarySE(sumdat[sumdat$Group.2 == "NV",], measurevar = 'x', groupvars = c("Group.3", "Group.5"))
ggplot(data = sum2, aes(x = Group.3, y = x, color = Group.5)) + geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=x-se, ymax=x+se), width=.2, position=position_dodge(.9))



#############
#############
#grouped data
#############
#############
#setwd("/Users/nathan/Downloads/AHA_EEG/AHA_KinarmBehavioral/AggData_NB")
rm(dat,dat2)
setwd('/Volumes/BorichLab/NB_AHA_Kinematics/AggData')
files = list.files()
#files = files[1:length(files)]
for(i in 1:length(files)){
  if(!exists("dat")){
    dat = read.csv(files[i], header = T)
  }
  dat2 = read.csv(files[i], header = T)
  print(files[i])
  dat = rbind(dat, dat2)
}

#dat$Group = "NYA"
names(dat) = c("Row", "Feedback", "Limb", "Region", "Posture", "Error", "ID","Group")


sumGroupDat = aggregate(dat$Error, by = list(dat$Feedback, dat$Limb, dat$Region, dat$Posture,  dat$ID, dat$Group), mean)
sumGroupDat$x = sumGroupDat$x*100
workspace = rep("",nrow(sumGroupDat))
sumGroupDat = cbind(sumGroupDat, workspace)
for(i in 1:nrow(sumGroupDat)){
  if(sumGroupDat$Group.2[i] == "Left"){
    if(sumGroupDat$Group.3[i] == "Right"){
      sumGroupDat$workspace[i] = "Distal"
    }
    if(sumGroupDat$Group.3[i] == "Left"){
      sumGroupDat$workspace[i] = "Proximal"
    }
    if(sumGroupDat$Group.3[i] == "Center"){
      sumGroupDat$workspace[i] = "Central"
    }
  }
  if(sumGroupDat$Group.2[i] == "Right"){
    if(sumGroupDat$Group.3[i] == "Right"){
      sumGroupDat$workspace[i] = "Proximal"
    }
    if(sumGroupDat$Group.3[i] == "Left"){
      sumGroupDat$workspace[i] = "Distal"
    }
    if(sumGroupDat$Group.3[i] == "Center"){
      sumGroupDat$workspace[i] = "Central"
    }
  }
}

#sumgroupdat has workspaces
sumGroupDat = sumGroupDat[sumGroupDat$Group.6 == "NYA",]
#sumgroupdat2 collapses across workspace
sumGroupDat2 = aggregate(sumGroupDat$x, by = list(sumGroupDat$Group.1, sumGroupDat$Group.2,  sumGroupDat$Group.4, sumGroupDat$Group.5, sumGroupDat$Group.6), mean)
#sumgroupdat3 collapses across posture
sumGroupDat3 = aggregate(sumGroupDat$x, by = list(sumGroupDat$Group.1, sumGroupDat$Group.2, sumGroupDat$Group.5, sumGroupDat$Group.6), mean)

#a = sumGroupDat[1:16,]
#b = sumGroupDat[18:115,]
#sumGroupDat = rbind(a,b)

###PLOTS###
#Feedback x Limb x Posture
pdat = sumGroupDat2
pdat$Group.1[pdat$Group.1 == "NV"] = "No-Vision"
pdat$Group.1[pdat$Group.1 == "VS"] = "Vision"

#if(pdat$Group.5[1] == "NOA"){
 # linecolor = "red"
#}else{
 # linecolor = "purple"
#}

newplot = ggplot(data = pdat[pdat$Group.2 == "Left",], aes(x = Group.3, y = x)) +
geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5) + 
xlab("Posture") + ylab("Average Error (cm's)") +
facet_grid(rows = vars(Group.1), cols = vars(Group.5)) +
geom_line(aes(group = Group.4)) + 
theme_minimal() + 
theme(text = element_text(size = 18)) + 
xlab("") #+
#ylim(0,3)

newplot + xlab("")

ggsave("/Volumes/BorichLab/IG_Reach/Figures/TargetTracking_group+ind_leftonly.jpeg", plot = newplot, width = 5,
       height = 4,
       units = "in",
       dpi = 300)

newplot = ggplot(data = pdat[pdat$Group.2 == "Left" & pdat$Group.3 == "Seat",], aes(x = Group.5, y = x)) +
  stat_summary(fun = "mean", geom = "bar", position = "dodge", aes(fill = Group.1)) +
  stat_summary(fun.data = "mean_se", geom = "errorbar", width = 0.2, position = position_dodge(width = 0.9)) +
  #geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5) + 
  xlab("Posture") + ylab("Average Error (cm's)") +
  facet_grid(rows = vars(Group.1), cols = vars()) +
  #geom_line(aes(group = Group.4)) + 
  theme_minimal() + 
  theme(text = element_text(size = 18),legend.position="none") + 
  xlab("") +
  scale_fill_manual(values = c("darkgray","lightgray"))
  
#ylim(0,3)

newplot + xlab("")

ggsave("/Volumes/BorichLab/IG_Reach/Figures/TargetTracking_groups_leftonly_seated.jpeg", plot = newplot, width = 5,
       height = 4,
       units = "in",
       dpi = 300)


testdat = pdat[pdat$Group.2 == "Right",]
p = pairwise.t.test(testdat$x,interaction(testdat$Group.1, testdat$Group.3),paired = T, p.adjust.method = "none", alternative = "less")
p


ggsave("AvgErrorNYA_VSonly.tiff", plot = newplot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

### #1.1 vis vs no vis, seated, R
seated_right = sumGroupDat2[sumGroupDat2$Group.2 == "Right" & sumGroupDat2$Group.3 == "Seat",]

newplot = ggplot(data = seated_right, aes(x = fct_rev(factor(Group.1)), y = x)) +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5) + 
  xlab("Posture") + ylab("Average Error (cm's)") +
  #facet_wrap(~ Group.1 + Group.2) +
  geom_line(aes(group = Group.4)) + 
  theme_minimal() + 
  theme(text = element_text(size = 18)) + 
  xlab("") + stat_summary(fun.y=mean, geom="point", shape=16,
                          size=3, color="red")

newplot + xlab("")
p = pairwise.t.test(seated_right$x,seated_right$Group.1,paired = T, p.adjust.method = "none", alternative = "less")
p

ggsave("AvgErrorNYA_VS-NV_seated_R.jpg", plot = newplot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

### #2.1 vis vs no vis, seated, L
seated_left = sumGroupDat2[sumGroupDat2$Group.2 == "Left" & sumGroupDat2$Group.3 == "Seat",]

newplot = ggplot(data = seated_left, aes(x = fct_rev(factor(Group.1)), y = x)) +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5) + 
  xlab("Posture") + ylab("Average Error (cm's)") +
  #facet_wrap(~ Group.1 + Group.2) +
  geom_line(aes(group = Group.4)) + 
  theme_minimal() + 
  theme(text = element_text(size = 18)) + 
  xlab("") + stat_summary(fun.y=mean, geom="point", shape=16,
                            size=3, color="red")

newplot + xlab("")
p = pairwise.t.test(seated_left$x,seated_left$Group.1,paired = T, p.adjust.method = "none", alternative = "less")
p

ggsave("AvgErrorNYA_VS-NV_seated_L.jpg", plot = newplot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

### #3a sit vs stand right only
posture_right = sumGroupDat2[sumGroupDat2$Group.2 == "Right",]

newplot = ggplot(data = posture_right, aes(x = Group.3, y = x)) +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5, position = "dodge") + 
  xlab("Posture") + ylab("Average Error (cm's)") +
  facet_wrap(~ fct_rev(factor(Group.1))) +
  geom_line(aes(group = Group.4)) + 
  theme_minimal() + 
  theme(text = element_text(size = 18)) + 
  xlab("") + stat_summary(fun.y=mean, geom="point", shape=16,
                            size=3, color="red")

newplot + xlab("")
p = pairwise.t.test(posture_right$x,interaction(posture_right$Group.1, posture_right$Group.3),paired = T, p.adjust.method = "none", alternative = "less")
p

tapply(posture_right$x, list(posture_right$Group.1, posture_right$Group.3), mean)

ggsave("AvgErrorNYA_VS-NV_posture_R.jpg", plot = newplot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

### #4a sit vs stand left only
posture_left = sumGroupDat2[sumGroupDat2$Group.2 == "Left",]

newplot = ggplot(data = posture_left, aes(x = Group.3, y = x)) +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5, position = "dodge") + 
  xlab("Posture") + ylab("Average Error (cm's)") +
  facet_wrap(~ fct_rev(factor(Group.1))) +
  geom_line(aes(group = Group.4)) + 
  theme_minimal() + 
  theme(text = element_text(size = 18)) + 
  xlab("") + stat_summary(fun.y=mean, geom="point", shape=16,
                          size=3, color="red")

newplot + xlab("")
p = pairwise.t.test(posture_left$x,interaction(posture_left$Group.1, posture_left$Group.3),paired = T, p.adjust.method = "none", alternative = "less")
p

tapply(posture_left$x, list(posture_left$Group.1, posture_left$Group.3), mean)
tapply(sumGroupDat2$x, list(sumGroupDat2$Group.1, sumGroupDat2$Group.3, sumGroupDat2$Group.2), mean)

ggsave("AvgErrorNYA_VS-NV_posture_L.jpg", plot = newplot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

### other view
vision = sumGroupDat2[sumGroupDat2$Group.1 == "VS",]

newplot = ggplot(data = vision, aes(x = Group.3, y = x)) +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5, position = "dodge") + 
  xlab("Posture") + ylab("Average Error (cm's)") +
  facet_wrap(~ Group.2) +
  geom_line(aes(group = Group.4)) + 
  theme_minimal() + 
  theme(text = element_text(size = 18)) + 
  xlab("") + stat_summary(fun.y=mean, geom="point", shape=16,
                          size=3, color="red")

newplot + xlab("")

ggsave("AvgErrorNYA_posture_VS.jpg", plot = newplot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

novision = sumGroupDat2[sumGroupDat2$Group.1 == "NV",]

newplot = ggplot(data = novision, aes(x = Group.3, y = x)) +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5, position = "dodge") + 
  xlab("Posture") + ylab("Average Error (cm's)") +
  facet_wrap(~ Group.2) +
  geom_line(aes(group = Group.4)) + 
  theme_minimal() + 
  theme(text = element_text(size = 18)) + 
  xlab("") + stat_summary(fun.y=mean, geom="point", shape=16,
                          size=3, color="red")

newplot + xlab("")

ggsave("AvgErrorNYA_posture_NV.jpg", plot = newplot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

###for loop single subject example###
subs = unique(pdat$Group.4)

for(i in 1:length(subs)){
  pdat = sumGroupDat2
  pdat$Group.1[pdat$Group.1 == "NV"] = "No-Vision"
  pdat$Group.1[pdat$Group.1 == "VS"] = "Vision"
  pdat = pdat[pdat$Group.4 == subs[i],]
  
  #print(pdat)
  
  plot = ggplot(data = pdat, aes(x = Group.3, y = x)) +
    geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5) + 
    xlab("Posture") + ylab("Average Error (cm's)") +
    facet_wrap(~ Group.1 + Group.2) +
  geom_line(aes(group = Group.4))   + 
    theme_minimal() + 
    theme(text = element_text(size = 18)) + 
    xlab("") +
    ggtitle(subs[i]) + 
    ylim(0,6)
  
  ggsave(paste0("/Users/nathan/Downloads/AHA_EEG/AHA_KinarmBehavioral/TestPlots/","AvgError", subs[i], ".tiff"), plot = plot, width = 5,
         height = 5,
         units = "in",
         dpi = 600)
}


#Vis only Posture x Limb
pdat2 = pdat[pdat$Group.1 == "Vision",]
pdat2$Group.2 = as.factor(pdat2$Group.2)
plot = ggplot(data = pdat2, aes(x = Group.3, y = x)) +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5) + xlab("Posture") + ylab("Average Error (cm's)") +
  facet_wrap(~ Group.2 ) +
  # stat_summary(aes(group = Group.2),fun=mean, geom="point", size=2, position=position_dodge(0),color = "red") +
  geom_line(aes(group = Group.4)) + ylim(0,2.5) + theme_minimal() + theme(text = element_text(size = 18))

ggsave("AvgErrorNYA_VSonly.tiff", plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

# limb x feedback
pdat3 = sumGroupDat2
pdat3$Group.1[pdat3$Group.1 == "NV"] = "No-Vision"
pdat3$Group.1[pdat3$Group.1 == "VS"] = "Vision"
pdat3 = pdat3[pdat3$Group.3 == "Seat",]
plot = ggplot(data = pdat3, aes(x = rev(Group.1), y = x)) +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5) + xlab("Sensory Feedback of Limb") + ylab("Seated Average Error (cm's)") +
  facet_wrap(~ Group.2 ) +
  # stat_summary(aes(group = Group.2),fun=mean, geom="point", size=2, position=position_dodge(0),color = "red") +
  geom_line(aes(group = Group.4))  + theme_minimal() + theme(text = element_text(size = 18)) + xlab("") 

ggsave("AvgErrorNYA_FeedbackOnly.tiff", plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

p = pairwise.t.test(pdat3$x,interaction(pdat3$Group.1, pdat3$Group.2),paired = T, p.adjust.method = "none", alternative = "less")
p




#feedback x limb
plot = ggplot(data = pdat3, aes(x = Group.2, y = x)) +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5) + xlab("Limb") + ylab("Seated Average Error (cm's)") + 
  facet_wrap(~ Group.1 ) +
  # stat_summary(aes(group = Group.2),fun=mean, geom="point", size=2, position=position_dodge(0),color = "red") +
  geom_line(aes(group = Group.4))  + theme_minimal() + theme(text = element_text(size = 18)) + xlab("") 

plot
#plot_ly(data = pdat3,x = ~Group.2, y = ~x, type = "scatter", color = ~Group.4,  mode="lines+markers")

ggsave("AvgErrorNYA_FeedbackOnlyByLimb.tiff", plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

p = pairwise.t.test(pdat3$x,interaction(pdat3$Group.1, pdat3$Group.2),paired = T, p.adjust.method = "none", alternative = "less")
p

#Visual Reliance x Limb
widepdat3 = spread(pdat3,Group.1,x)
widepdat3$delta = widepdat3$`No-Vision` - widepdat3$Vision
widepdat3 = widepdat3[widepdat3$Group.5 == "NYA",]

plot = ggplot(data = widepdat3, aes(x = Group.2, y = delta)) +
  geom_hline(yintercept=0,linetype=2, alpha = 0.75)+
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5) + xlab("Limb") + ylab(expression(paste("Seated Visual Reliance (cm's)"))) +
 geom_line(aes(group = Group.4)) + theme_minimal() + theme(text = element_text(size = 18)) + xlab("")

ggsave("AvgErrorNYA_VisualReliancebyLimb.tiff", plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

test = widepdat3[widepdat3$Group.5 == "NYA",]
t.test(test$delta ~ test$Group.2, paired = T)

##Delta Posture
require(tidyr)
widedat = spread(pdat,Group.3,x)
widedat$delta = widedat$Stand - widedat$Seat

plot = ggplot(data = widedat[widedat$Group.5 == "NYA",], aes(x = Group.2, y = delta)) +
   geom_hline(yintercept=0,linetype=2, alpha = 0.75)+
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5) + xlab("Limb") + ylab(expression(paste(Delta,"Stand-Sit Error (cm's) "))) +
  facet_wrap(~ Group.1 ) + theme(text = element_text(size = 20)) + theme_minimal() + theme(text = element_text(size = 18)) + xlab("") #+
  # stat_summary(aes(group = Group.2),fun=mean, geom="point", size=2, position=position_dodge(0),color = "red") +
  geom_line(aes(group = Group.4)) + theme_minimal() + theme(text = element_text(size = 18)) + xlab("")
  


ggsave("AvgErrorNYADelta.tiff", plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

p = pairwise.t.test(widedat$delta,interaction(widedat$Group.1, widedat$Group.2),paired = T, p.adjust.method = "none", alternative = "less")
p

#diff in vision conditions: limb x Posture
widedat2 = spread(pdat,Group.1,x)
widedat2$delta = widedat2$`No-Vision` - widedat2$Vision

plot = ggplot(data = widedat2, aes(x = Group.3, y = delta)) +
  geom_hline(yintercept=0,linetype=2, alpha = 0.75)+
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5) + xlab("") + ylab(expression(paste("Visual Reliance (cm's) "))) +
  facet_wrap(~ Group.2 ) +
# stat_summary(aes(group = Group.2),fun=mean, geom="point", size=2, position=position_dodge(0),color = "red") +
geom_line(aes(group = Group.4)) + theme_minimal()  + theme(text = element_text(size = 18)) + xlab("")

ggsave("AvgErrorNYADeltaFeedback.tiff", plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

p = pairwise.t.test(widedat2$delta,interaction(widedat2$Group.2, widedat2$Group.3),paired = T, p.adjust.method = "none", alternative = "less")
p

##correlation between visual reliance (NV - VS)  and standNV - seatNV (n=28) 
widedat4 = widedat[widedat$Group.1 == "No-Vision",] #for posture delta
widedat5 =  widedat2[widedat2$Group.3 == "Seat",] #widepdat3 #for visual reliance
wide_cor = cbind(widedat4, widedat5$delta)
names(wide_cor) = c("FBack", "Limb", "ID","Group","Seat", "Stand","StandImprove","VisualReliance")


plot = ggplot(data = wide_cor, aes(x = VisualReliance, y = StandImprove, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
   theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Seated Visual Reliance (cm's)"))) + ylab(expression(paste("NV", Delta,"Stand-Sit Error (cm's) "))) 


ggsave("VisReliancecorrelation.tiff", plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

left = wide_cor[wide_cor$Limb == "Left",]
right = wide_cor[wide_cor$Limb == "Right",]
cor.test(left$VisualReliance, left$StandImprove)
cor.test(right$VisualReliance, right$StandImprove)

ggsave("AvgErrorNYADeltaFeedback.tiff", plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

#Workspaces
sumGroupDat4 = aggregate(sumGroupDat$x, by = list(sumGroupDat$Group.1, sumGroupDat$Group.2, sumGroupDat$Group.4, sumGroupDat$workspace, sumGroupDat$Group.5), mean)
plot = ggplot(data = sumGroupDat4, aes(x = Group.4, y = x)) +
  geom_hline(yintercept=0,linetype=2, alpha = 0.75)+
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.75) + xlab("Posture") + ylab(expression(paste("Average Error (cm's) "))) +
  facet_wrap(~ Group.1 + Group.2 ) +theme_minimal() + theme(text = element_text(size = 18)) + xlab("")
  # stat_summary(aes(group = Group.2),fun=mean, geom="point", size=2, position=position_dodge(0),color = "red") +
  #geom_line(aes(group = Group.5)) + theme(text = element_text(size = 20))  

ggsave("Workspace.tiff", plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

  x = sumGroupDat4[sumGroupDat4$Group.4 != "Central",]
x = x[x$Group.2 == "Left",]
p = pairwise.t.test(x$x,interaction(x$Group.3, x$Group.4),paired = T, p.adjust.method = "none", alternative = "less")
p

ggsave("AvgErrorNYADeltaFeedback.tiff", plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)


#is there a sign diff in delta between right and left
test = widedat2
p = pairwise.t.test(test$delta,interaction(test$Group.2, test$Group.3),paired = T, p.adjust.method = "none", alternative = "less")
p
tapply(test$delta, list(test$Group.1, test$Group.2), mean)


sum3 = summarySE(pdat, measurevar = 'x', groupvars = c("Group.1","Group.2","Group.3", "Group.5"))
ggplot(data = sum3, aes(x = Group.3, y = x, fill = Group.5)) +
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=x-sd, ymax=x+sd), width=.2, position=position_dodge(.9)) +
  facet_wrap(~ Group.1 + Group.2 ) +
  xlab("Limb") + ylab("Error (cm's)") +  ggtitle("Kinarm Trace Task Error")
  
#need to calculate whether something is center, or across the body
pdat_left = pdat[pdat$Group.2 == "Left",]
pdat_left = pdat_left[pdat_left$Group.5 == "NYA",]
#pdat_left = pdat_left[pdat_left$Group.4 != "NYA09",]
pdat_right = pdat[pdat$Group.2 == "Right",]
pdat_right = pdat_right[pdat_right$Group.5 == "NYA",]

p = pairwise.t.test(pdat_left$x,interaction(pdat_left$Group.1, pdat_left$Group.3),paired = T, p.adjust.method = "none", alternative = "less")
p

p = pairwise.t.test(pdat_right$x,interaction(pdat_right$Group.1, pdat_right$Group.3),paired = T, p.adjust.method = "none", alternative = "less")
p

nv_dat = pdat[pdat$Group.1 == "NV" & pdat$Group.2 == "Left",]
vs_dat = pdat[pdat$Group.1 == "VS",]
t.test(nv_dat$x ~ nv_dat$Group.3, paired=T)
t.test(vs_dat$x ~ vs_dat$Group.3, paired=T)

write.csv(pdat, "TraceGroupExport.csv")


###############################
####TRACE ERSP ANALYSES###

###single subject merge
#set directory (need to change location), load all files, righ tnow have to change the value in files[x], but will make into a loop
sub = "NYA14"
setwd(paste0("/Users/nathan/Documents/NB_EEG_AHA/",sub,"/ERSP"))
files = list.files()
Limb = c(rep("Left", 56), rep("Right", 56))
Vision = c(rep("NV",28), rep("VS",28),rep("NV",28), rep("VS",28))
Posture = c(rep("Seat",14), rep("Stand",14),rep("Seat",14), rep("Stand",14),rep("Seat",14), rep("Stand",14),rep("Seat",14), rep("Stand",14))
elecs = c("AF3", "AF4", "CP1_2", "CP3", "CP4" , "CPZ", "CZ", "FPZ", "O1", "O2", "OZ", "P3", "P4", "PZ")
Electrode = c(rep(elecs,8))

for(x in 1:length(files)){
  ersp1 = read.csv(files[x], header =F)
  ersp1$freq = seq(.75,50, by =0.25)
  ersp1$Limb = Limb[x]
  ersp1$Vision = Vision[x]
  ersp1$Posture = Posture[x]
  ersp1$ID = sub
  ersp1$Electrode = Electrode[x]

  
  #average across time
  ersp1$avgersp = rowMeans(ersp1[,1:200])
  ersp2 = ersp1[,201:207]
  alpha = ersp2[ersp2$freq > 7.5 & ersp2$freq < 12,]
  alpha$band = "alpha"
  lowbeta = ersp2[ersp2$freq > 13 & ersp2$freq < 16,]
  lowbeta$band = "lowbeta"
  midbeta = ersp2[ersp2$freq > 17 & ersp2$freq < 20,]
  midbeta$band = "midbeta"
  highbeta = ersp2[ersp2$freq > 21 & ersp2$freq < 30,]
  highbeta$band = "highbeta"
  beta = ersp2[ersp2$freq > 13 & ersp2$freq < 30,]
  beta$band = "beta"
  bands1 = rbind(alpha,beta,lowbeta,midbeta,highbeta)

  
  if(!exists("ersp")){
    ersp = ersp1
  }else{
    ersp = rbind(ersp,ersp1)
  }
  
  if(!exists("bands")){
    bands = bands1
  }else{
    bands = rbind(bands,bands1)
  }
  
  
}

write.csv(ersp,paste0("/Users/nathan/Documents/NB_EEG_AHA/GroupedDataFull/",sub,"_erspMerged.csv"))
rm(ersp)
write.csv(bands,paste0("/Users/nathan/Documents/NB_EEG_AHA/GroupedDataBands/",sub,"_bandsMerged.csv"))
rm(bands)

##grouped analysis##
##full##
require(ggplot2)
require(psych)
require(varhandle)
require(tidyr)
setwd("~/Documents/NB_EEG_AHA/GroupedDataFull")
files = list.files()
for(x in 1:length(files)){
  tempdat2 = read.csv(files[x],header=T)
  if(!exists("tempdat")){
    tempdat = tempdat2
  }else{
    tempdat = rbind(tempdat, tempdat2)
  }
}

fulldata = tempdat
rm(tempdat)
require(tidyr)

test = gather(fulldata, time, erspValue, V1:V200)
t1 = read.csv("/Users/nathan/Documents/NB_EEG_AHA/times.csv", header=F)
t2 = t1$V1

values = rep(t2,each=length(test$X)/200)
test$time = values

#write.csv(test,"fulldata.csv")

#if it exists, needs to be recreated if more subjects added
#test = read.csv("/Users/nathan/Documents/NB_EEG_AHA/fulldata.csv", header = T)

#######Differences within subject##########
#differences per subject for Vision
testFullNV = test[test$Vision == "NV",]
testFullVS = test[test$Vision == "VS",]
VisWide = data.frame(testFullVS, testFullNV[10])
VisWide$VS_NV = VisWide$erspValue - VisWide$erspValue.1
VisWide$NV_VS = VisWide$erspValue.1 - VisWide$erspValue
subjectaggVis = aggregate(cbind(VisWide$VS_NV, VisWide$NV_VS), by = list(VisWide$freq, VisWide$Limb, VisWide$Vision, VisWide$Posture, VisWide$Electrode, VisWide$time), mean)
names(subjectaggVis) = c("Frequency", "Limb", "Vision", "Posture", "Electrode", "Time", "VS_NV", "NV_VS")


hand = c("Right", "Left")
elect = c("CP3", "CP4", "CPZ", "O1", "O2", "OZ", "AF3", "AF4", "FPZ", "P3", "P4", "PZ", "CZ")
pos = c("Seat", "Stand")
for(h in 1:length(hand)){
  for(e in 1:length(elect)){
    for(p in 1:length(pos)){
      subjectDataVis = subjectaggVis[subjectaggVis$Limb == hand[h] & subjectaggVis$Posture == pos[p] & subjectaggVis$Electrode == elect[e],]
      min(subjectDataVis$Stand_Sit); max(subjectDataVis$Stand_Sit)
      
      title = paste0("SubDelta_",elect[e],": ",hand[h],", ", pos[p], ", VS - NV")
      plot = ggplot(data = subjectDataVis, aes(x = Time, y = Frequency)) +
        geom_tile(aes( fill = VS_NV)) + scale_fill_gradientn(colours=topo.colors(12), limits=c(-3,3)) +
        theme_minimal() + theme(text = element_text(size = 18)) + xlab("") + ylab("Frequency (Hz)") #+ ggtitle(title)
      
      plot
      
      ggsave(paste0("/Users/nathan/Documents/NB_EEG_AHA/ERSP_plots/VisDiffs/" ,title, ".tiff"), plot = plot, width = 5,
             height = 5,
             units = "in",
             dpi = 600)
      
      title = paste0("SubDelta_",elect[e],": ",hand[h],", ", pos[p], ", NV - VS")
      plot = ggplot(data = subjectDataVis, aes(x = Time, y = Frequency)) +
        geom_tile(aes( fill = NV_VS)) + scale_fill_gradientn(colours=topo.colors(12), limits=c(-3,3)) + 
        theme_minimal() + theme(text = element_text(size = 18)) + xlab("")  + ylab("Frequency (Hz)")#+ ggtitle(title)
      
      plot
      
      ggsave(paste0("/Users/nathan/Documents/NB_EEG_AHA/ERSP_plots/VisDiffs/" ,title, ".tiff"), plot = plot, width = 5,
             height = 5,
             units = "in",
             dpi = 600)
    }
  }
}



#differences per subject for Posture
testFullStand = test[test$Posture == "Stand",]
testFullSit = test[test$Posture == "Seat",]
PosWide = data.frame(testFullStand, testFullSit[10])
PosWide$Stand_Sit = PosWide$erspValue - PosWide$erspValue.1
PosWide$Sit_Stand = PosWide$erspValue.1 - PosWide$erspValue
subjectaggPos = aggregate(cbind(PosWide$Stand_Sit, PosWide$Sit_Stand), by = list(PosWide$freq, PosWide$Limb, PosWide$Vision, PosWide$Posture, PosWide$Electrode, PosWide$time), mean)
names(subjectaggPos) = c("Frequency", "Limb", "Vision", "Posture", "Electrode", "Time", "Stand_Sit", "Sit_Stand")


hand = c("Right", "Left")
elect = c("CP3", "CP4", "CPZ", "O1", "O2", "OZ", "AF3", "AF4", "FPZ", "P3", "P4", "PZ", "CZ")
vis = c("NV", "VS")
for(h in 1:length(hand)){
  for(e in 1:length(elect)){
    for(v in 1:length(vis)){
      subjectDataPos = subjectaggPos[subjectaggPos$Limb == hand[h] & subjectaggPos$Vision == vis[v] & subjectaggPos$Electrode == elect[e],]
      min(subjectDataPos$Stand_Sit); max(subjectDataPos$Stand_Sit)
      
      title = paste0("SubDelta_",elect[e],": ",hand[h],", ", vis[v], ", Stand - Sit")
      plot = ggplot(data = subjectDataPos, aes(x = Time, y = Frequency)) +
        geom_tile(aes( fill = Stand_Sit)) + scale_fill_gradientn(colours=topo.colors(12), limits=c(-3,3)) + 
        theme_minimal() + theme(text = element_text(size = 18)) + xlab("") + ylab("Frequency (Hz)") + labs(fill="dB") +
        theme(axis.title.x=element_blank(),
              axis.text.x=element_blank(),
              axis.ticks.x=element_blank()) #+ ggtitle(title)
      
      plot
      
      ggsave(paste0("/Users/nathan/Documents/NB_EEG_AHA/ERSP_plots/PostureDiffs/" ,title, ".tiff"), plot = plot, width = 5,
             height = 5,
             units = "in",
             dpi = 600)
      
      title = paste0("SubDelta_",elect[e],": ",hand[h],", ", vis[v], ", Sit - Stand")
      plot = ggplot(data = subjectDataPos, aes(x = as.factor(Time), y = Frequency)) +
        geom_tile(aes( fill = Sit_Stand)) + scale_fill_gradientn(colours=topo.colors(12), limits=c(-3,3)) + 
        theme_minimal() + theme(text = element_text(size = 18)) + xlab("") + ylab("Frequency (Hz)") + labs(fill="dB") +
        theme(axis.title.x=element_blank(),
              axis.text.x=element_blank(),
              axis.ticks.x=element_blank()) #+ ggtitle(title)
      
      plot
      
      ggsave(paste0("/Users/nathan/Documents/NB_EEG_AHA/ERSP_plots/PostureDiffs/" ,title, ".tiff"), plot = plot, width = 5,
             height = 5,
             units = "in",
             dpi = 600)
    }
  }
}


#####Plotting conditions, no contrasts##########
fullagg = aggregate(test$erspValue, by = list(test$freq, test$Limb, test$Vision, test$Posture,test$Electrode, test$time), mean)
names(fullagg) = c("Frequency", "Limb", "Vision" , "Posture", "Electrode", "Time", "ERSP")

hand = c("Right", "Left")
elect = c("CP3", "CP4", "CPZ", "O1", "O2", "OZ", "AF3", "AF4", "FPZ", "P3", "P4", "PZ", "CZ")
pos = c("Seat", "Stand")
vis = c("VS", "NV")
for(h in 1:length(hand)){
  for(e in 1:length(elect)){
    for(p in 1:length(pos)){
      for(v in 1:length(vis)){
        subfull = fullagg[fullagg$Electrode == elect[e] & fullagg$Limb == hand[h] & fullagg$Vision == vis[v] & fullagg$Posture == pos[p],]
        mini = min(subfull$ERSP); maxi = max(subfull$ERSP)
        if(mini > maxi){
          scale_val = abs(mini)
        }else{
          scale_val = abs(maxi)
        }
        
        title = paste0("NoContrast_",elect[e],": ",hand[h],", ",pos[p],", " , vis[v])
        plot = ggplot(data = subfull, aes(x = as.factor(Time), y = Frequency)) +
          geom_tile(aes( fill = ERSP)) + scale_fill_gradientn(colours=topo.colors(12), limits=c(-5,5)) +
          theme_minimal() + theme(text = element_text(size = 18)) + xlab("") + ylab("Frequency (Hz)") + labs(fill="dB") +
          theme(axis.title.x=element_blank(),
                axis.text.x=element_blank(),
                axis.ticks.x=element_blank()) #+ ggtitle(title)
        
        plot
        #print("/Users/nathan/Documents/NB_EEG_AHA/ERSP_plots/NoContrast/" ,title, ".tiff")
        ggsave(paste0("/Users/nathan/Documents/NB_EEG_AHA/ERSP_plots/NoContrast/" ,title, ".tiff"), plot = plot, width = 5,
               height = 5,
               units = "in",
               dpi = 600)
        
      }
    }
  }
}




#collapsing across subjects: group subtraction
####### difference between groups, not subject
subDiff = data.frame(subfullA[1:7], subfullB[7])
subDiff$difference = subDiff$ERSP - subDiff$ERSP.1
subDiff$difference2 = subDiff$ERSP.1 - subDiff$ERSP

title = "CP4: R, Seat, NV - VS"
plot = ggplot(data = subDiff, aes(x = Time, y = Frequency)) +
  geom_tile(aes( fill = difference)) + scale_fill_gradientn(colours=topo.colors(12), limits=c(-2,2)) +
  ggtitle(title)

plot

ggsave(paste0("/Users/nathan/Documents/NB_EEG_AHA/ERSP_plots/" ,title, ".tiff"), plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)

title = "CP4: R, Seat, VS - NV"
plot = ggplot(data = subDiff, aes(x = Time, y = Frequency)) +
  geom_tile(aes( fill = difference2)) + scale_fill_gradientn(colours=topo.colors(12), limits=c(-2,2)) +
  ggtitle(title)

plot

ggsave(paste0("/Users/nathan/Documents/NB_EEG_AHA/ERSP_plots/" ,title, ".tiff"), plot = plot, width = 5,
       height = 5,
       units = "in",
       dpi = 600)


###########bands##############
setwd("~/Documents/NB_EEG_AHA/GroupedDataBands")
files = list.files()
for(x in 1:length(files)){
  tempdat2 = read.csv(files[x],header=T)
  if(!exists("tempdat")){
    tempdat = tempdat2
  }else{
    tempdat = rbind(tempdat, tempdat2)
  }
}

bandsdata = tempdat
rm(tempdat)

bandsdataagg = aggregate(bandsdata$avgersp, by = list(bandsdata$Limb, bandsdata$Vision, bandsdata$Posture, bandsdata$ID, bandsdata$band, bandsdata$Electrode), mean)
names(bandsdataagg) = c("Limb", "Vision", "Posture", "ID", "Band", "Electrode","AvgERSP")

subERSP = function(data, leftArmElectrode, rightArmElectrode, band){
  tdataLeft = data[data$Limb == "Left" & data$Electrode == leftArmElectrode[1] & data$Band == band,]
  tdataRight = data[data$Limb == "Right" & data$Electrode == rightArmElectrode[1] & data$Band == band,]
  
  if(length(leftArmElectrode) > 1){
    for(x in 2:length(leftArmElectrode)){
      tdataLeft = rbind(tdataLeft, data[data$Limb == "Left" & data$Electrode == leftArmElectrode[x] & data$Band == band,])
    }
  }

  if(length(rightArmElectrode) > 1){
    for(x in 2:length(rightArmElectrode)){
      tdataRight = rbind(tdataRight, data[data$Limb == "Right" & data$Electrode == rightArmElectrode[x] & data$Band == band,])
    }
  }

  tdata = rbind(tdataLeft, tdataRight)
  return(tdata)
  }

plotdat = subERSP(bandsdataagg, leftArmElectrode = c("CPZ"), rightArmElectrode = c("CPZ"), band = "beta")
plotdat = plotdat[plotdat$ID != "NYA09",]
#plotdat = plotdat[plotdat$Posture == "Seat" & plotdat$Vision == "NV",]

plot = ggplot(data = plotdat, aes(x = Electrode, y = AvgERSP)) +
  geom_dotplot(binaxis='y', stackdir = "center", dotsize=1, alpha = 0.5) + xlab("Limb") + ylab("Average ERSP") +
  facet_wrap(~ Limb) +
  # stat_summary(aes(group = Group.2),fun=mean, geom="point", size=2, position=position_dodge(0),color = "red") +
 geom_line(aes(group = ID))  + 
  theme_minimal() + theme(text = element_text(size = 18)) + xlab("")

plot

plot = ggplot(data = plotdat, aes(x = Posture, y = AvgERSP)) +
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1, alpha = 0.5) + xlab("Limb") + ylab("Average ERSP") +
  facet_wrap(~ Vision + Limb) +
  # stat_summary(aes(group = Group.2),fun=mean, geom="point", size=2, position=position_dodge(0),color = "red") +
  geom_line(aes(group = ID))  + theme_minimal() + theme(text = element_text(size = 18)) + xlab("")

plot

left = plotdat[plotdat$Limb == "Left",]
right = plotdat[plotdat$Limb == "Right",]

pairwise.t.test(left$AvgERSP,interaction(left$Vision, left$Posture),paired = T, p.adjust.method = "none", alternative = "greater")
pairwise.t.test(right$AvgERSP,interaction(right$Vision, right$Posture),paired = T, p.adjust.method = "none", alternative = "greater")

names(widedat2) = c("Limb", "Posture", "ID","Group", "No-Vision", "Vision", "Delta")
names(widedat) = c("Vision","Limb","ID","Group","Seat","Stand", "Delta")


########################
#comparison correlations
plotdat = bandsdataagg[bandsdataagg$Electrode == "CP1_2",]
plotdat = plotdat[plotdat$Band == "beta",]
plotdat = plotdat[plotdat$ID != "NYA09",]

pd_vis_sit = plotdat[plotdat$Vision == "VS" & plotdat$Posture == "Seat",]
pd_nv_sit = plotdat[plotdat$Vision == "NV" & plotdat$Posture == "Seat",]
pd_vis_stand = plotdat[plotdat$Vision == "VS" & plotdat$Posture == "Stand",]
pd_nv_stand = plotdat[plotdat$Vision == "NV" & plotdat$Posture == "Stand",]

seatedVR = widedat2[widedat2$Posture == "Seat",]
standVR = widedat2[widedat2$Posture == "Stand",]

###VISUAL RELIANCE###
#Seated Visual Reliance x ERSP_vis_sit
x = seatedVR
y = pd_vis_sit
mergedcorr = merge(x, y, by=c("Limb", "ID", "Posture"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Visual Reliance (cm's)"))) + ylab("Avg ERSP") +
  ggtitle("Seated Visual Reliance x Seated Vision ERSP ")
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#Seated Visual Reliance x ERSP_vis_stand
x = seatedVR
y = pd_vis_stand
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Visual Reliance (cm's)"))) + ylab("Avg ERSP") +
  ggtitle("Seated Visual Reliance x Seated Vision ERSP ")
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#Seated Visual Reliance x ERSP_novis_sit
x = seatedVR
y = pd_nv_sit
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Visual Reliance (cm's)"))) + ylab("Avg ERSP")# +
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#Seated Visual Reliance x ERSP_novis_stand
x = seatedVR
y = pd_nv_stand
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Visual Reliance (cm's)"))) + ylab("Avg ERSP") +
  ggtitle("Seated Visual Reliance x Seated Vision ERSP ")
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#Standing Visual Reliance x ERSP_vis_sit
x = standVR
y = pd_vis_sit
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Visual Reliance (cm's)"))) + ylab("Avg ERSP") +
  ggtitle("Seated Visual Reliance x Seated Vision ERSP ")
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#Standing Visual Reliance x ERSP_vis_stand
x = standVR
y = pd_vis_stand
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Visual Reliance (cm's)"))) + ylab("Avg ERSP") +
  ggtitle("Seated Visual Reliance x Seated Vision ERSP ")
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#Standing Visual Reliance x ERSP_novis_sit
x = standVR
y = pd_nv_sit
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Visual Reliance (cm's)"))) + ylab("Avg ERSP")# +
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#Standing Visual Reliance x ERSP_novis_stand
x = standVR
y = pd_nv_stand
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Visual Reliance (cm's)"))) + ylab("Avg ERSP") +
  ggtitle("Seated Visual Reliance x Seated Vision ERSP ")
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

################
###StandDelta###
visionStandDelta = widedat[widedat$Vision == "Vision",]
novisStandDelta = widedat[widedat$Vision == "No-Vision",]

#vision delta x pd_vis_sit
x = visionStandDelta
y = pd_vis_sit
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Stand delta"))) + ylab("Avg ERSP") 
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#vision delta x pd_vis_stand
x = visionStandDelta
y = pd_vis_stand
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Stand delta"))) + ylab("Avg ERSP") 
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#vision delta x pd_vnv_sit
x = visionStandDelta
y = pd_nv_sit
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Stand delta"))) + ylab("Avg ERSP") 
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#vision delta x pd_nv_stand
x = visionStandDelta
y = pd_nv_stand
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Stand delta"))) + ylab("Avg ERSP") 
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#no-vision delta x pd_vis_sit
x = novisStandDelta
y = pd_vis_sit
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Stand delta"))) + ylab("Avg ERSP") 
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#no-vision delta x pd_vis_stand
x = novisStandDelta
y = pd_vis_stand
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Stand delta"))) + ylab("Avg ERSP") 
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#no-vision delta x pd_nv_sit
x = novisStandDelta
y = pd_nv_sit
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Stand delta"))) + ylab("Avg ERSP") 
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#no-vision delta x pd_nv_stand
x = novisStandDelta
y = pd_nv_stand
mergedcorr = merge(x, y, by=c("Limb", "ID"))

plot = ggplot(data = mergedcorr, aes(x = Delta, y = AvgERSP, color = Limb)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Stand delta"))) + ylab("Avg ERSP") 
plot

left = mergedcorr[mergedcorr$Limb == "Left",]
right = mergedcorr[mergedcorr$Limb == "Right",]
cor.test(left$Delta, left$AvgERSP)
cor.test(right$Delta, right$AvgERSP)

#a: alpha/beta seated/standing and visual reliance in seated/standing
#b: alpha/beta seated/stading and change in standing error


### MEP's
library(dplyr)

setwd("/Volumes/somrehab-ts/Groups/BorichLab/IG_REACH")
p015_mep = read.csv("P015/Training/ses-S002/eeg/MEP_raw.csv")
p015_mep$ID = "P015"
p015_mep$Group = "NT"
p015_mep <- p015_mep %>%
  mutate(Trial = (row_number() - 1) %/% length(seq(-100, 148, by = 2)) + 1)
p015_mep$Tricep = p015_mep$Tricep * -1

p016_mep = read.csv("P016/Training/ERP_raw.csv")
p016_mep$ID = "P016"
p016_mep$Group = "Stroke"
p016_mep <- p016_mep %>%
  mutate(Trial = (row_number() - 1) %/% length(seq(-100, 148, by = 2)) + 1)


mep_df = rbind(p015_mep, p016_mep)

peak_to_peak_df <- mep_df %>%
  group_by(Trial, Group) %>%
  summarise(peak_to_peak = max(Tricep) - min(Tricep)) %>%
  ungroup()

# Calculate median of peak-to-peak amplitudes for each group
median_amplitudes <- peak_to_peak_df %>%
  group_by(Group) %>%
  summarise(median_peak_to_peak = median(peak_to_peak))

# Label each trial as "High" or "Low" based on group's median split
peak_to_peak_df <- peak_to_peak_df %>%
  left_join(median_amplitudes, by = "Group") %>%
  mutate(Label = ifelse(peak_to_peak > median_peak_to_peak, paste("2_High"), paste("1_Low"))) %>%
  select(-median_peak_to_peak)

# Merge the labels back to the original dataframe
mep_df <- mep_df %>%
  left_join(peak_to_peak_df %>% select(Trial, Group, Label), by = c("Trial", "Group"))

summary_df <- mep_df %>%
  group_by(Time, Group, Label) %>%
  summarise(
    mean_MEP = mean(Tricep),
    sd_MEP = sd(Tricep)
  )

mep_df$Label = as.factor(mep_df$Label)
mep_df$Label <- factor(mep_df$Label, levels = rev(levels(mep_df$Label)))


ggplot(summary_df, aes(x = Time, y = mean_MEP, color = Group, fill = Group)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black", alpha = 0.4) +  # Add vertical dashed line
  geom_ribbon(aes(ymin = mean_MEP - sd_MEP, ymax = mean_MEP + sd_MEP), alpha = 0.5, color = NA) +
  scale_color_manual(values = c("NT" = "goldenrod", "Stroke" = "blue")) +
  scale_fill_manual(values = c("NT" = "lightgoldenrod", "Stroke" = "lightblue")) +
  geom_line(size = 1, alpha = 0.5) +
  labs( x = "Time (ms)", y = "Tricep MEP Amplitude (µV)") +
  theme_minimal()+
  xlim(-40,100)+
  facet_wrap(~Label)

ggsave("Figures/TrainingMEPs_high_low.jpeg", width = 5, height = 4, unit = "in", dpi = 300)
  
ggplot(data = mep_df, aes(x = Time, y = Tricep, group = Trial, color = Trial)) + 
  geom_line()+
  facet_wrap(~Group)


### MEP 2
require(readxl)
library(tidyr)


setwd("/Volumes/BorichLab/IG_REACH")
order_group = c("Stroke", "Stroke","NT","NT")
order_state = c("High","Low","High","Low")
dat1 = read_excel("classifier_pred_mep_traces.xlsx", sheet = 1)
dat1$Group = order_group[1]
dat1$State = order_state[1]
dat1$Location = "Emory"

dat1 <- dat1 %>%
  pivot_longer(cols = -c(sample, Group, State, Location),
               names_to = "Trial",
               values_to = "Signal")

dat2 = read_excel("realtime_meps_fdi_NT&stroke2.xlsx", sheet = 1)
dat2$Group = order_group[1]
dat2$State = order_state[1]
dat2$Location = "UT"


dat2 <- dat2 %>%
  pivot_longer(cols = -c(sample, Group, State, Location),
               names_to = "Trial",
               values_to = "Signal")

for(i in 2:4){
  dat3 = read_excel("classifier_pred_mep_traces.xlsx", sheet = i)
  dat3$Group = order_group[i]
  dat3$State = order_state[i]
  dat3$Location = "Emory"
  
  dat3 <- dat3 %>%
    pivot_longer(cols = -c(sample, Group, State, Location),
                 names_to = "Trial",
                 values_to = "Signal")
  
  dat1 = rbind(dat1,dat3)
  
  dat4 = read_excel("realtime_meps_fdi_NT&stroke2.xlsx", sheet = i)
  dat4$Group = order_group[i]
  dat4$State = order_state[i]
  dat4$Location = "UT"
  
  dat4 <- dat4 %>%
    pivot_longer(cols = -c(sample, Group, State, Location),
                 names_to = "Trial",
                 values_to = "Signal")
  dat2 = rbind(dat2,dat4)
}

fulldata = rbind(dat1, dat2)

fulldata$Muscle <- ifelse(fulldata$Location == "Emory", "Tricep",
                          ifelse(fulldata$Location == "UT", "FDI", NA))

# Low pass filter function
low_pass_filter <- function(data, cutoff_freq = 20, sampling_rate = 5000) {
  # Design Butterworth filter
  bf <- butter(4, cutoff_freq / (sampling_rate / 2), type = "low")
  
  # Apply the filter to the Signal column
  data$Signal <- filtfilt(bf, data$Signal)
  return(data)
}

require(dplyr)
require(signal)
filtered_df <- fulldata %>%
  group_by( Group, State, Location, Muscle, Trial) %>%
  group_modify(~ low_pass_filter(.x)) %>%
  ungroup()

summary_df <- fulldata %>%
  group_by(sample, Group, State, Location, Muscle) %>%
  summarise(
    mean_MEP = mean(Signal),
    sd_MEP = sd(Signal)
  )
#summary_df$sample = summary_df$sample-500

# Apply the low pass filter to the Signal column

df = summary_df[summary_df$Location == "Emory",]
df$State <- as.factor(df$State)
df[df$Group =="NT",]$mean_MEP = df[df$Group =="NT",]$mean_MEP * -1

library(scales)

ggplot(df, aes(x = ((sample-500)/5000)*1000, y = mean_MEP, color = interaction(Group,State), fill = State, linetype = State)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray", alpha = 0.5) +
  #geom_ribbon(aes(ymin = mean_MEP - sd_MEP, ymax = mean_MEP + sd_MEP), alpha = 0.1, color = NA) +
  scale_color_manual(values = c("NT.High" = "blue", "NT.Low" = "lightblue","Stroke.High" = "red", "Stroke.Low" = "red4")) +
  #scale_fill_manual(values = c("High" = "lightgoldenrod", "Low" = "lightblue")) +
  geom_line(size = 1, alpha = 1) +
  #geom_line(size = 1, alpha = 1) + 
 # geom_line(size = 0.5, alpha = 1, color = "black") +  # Main line
 # Outline
  labs(x = "Time (ms)", y = "Tricep \n MEP Amplitude (µV)") +
  theme_minimal() +
  scale_linetype_manual(values = c("High" = "solid", "Low" = "dashed")) +
  xlim( -25, 75) +
  ylim(-75, 75) +
  facet_wrap(~Group) +
  theme_classic() +
  scale_size_manual(values = c("High" = 1, "Low" = 1),
                    labels = c("High", "Low"))+
  theme(legend.position = "none",
        axis.title = element_text(size = 16), axis.text = element_text(size = 12))
 # guides(linetype = guide_legend(keywidth = 5, keyheight = 5))




ggsave("Figures/Emory_Tricep_Mep.jpeg", width = 5, height = 4, unit = "in", dpi = 300)


summary_df <- fulldata %>%
  group_by(sample, Group, State, Location, Muscle) %>%
  summarise(
    mean_MEP = mean(Signal),
    sd_MEP = sd(Signal)
  )
df = summary_df[summary_df$Location == "UT",]
df$State <- as.factor(df$State)

ggplot(df, aes(x = ((sample-500)/5000)*1000, y = mean_MEP, color = interaction(Group,State), fill = State, linetype = State)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black", alpha = 0.5) +
  #geom_ribbon(aes(ymin = mean_MEP - sd_MEP, ymax = mean_MEP + sd_MEP), alpha = 0.1, color = NA) +
  scale_color_manual(values = c("NT.High" = "blue", "NT.Low" = "lightblue","Stroke.High" = "red1", "Stroke.Low" = "red4")) +
  #scale_fill_manual(values = c("High" = "lightgoldenrod", "Low" = "lightblue")) +
  geom_line(aes(size = State), alpha = 1) +
  #geom_line(size = 1, alpha = 1) + 
  # geom_line(size = 0.5, alpha = 1, color = "black") +  # Main line
  # Outline
  labs(x = "Time (ms)", y = "FDI \n MEP Amplitude (µV)") +
  theme_minimal() +
  scale_linetype_manual(values = c("High" = "solid", "Low" = "dashed"),
  labels = c("High", "Low")) +
  xlim( -25, 75) +
  ylim(-500, 1300) +
  facet_wrap(~Group) +
  theme_classic() +
  scale_size_manual(values = c("High" = 1, "Low" = 1),
                    labels = c("High", "Low"))+
  theme(legend.position = "none",
        axis.title = element_text(size = 16), axis.text = element_text(size = 12))
# guides(linetype = guide_legend(keywidth = 5, keyheight = 5))


ggsave("Figures/UT_FDI_Mep.jpeg", width = 5, height = 4, unit = "in", dpi = 300)

## MEP data points
setwd("/Volumes/BorichLab/IG_REACH")

mep = summary_df
mep$sample = ((mep$sample-500)/5000)*1000
mep = mep[mep$sample >= 3 & mep$sample <= 35,]
library(dplyr)

peak_to_peak <- mep %>%
  group_by(Group, State, Muscle, Location) %>%
  summarize(peak_to_peak_amplitude = max(mean_MEP) - min(mean_MEP)) 

  

###Need to rerun with Group added
peak_to_peak <- peak_to_peak %>%
  group_by(Muscle, Group) %>%
  mutate(normalized_amplitude = peak_to_peak_amplitude / mean(peak_to_peak_amplitude)) %>%
  ungroup()

aggregated_data <- peak_to_peak %>%
  group_by(State, Muscle, Group) %>%
  summarize(mean_peak_to_peak = mean(peak_to_peak_amplitude),
            mean_normalized = mean(normalized_amplitude))

#df = aggregated_data[aggregated_data$Muscle == "Tricep" & aggregated_data$Group == "Stroke",]
df = peak_to_peak#[peak_to_peak$Muscle == "Tricep" & peak_to_peak$Group == "Stroke",]

ggplot(data = df, aes(x = State, y = normalized_amplitude, group = Group, color = Group))+
  geom_point()+
  geom_line( alpha = 0.5)+
  facet_grid(cols = vars(Group), rows = vars())+
  ylab("Normalized Tricep \n MEP Amplitude")+
  scale_color_manual(values = c("Stroke" = "red", "NT" = "blue")) +
  theme_classic()+
  theme(legend.position = "none") +
  theme(legend.position = "none",
        axis.title = element_text(size = 14), axis.text = element_text(size = 12))+
  ylim(0.75, 1.25)
ggsave("Figures/Emory_Tricep_Mep_points.jpeg", width = 3, height = 4, unit = "in", dpi = 300)


##UT data
data = read_xlsx("REACH_R21_prelim_data_UT.xlsx", sheet = 3)
ggplot(data = data, aes(x = State, y = mean_MEP, group = ID, color = Group))+
  geom_point()+
  geom_line( alpha = 0.5)+
  facet_grid(cols = vars(Group), rows = vars())+
  ylab("Normalized FDI \n MEP Amplitude")+
  scale_color_manual(values = c("Stroke" = "red", "NT" = "blue")) +
  theme_classic()+
  theme(legend.position = "none") +
  theme(legend.position = "none",
        axis.title = element_text(size = 16), axis.text = element_text(size = 12))
ggsave("Figures/UT_FDI_Mep_points.jpeg", width = 3, height = 4, unit = "in", dpi = 300)

## F1 performance
ggplot(data[data$State == "Low",], aes(x = Group, y = F1)) +
  geom_violin(data = subset(data, Group == "NT"), fill = "blue", alpha = 0.5, trim = F) +
  geom_point(data = subset(data, Group == "Stroke"), color = "red", size = 3) +
  labs(x = "", y = "Classifier \n Performance (F1)") +
  theme_minimal()+
  geom_point(data = subset(data, Group == "NT"), position = position_jitter(width = 0.1), size = 1.5, color = "black")+
  stat_summary(data = subset(data, Group == "NT"),fun = mean, geom = "point", color = "black", size = 5, shape = 21, fill = "White")+
  theme_classic()+
  theme(legend.position = "none",
        axis.title = element_text(size = 16), axis.text = element_text(size = 12))
ggsave("Figures/UT_F1.jpeg", width = 3, height = 4, unit = "in", dpi = 300)

  #facet_grid(cols = vars(Group))
  
  

# check the mep averages
ggplot(mep, aes(x = sample, y = Signal, color = interaction(Group,State), fill = State)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black", alpha = 0.5) +
  #geom_ribbon(aes(ymin = mean_MEP - sd_MEP, ymax = mean_MEP + sd_MEP), alpha = 0.1, color = NA) +
  scale_color_manual(values = c("NT.High" = "cyan4", "NT.Low" = "cyan1","Stroke.High" = "magenta4", "Stroke.Low" = "magenta1")) +
  #scale_fill_manual(values = c("High" = "lightgoldenrod", "Low" = "lightblue")) +
  geom_line(aes(size = State), alpha =0.01) +
  #geom_line(size = 1, alpha = 1) + 
  # geom_line(size = 0.5, alpha = 1, color = "black") +  # Main line
  # Outline
  labs(x = "Time (ms)", y = "Tricep MEP Amplitude (µV)") +
  theme_minimal() +
  #(values = c("High" = "dotted", "Low" = "solid"),
  #labels = c("High", "Low")) +
  xlim( 3, 75) +
  ylim(-75, 75) +
  facet_wrap(~Group+State) +
  theme_classic() +
  scale_size_manual(values = c("High" = 1, "Low" = 1),
                    labels = c("High", "Low"))


Noggplot(fulldata, aes(x = sample, y = Signal, color = State)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black", alpha = 0.2) +
  scale_color_manual(values = c("High" = "blue", "Low" = "goldenrod")) +
  geom_smooth(method = "loess", size = 1, se = TRUE, alpha = 0.8) +
  labs(x = "Time (ms)", y = "Tricep MEP Amplitude (µV)") +
  theme_minimal() +
  #xlim(400, 550) +
  facet_wrap(~Group + State)+
  theme_classic()


#setwd("/Volumes/BorichLab/IG_REACH")
setwd("/Volumes/BorichLab/NB_VPI_EEG")
library(reshape2)
library(dplyr)
library(tidyr)
library(ggplot2)
sub = "NOA07"
electrode = "C4"

# Set the path to the folder containing the EEG data files
path <- paste0(sub,".sub/TRACE/epoched_clean_R21")

# Get a list of all the EEG data files in the folder, excluding times.csv and freqs.csv
#files <- list.files(path)
files <- list.files(path, pattern = "\\.csv$")

# Read the freqs.csv and times.csv files
freqs <- read.csv(file.path(paste0(path,"/info"), "freqs.csv"), header = FALSE)
times <- read.csv(file.path(paste0(path,"/info"), "times.csv"), header = FALSE)
times = times[,1]

#High = read.csv(paste0(path,"/",sub,"_High_",electrode,".csv"))
#Low = read.csv(paste0(path,"/",sub,"_Low_",electrode,".csv"))
dat = read.csv(paste0(path,"/",files[1]), header = F)

#colnames(High) = times
#colnames(Low) = times
colnames(dat) = times

#High$frequencies = freqs[1:27,1]
#Low$frequencies = freqs[1:27,1]
dat$frequencies = freqs[1:100,1]

#High$ID = sub
#Low$ID = sub
dat$ID = sub
dat$Group = "NT"

#High$State = "High"
#Low$State = "Low"

#data = rbind(High, Low)
#dat2 = dat
dat2 = rbind(dat2,dat)

#p15 = ddattestp15 = data
#p15$Group = "NT"

# Assuming your dataframe is called 'df'
# long_df_15 <- gather(p15, Time, Signal, -frequencies, -ID, -State, -Group)
# long_df_15$Time = as.numeric(long_df$Time)
# 
# p16 = data
# p16$Group = "Stroke"
# long_df_16 <- gather(p16, Time, Signal, -frequencies, -ID, -State, -Group)
# long_df_16$Time = as.numeric(long_df$Time)

dat2_long = gather(dat2, Time, Signal, -frequencies, -ID, -Group)
data = dat2_long


#data = rbind(p15,p16)

  ggplot(data = data, aes(x = Time, y = Signal)) +
  geom_point() + geom_smooth(method="glm", se=F) + scale_color_manual(values=c("#37bba3", "#f89923")) +
  theme_minimal() + theme(text = element_text(size = 18)) + xlab(expression(paste("Visual Reliance (cm's)"))) + ylab("Avg ERSP") +
  ggtitle("Seated Visual Reliance x Seated Vision ERSP ")

  ggplot(data = data[data$Time > -500,], aes(x = as.factor(Time), y = frequencies, fill = Signal)) +
  geom_tile() + scale_fill_gradientn(colours=topo.colors(12),limits = c(-7.5, 7.5)) + 
  theme_minimal() + theme(text = element_text(size = 18)) + xlab("") + ylab("Frequency (Hz)") + labs(fill="dB") +
  theme(axis.title.x=element_blank(),
       # axis.text.x=element_blank(),
        axis.ticks.x=element_blank())+
    facet_grid(cols = vars(), rows = vars(Group))
   #geom_vline(xintercept = 0, linetype = "dashed", color = "black", alpha = 0.4) +
    #xlim(-500,max(long_df$Time))
  
  
  ### Trace Beta Desync for R21 ###
  setwd("/Volumes/BorichLab/NB_VPI_EEG/R21_data_results/betadesync")
  
  # Get the list of CSV files in the current directory
  file_list <- list.files(pattern = "*.csv")
  
  # Initialize an empty list to store the data frames
  df_list <- list()
  
  # Loop through each file
  for (file in file_list) {
    # Read the CSV file
    df <- read.csv(file, header = FALSE)
    
    # Extract the band and group from the file name
    file_parts <- strsplit(file, "_|\\.csv")[[1]]
    band <- file_parts[2]
    group <- file_parts[3]
    
    # Add the Band and Group columns to the data frame
    df$Band <- band
    df$Group <- group
    
    # Append the data frame to the list
    df_list[[file]] <- df
  }
  
  # Combine all data frames into a single data frame
  combined_df <- do.call(rbind, df_list)

  mean_df <- aggregate(V1 ~ Group + Band, data = combined_df, FUN = mean)

  df = mean_df[mean_df$Band == "beta",]
  df = sumGroupDat2[sumGroupDat2$Group.1 == "VS" & sumGroupDat2$Group.2 == "Left" & sumGroupDat2$Group.3 == "Seat",]
  names(df) = c("Feedback", "Limb", "Posture", "ID", "Group", "Error")
  
  ggplot(data = df[,], aes(x = Group, y = Error, color = Group, group = Group)) +
    #geom_point(aes(x = Group, y = V1), position = position_jitter(width = 0.1, height = 0), size = 2, alpha = 0.6) +
    stat_summary(fun = "mean", geom = "point", size = 3) +
    stat_summary(fun = "mean", geom = "line", aes(linetype = Group), size = 1) +
    stat_summary(fun.data = "mean_se", geom = "errorbar", width = 0.2, size = 0.8) +
    #geom_text(aes(label = ID), position = position_jitter(width = 0.1, height = 0), size = 3, vjust = -1, hjust = 0.5) +
    labs(y = "Error (cm)", x = "", legend = "") +
    # scale_color_manual(values = c("NT-YA" = "magenta", "NT-OA" = "magenta", "Stroke" = "cyan"),
    #   labels = c("NT-YA","NT-OA", "Stroke")) +
    #scale_linetype_manual(values = c("NYA" = "solid", "Stroke" = "solid"),
    #  labels = c("NT", "Stroke")) +
    theme_classic() +  theme(text = element_text(size = 14))+
    guides(color = guide_legend(title = "Group"),
           linetype = guide_legend(title = "Group")) +
    labs(color = "Group", linetype = "Group")+
    #facet_wrap(~Group, scales = "free_y") +
    theme(legend.position = "none") #+ ylim(0,2.6)
  ggsave("/Volumes/BorichLab/IG_Reach/Figures/TraceBehavior.jpeg", width = 5, height = 5, dpi = 300, units = 'in')
  
  
  
  ## MRBD [ERSP after 0, averaged]
  
  setwd("/Volumes/BorichLab/NB_VPI_EEG")
  
  library(dplyr)
  library(tidyr)
  
  # Read in the freqs.csv and times.csv files from the root directory
  freqs <- read.csv("freqs.csv", header = FALSE)$V1
  times <- read.csv("times.csv", header = FALSE)$V1
  
  # Get a list of all directories ending in .sub
  sub_dirs <- list.dirs(recursive = FALSE)
  sub_dirs <- sub_dirs[grepl("\\.sub$", sub_dirs)]
  
  # Initialize an empty list to store the data frames
  df_list <- list()
  
  # Loop through each .sub directory
  for (sub_dir in sub_dirs) {
    # Get a list of all CSV files in the ERSP directory, excluding times.csv
    csv_files <- list.files(path = file.path(sub_dir, "TRACE", "ERSP"), pattern = "\\.csv$", full.names = TRUE)
    csv_files <- csv_files[!grepl("times\\.csv$", csv_files)]
    
    # Loop through each CSV file
    for (csv_file in csv_files) {
      # Read in the CSV file
      df <- read.csv(csv_file, header = FALSE)
      
      # Set the column names to the times values
      colnames(df) <- times
      
      # Add the freqs column
      df$freqs <- freqs
      
      # Extract information from the file name
      file_name <- basename(csv_file)
      file_parts <- strsplit(file_name, "_|\\.")[[1]]
      
      # Add the ID, Group, Limb, Posture, and Electrode columns
      df$ID <- file_parts[1]
      df$Group <- gsub("\\d+", "", file_parts[1])
      df$Limb <- ifelse(file_parts[2] == "L", "Left", "Right")
      df$Posture <- file_parts[4]
      df$Electrode <- file_parts[5]
      df$Feedback <- ifelse(file_parts[3] == "NV", "NV", "VS")
      
      # Convert the data frame to long format
      df_long <- df %>%
        pivot_longer(cols = -c(freqs, ID, Group, Limb, Posture, Feedback, Electrode),
                     names_to = "Time",
                     values_to = "Signal")
      
      # Append the long-format data frame to the list
      df_list[[csv_file]] <- df_long
    }
  }
  
  
  # Combine all data frames into a single data frame
  ERSP_data <- bind_rows(df_list)
  
  df = ERSP_data
  df = df[df$Time > 0,]
  df = df[df$Electrode == "C4",]
  df = df[df$Posture == "SIT" & df$Limb == "Left" & df$Feedback == "VS",]
  
  library(dplyr)
  
  df <- df %>%
    group_by(freqs, Feedback, Electrode, Posture, Limb, Group, ID) %>%
    summarise(Signal = mean(Signal))
  
  df_bands <- df %>%
    mutate(Bands = case_when(
      freqs > 1 & freqs < 4 ~ "delta",
      freqs > 4 & freqs < 8 ~ "theta",
      freqs > 8 & freqs < 13 ~ "mu",
      freqs > 13 & freqs < 30 ~ "Beta",
      #freqs >= 13 & freqs <= 16 ~ "Low Beta",
     # freqs >= 17 & freqs <= 20 ~ "Mid Beta",
      #freqs >= 21 & freqs <= 30 ~ "High Beta",
      freqs > 30 & freqs < 80 ~ "gamma",
      TRUE ~ "other"
    )) %>%
    group_by(Feedback, Electrode, Posture, Limb, Group, ID, Bands) %>%
    summarise(Signal = mean(Signal))
  data = df_bands
  data = data[data$Group != "NYA",]
  
  data$Group <- factor(data$Group, levels = c("NOA", "SP"), labels = c("NT", "Stroke"))
  #data$Bands <- factor(data$Bands, levels = c("High Beta", "Mid Beta", "Low Beta"))
  data = data[!is.na(data$Bands),]
  data = data[data$Bands != "other"  & data$Bands != "theta"  & data$Bands != "gamma"  & data$Bands != "mu"  & data$Bands != "delta"  ,]
  
  ggplot(data = data[,], aes(x = Group, y = Signal, color = Group, group = Group)) +
    #geom_point(aes(x = Group, y = Signal), position = position_jitter(width = 0.1, height = 0), size = 2, alpha = 0.01) +
    stat_summary(fun = "mean", geom = "point", size = 3) +
    stat_summary(fun = "mean", geom = "line", aes(linetype = Group), size = 1) +
    stat_summary(fun.data = "mean_se", geom = "errorbar", width = 0.2, size = 0.8) +
    labs(y = "", x = "", legend = "") +
    #scale_color_manual(values = c("NT" = "magenta", "Stroke" = "cyan"),
                     #  labels = c("NT", "Stroke")) +
   # scale_linetype_manual(values = c("NT" = "solid", "Stroke" = "solid"),
                         # labels = c("NT", "Stroke")) +
    scale_color_manual(values = c("NT" = "blue", "Stroke" = "red"),
                       labels = c("NT", "Stroke")) +
    theme_classic() +  theme(text = element_text(size = 14))+
    guides(color = guide_legend(title = "Group"),
           linetype = guide_legend(title = "Group")) +
    labs(color = "Group", linetype = "Group")+
    #facet_wrap(~Group + Bands) +
    #facet_grid(cols = vars(), rows = vars(Bands))+
    theme(legend.position = "none") +theme(panel.spacing = unit(1, "lines"))+
    theme(legend.position = "none",
          axis.title = element_text(size = 16), axis.text = element_text(size = 14),axis.text.x = element_text(face = "bold"))+
    ylab("Movement Related \n Beta Desynchronization")
  #ggtitle("Error")
  
  ggsave("/Volumes/BorichLab/IG_Reach/Figures/MRBD.jpeg", width = 3, height = 5, dpi = 300, units = 'in')
  
  
  # test is there is correlation betwee beta desync and Error during trace
  merged_data <- merge(data, df_agg[c("ID", "Group", "Error")], by = c("ID", "Group"), all.x = TRUE)
  
  
  library(ggplot2)
  library(ggpubr)
  
  ggplot(merged_data, aes(x = Signal, y = Error)) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE) +
    facet_grid(cols = vars() )+
   # stat_cor(label.x = "left", label.y = "top") +
    labs(x = "Signal", y = "Error", title = "Correlation Plot") +
    theme_minimal()
  
  
  
  ## accuracy plot
  setwd("/Volumes/BorichLab/IG_REACH")
  data_acc = read_xlsx("targeting_accuracy_emory_realtime.xlsx", sheet=2)
  
  ggplot(data = data_acc[data_acc$Dval == "Dval",], aes(x = State, y = Accuracy, color = Group, group = Group)) +
    #geom_point(aes(x = Group, y = Signal), position = position_jitter(width = 0.1, height = 0), size = 2, alpha = 0.01) +
    stat_summary(fun = "mean", geom = "point", size = 3) +
    stat_summary(fun = "mean", geom = "line", aes(linetype = Group), size = 1) +
    stat_summary(fun.data = "mean_se", geom = "errorbar", width = 0.2, size = 0.8) +
    labs(y = "", x = "", legend = "") +
    #scale_color_manual(values = c("NT" = "magenta", "Stroke" = "cyan"),
    #  labels = c("NT", "Stroke")) +
    # scale_linetype_manual(values = c("NT" = "solid", "Stroke" = "solid"),
    # labels = c("NT", "Stroke")) +
    scale_color_manual(values = c("NT" = "blue", "Stroke" = "red"),
                       labels = c("NT", "Stroke")) +
    theme_classic() +  theme(text = element_text(size = 14))+
    guides(color = guide_legend(title = "Group"),
           linetype = guide_legend(title = "Group")) +
    labs(color = "Group", linetype = "Group")+
    #facet_wrap(~Group + Bands) +
    facet_grid(cols = vars(Group), rows = vars())+
    theme(legend.position = "none") +theme(panel.spacing = unit(1, "lines"))+
    theme(legend.position = "none",
          axis.title = element_text(size = 16), axis.text = element_text(size = 14))+
    ylab("Movement Related \n Beta Desynchronization")
  #ggtitle("Error")
  
  ggsave("/Volumes/BorichLab/IG_Reach/Figures/Accuracy.jpeg", width = 3, height = 5, dpi = 300, units = 'in')
  
  
  
  
  ## trace trace's
  setwd("/Volumes/BorichLab/NB_AHA_Kinematics")
  library(dplyr)
  
  # Get a list of all CSV files in the MasterData folder
  csv_files <- list.files("MasterData/", pattern = "\\.csv$", full.names = TRUE)
  
  # Read in each CSV file, add ID and Group columns, and store the data frames in a list
  data_list <- lapply(csv_files, function(file) {
    df <- read.csv(file)
    
    # Extract the ID from the file name
    id <- gsub("^MasterData_|.csv$", "", basename(file))
    
    # Extract the Group from the ID
    group <- gsub("\\d+$", "", id)
    
    # Add ID and Group columns to the data frame
    df$ID <- id
    df$Group <- group
    
    return(df)
  })
  
  # Combine all data frames into a single data frame
  tracetraces <- bind_rows(data_list)
  
head(tracetraces)

df = tracetraces[tracetraces$limb == "Left" &tracetraces$posture == "Seat" & tracetraces$vision == "VS" & tracetraces$position == "Left" & tracetraces$Group != "NYA",  ]  
df_s = df[df$Group == "SP" & df$trial == 8,]
#df_NYA = df[df$Group == "NYA" & df$trial == 12,]
df_NOA = df[df$Group == "NOA" & df$trial ==7,]
df2 = rbind(df_NOA, df_s)

# Reorder and rename the levels of the "Group" factor
df2$Group <- factor(df2$Group, levels = c("NOA", "SP"), labels = c("NT", "Stroke"))


#df2 = df[df$trial == 1,]
ggplot(data = df2,aes(x=Right..Hand.position.X*100,y=Right..Hand.position.Y*100)) +
  geom_point(data = df2, aes(x = TARGET_X*100, y = TARGET_Y*100), color = 'green', size = 0.5, alpha = 0.01) +
  geom_point(size = 0.2, alpha = 0.02, color = "darkgray")+
  facet_grid(rows = vars(), cols = vars(Group))+
  theme_classic()+ labs(x = "X-axis (cm's)", y = "Y-axis (cm's)")+
  theme(text = element_text(size = 14)) #+ xlim(-10,10) + ylim(0,30)
#geom_point(data = targets, aes(x = targets$`X-80%`, y = targets$`Y-80%`))+
ggsave("/Volumes/BorichLab/IG_Reach/Figures/KinematicTraces_exemplars.jpeg", width = 5.75, height = 3.35, dpi = 300, units = 'in')
