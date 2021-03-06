# Andrew Fairless, September 2011
# modified May 2015 for posting onto Github
# This script constructs the boxplots for Figure 2a of Fairless et al 2013
# Fairless et al 2013, doi: 10.1016/j.bbr.2012.08.051, PMID: 22982070, PMCID: PMC3554266

# The fictional data in "altereddata.txt" were modified from the original 
# empirical data used in Fairless et al 2011.
# I am using fictional data instead of the original data because I do not have 
# permission of my co-authors to release the data into the public domain.  
# NOTE:  Because the data have been altered, many characteristics of the original 
# data set will not be retained.

install.packages("psych", dependencies = TRUE)    # install package if not already installed
install.packages("gplots", dependencies = TRUE)   # install package if not already installed


library(psych)     	
datamaxmice = read.table("altereddata.txt", header = TRUE)		
data = datamaxmice		
data[ ,(dim(data)[2] + 1)] = data$brainwt / data$mousewtadj		
colnames(data)[dim(data)[2]] = "brwtmswt"	     # adds variable:  ratio of brain weight to mouse weight	
data[ ,(dim(data)[2] + 1)] = data$sniff + data$passivepawing		
colnames(data)[dim(data)[2]] = "allsocial"		# adds variable:  sum of all social behaviors
data = split(data, list(data$sex, data$age, data$strain))		

# determines which experimental groups (as defined by strain, sex, age) are included
# numbered as elements in the list 'data'
# elements 7 through 12 denote the C57BL/6J mouse groups
expgroups = 7:12

# determines which experimental variables are included 
# numbered as columns of the data frames, which are elements of the list 'data'
# columns 19, 22, and 37 specify "na", "nonsocial", and "allsocial" behaviors, respectively
varcols = c(37, 22, 19)		

maxrow = 1		
for (iter in expgroups) {		
     maxrow = max(maxrow, dim(data[[iter]])[1])		
}		
maxrow = maxrow + 1		
for (iter in expgroups) {		
     data[[iter]][(dim(data[[iter]])[1] + 1):maxrow, ] = NA		
     rownames(data[[iter]]) = 1:maxrow		
}		

datagraph = 1:maxrow		
datagraph = as.data.frame(datagraph)		
graphcol = 0		

for (iter in expgroups) {		
     for (iter2 in 1:length(varcols)) {		
          graphcol = graphcol + 1		
          datagraph[ ,graphcol] = data[[iter]][ ,varcols[iter2]]		
          colnames(datagraph)[graphcol] = paste(colnames(data[[iter]])[varcols[iter2]], 
                                                names(data)[iter], sep = ",")		
     }		
}		


library(gplots)

# creates table with values (i.e., upper and lower box limits and the median) for the boxplot
datasumm = c(1, 1, 1)
datasumm = as.data.frame(datasumm)
for (iter in 1:dim(datagraph)[2]) {
     datasumm[1, iter] = summary(datagraph[ ,iter])[[3]]
     datasumm[2, iter] = summary(datagraph[ ,iter])[[2]]
     datasumm[3, iter] = summary(datagraph[ ,iter])[[5]]
}
rownames(datasumm) = c("central", "lowerrbar", "upperrbar")
colnames(datasumm) = colnames(datagraph)
datasumm = t(datasumm)
datasumm = (datasumm / 61) * 100

lwd = 2
col = c(7, 5, 3)
space = c(3, 0, 0, 1, 0, 0)

# "nacol" adds vertical empty spaces to separate the groups of boxes in the boxplot
nacol = rep(x = NA, times = maxrow)     
datagraph = cbind(datagraph[ ,1:3], nacol, datagraph[ ,4:6], nacol, nacol, nacol, 
                  datagraph[ ,7:9], nacol, datagraph[ ,10:12], nacol, nacol, nacol, 
                  datagraph[ ,13:15], nacol, datagraph[ ,16:18])	

png("B6 soc nonsoc na boxplot space3.png", width = 640, height = 512)	
par(mar = c(5.1, 4.1, 4.1, 4.1))
boxplot((datagraph / 61) * 100, col = c(7, 5, 3, 1, 7, 5, 3, 1, 1, 1), 
        ylab = "Portion (%) of all scored time points", ylim = c(0, 80), 
        yaxt = "n", xaxt = "n", cex.lab = 1.5)
# denotes the mean of each group with an asterisk (*)
points(mean((datagraph / 61) * 100, na.rm = T), pch = 8, col = 1)

axis(2, at = seq(0, 80, by = 10), las = 2, lwd = lwd, cex.axis = 1.6)

# x-axis
sexverticaloffset = 1
ageverticaloffset = 2.5
xlabelcex = 1.3
text(4, labels = "30 days", par("usr")[3], pos = 1, xpd = T, cex = xlabelcex, offset = ageverticaloffset, font = 2)
text(14, labels = "41 days", par("usr")[3], pos = 1, xpd = T, cex = xlabelcex, offset = ageverticaloffset, font = 2)
text(24, labels = "69 days", par("usr")[3], pos = 1, xpd = T, cex = xlabelcex, offset = ageverticaloffset, font = 2)
text(c(2, 12, 22), labels = "female", par("usr")[3], pos = 1, xpd = T, cex = xlabelcex, offset = sexverticaloffset, font = 2)
text(c(6, 16, 26), labels = "male", par("usr")[3], pos = 1, xpd = T, cex = xlabelcex, offset = sexverticaloffset, font = 2)

# legend
par(font = 2)
leg = col
leg = as.data.frame(leg)
leg[ ,2] = c("C57BL/6J social", "C57BL/6J nonsocial", "C57BL/6J no behavior")
legend(0, 80, legend = leg[ ,2], fill = leg[ ,1], bty = "o")
par(font = 1)

# right-hand y-axis
tkmks2 = seq(0, 50, by = 5)
axis(4, at = tkmks2 / 0.61, las = 2, lwd = lwd, cex.axis = 1.6, labels = tkmks2)
par(xpd = T) 
text(31.3, 40, "Number of time points", cex = 1.5, srt = 270)
par(xpd = F)

dev.off()	
