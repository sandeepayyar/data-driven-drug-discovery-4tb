
setwd("/Users/sayyar/Downloads")
setwd("/Users/sayyar/Documents/openpredict")
library("splitstackshape")

###Reading the data
data.chem.1.3 <- data.frame(read.delim(file="data/features/drugbank-sideeffects-similarity.tab", sep="\t",header=F))
tbDrugs <- c("DB00679","DB00845","DB00479", "DB00601", "DB01044", "DB01137", "DB00218", "DB01165", "DB01044", "DB00766", "DB00615", "DB04934", "DB01045", "DB01201", "DB01082", "DB00609", "DB00951", "DB00609", "DB00760", "DB00679", "DB00314", "DB01172", "DB00339", "DB00314", "DB00260",  "DB00760","DB00330", "DB00494")
data.chem.1.6 <- data.frame(read.delim(file="data/features/drugbank-sider-smiles-similarity-MACCS.tab",sep="\t",header=F))
new.Drugs <- data.frame(read.delim(file = "DiseaseDrugs.csv", sep= "\t", header = F))

###Functions for data cleanup
rowname.data.chem <- function(data)
{
  rowname       <- apply(data[,1:2],1,function(x) paste(sort(c(x[1],x[2]))[1], sort(c(x[1],x[2]))[2] ,sep="_"))
  mat           <- as.matrix(data[,3])
  rownames(mat) <- rowname
  return(mat)
}

splitAndOrder <-function(x) {
  x=unlist(strsplit(x, "_"))
  x=paste(sort(x), collapse = "_")
  return(x)
}


###Filter the Sider similarity data through known drugs
drugs.tb.known <- sort(unique(tbDrugs))

drugs.1 <- data.chem.1.3[data.chem.1.3$V1 %in% tbDrugs,]
drugs.2 <- data.chem.1.3[data.chem.1.3$V2 %in% tbDrugs,]

drugs.tb <- rbind(drugs.1,drugs.2)
drugs.tb <- unique(drugs.tb)

drugs.tb <- drugs.tb[which(drugs.tb$V3 < 0.3), ]
d <- cSplit(new.Drugs, "V1", ":")
head(d)
new.Drugs <- d$V1_2
new.Drugs <- gsub(']','', new.Drugs)

new.Drugs - new.Drugs[!is.na(new.Drugs)]

######Filter the drug drug side effect similarities from TB with candidate drugs
candidate.Drugs <- new.Drugs

sim.drugs.1 <- as.character(drugs.tb$V1[drugs.tb$V1 %in% candidate.Drugs])
sim.drugs.2 <- as.character(drugs.tb$V2[drugs.tb$V2 %in% candidate.Drugs])

sim.drugs <- c(sim.drugs.1, sim.drugs.2)
sim.drugs <- sort(unique(sim.drugs))

known.unknown.tb <- apply(expand.grid(sim.drugs, drugs.tb.known),1,function(x) paste(x[1],x[2],sep="_"))
known.unknown.tb <- sapply(known.unknown.tb, splitAndOrder, USE.NAMES = F)


####Filter the chemical similarity MACCS data with the above candidate drug list
results.1.data <- data.chem.1.6[rownames(data.chem.1.6) %in% known.unknown.tb, ]
results.1.data <- data.frame(results.1.data)

results.1.data <- results.1.data[order(-results.1.data$score), , drop = FALSE]
