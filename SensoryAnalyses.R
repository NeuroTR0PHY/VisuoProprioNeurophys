require(ggplot2)
require(tidyverse)
require(readxl)

#subjects level
setwd("~/Downloads/AHA_EEG/AHA_Behavior")
sub_id = "NOA04"
Group = "NOA"
JAM = read_excel(paste0(sub_id,"/JointAngleMatching.xlsx"), sheet = 1)
LOC_L = read_excel(paste0(sub_id,"/Locognosia.xlsx"), sheet = 1)
LOC_R = read_excel(paste0(sub_id,"/Locognosia.xlsx"), sheet = 2)
LOC = rbind(LOC_L[,1:4], LOC_R[,1:4])
THRESH =read_excel(paste0(sub_id,"/TactileThresh.xlsx"), sheet = 1)

JAM$ErrorDiff = abs(JAM$Angle - JAM$Error)
JAM_AGG = aggregate(JAM$ErrorDiff, data = JAM, by = list(JAM$Joint, JAM$Limb), FUN = mean)
LOC_AGG = aggregate(LOC$Error, data = LOC, by = list(LOC$Hand), FUN = mean)
THRESH_AGG = aggregate(THRESH$Filament, data = THRESH, by = list(THRESH$Site, THRESH$Hand), FUN = mean)
names(JAM_AGG) = c("Joint", "Limb", "Error")
names(LOC_AGG) = c("Limb", "Error")
names(THRESH_AGG) = c("Site","Hand", "Error")
####ADD SUBJECT ID AS A COLUMN!!!!!!!
JAM_AGG = cbind(Group, JAM_AGG)
LOC_AGG = cbind(Group, LOC_AGG)
THRESH_AGG = cbind(Group, THRESH_AGG)

JAM_AGG$subject = sub_id
LOC_AGG$subject = sub_id
THRESH_AGG$subject = sub_id

write.csv(JAM_AGG, paste0(sub_id,"/JAM_aggregate.csv"))
write.csv(LOC_AGG, paste0(sub_id,"/LOC_aggregate.csv"))
write.csv(THRESH_AGG, paste0(sub_id,"/THRESH_aggregate.csv"))


#group level
datadirs = c("NYA01","NYA02","NYA03","NYA04","NYA05","NYA06","NYA07","NYA08","NYA09","NYA10","NYA11","NYA12","NYA13","NYA14","NOA01","NOA03","NOA04")
for(i in 1:length(datadirs)){
if(!exists("jam_g")){
  jam_g = read.csv2(paste0(datadirs[i],"/JAM_aggregate.csv"), header = T, sep =",")
}else{
  jam_g = rbind(jam_g, read.csv2(paste0(datadirs[i],"/JAM_aggregate.csv"), header = T, sep =","))
}
  
  if(!exists("loc_g")){
    loc_g = read.csv2(paste0(datadirs[i],"/LOC_aggregate.csv"), header = T, sep =",")
  }else{
    loc_g = rbind(loc_g, read.csv2(paste0(datadirs[i],"/LOC_aggregate.csv"), header = T, sep =","))
  }
  
  if(!exists("thresh_g")){
    thresh_g = read.csv2(paste0(datadirs[i],"/THRESH_aggregate.csv"), header = T, sep =",")
  }else{
    thresh_g = rbind(thresh_g, read.csv2(paste0(datadirs[i],"/THRESH_aggregate.csv"), header = T, sep =","))
  }
}

JAM_GROUP = jam_g
LOC_GROUP = loc_g
THRESH_GROUP = thresh_g

JAM_GROUP$Sub = factor(JAM_GROUP$subject)
JAM_GROUP$Error = as.numeric(JAM_GROUP$Error)
ggplot(data = JAM_GROUP, aes(x = Limb, y = Error, fill = subject)) +
  geom_bar(stat = "identity", position=position_dodge())

ggplot((data = JAM_GROUP[JAM_GROUP$Joint == "Wrist",]), aes(x = Limb, y = Error, fill = Group))+
  geom_dotplot(binaxis='y', stackdir='center', dotsize=1)

LOC_GROUP$Sub = factor(LOC_GROUP$Sub)
ggplot(data = LOC_GROUP, aes(x = Limb, y = Error, fill = Sub)) +
  geom_bar(stat = "identity", position=position_dodge())

THRESH_GROUP$Sub = factor(THRESH_GROUP$Sub)
ggplot(data = THRESH_GROUP, aes(x = Hand, y = Error, fill = Sub)) +
  geom_bar(stat = "identity", position=position_dodge())
