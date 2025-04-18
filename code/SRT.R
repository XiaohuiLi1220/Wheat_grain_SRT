```R
library(Seurat)
library(tidyverse)
library(ggplot2)
```


```R
### 数据整合
source("CreateBmkObject.R")
dap4 <- CreateS1000Object(
          matrix_path="./dap4/subdata/L4_heAuto/", 
          png_path="./dap4/images/he_roi_small.png", 
          spot_radius = 0.0039,
          min.cells =1,
          min.features =1    
)

dap8 <- CreateS1000Object(
          matrix_path="./dap8/subdata/L4_heAuto/", 
          png_path="./dap8/images/he_roi_small.png", 
          spot_radius = 0.0039,
          min.cells =1,
          min.features =1    
)

dap12 <- CreateS1000Object(
          matrix_path="./dap12/subdata/L4_heAuto/", 
          png_path="./dap12/images/he_roi_small.png", 
          spot_radius = 0.0039,
          min.cells =1,
          min.features =1    
)

daph12 <- CreateS1000Object(
          matrix_path="./daph12/subdata/L4_heAuto/", 
          png_path="./daph12/images/he_roi_small.png", 
          spot_radius = 0.0039,
          min.cells =1,
          min.features =1    
)
dap4@meta.data$sample <- 'dap4'
dap8@meta.data$sample <- 'dap8'
dap12@meta.data$sample <- 'dap12'
daph12@meta.data$sample <- 'daph12'

sample_list <- list(dap4,dap8,dap12,daph12)
seurat_list <- lapply(sample_list, function(sample) {
    sample@meta.data$nUMI <- sample@meta.data$nCount_Spatial
    sample@meta.data$nGene <- sample@meta.data$nFeature_Spatial
})
for (i in seq_along(singleList)){
  singleList[[i]] <- SCTransform(object = singleList[[i]], assay = "Spatial", verbose = FALSE, return.only.var.genes = FALSE)#20211105
}
anchors <- FindIntegrationAnchors(object.list = seurat_list, normalization.method = "SCT", verbose = FALSE)
seurat_integrated <- IntegrateData(anchorset = anchors, normalization.method = "SCT", verbose = FALSE)
```


```R
## 降维聚类
single.integrated <- ScaleData(single.integrated)
single.integrated <- RunPCA(single.integrated, features = VariableFeatures(single.integrated))
single.integrated <- RunTSNE(single.integrated, features = VariableFeatures(single.integrated), check_duplicates = FALSE)
single.integrated <- RunUMAP(single.integrated, features = VariableFeatures(single.integrated), check_duplicates = FALSE)
single.integrated <- FindNeighbors(single.integrated, dims = 1:30)
single.integrated <- FindClusters(single.integrated, resolution = 0.2)
plot1 <- SpatialPlot(single.integrated,pt.size.factor = 2,crop=F,image.alpha = 0)
```


```R
## 细胞注释
single.integrated@meta.data$celltype[single.integrated@meta.data$seurat_clusters == 0] <- "Inner Pericarp"
single.integrated@meta.data$celltype[single.integrated@meta.data$seurat_clusters == 1] <- "Inner Pericarp"
single.integrated@meta.data$celltype[single.integrated@meta.data$seurat_clusters == 2] <- "Testa Seed Coat"
single.integrated@meta.data$celltype[single.integrated@meta.data$seurat_clusters == 3] <- "Outer Pericarp"
single.integrated@meta.data$celltype[single.integrated@meta.data$seurat_clusters == 4] <- "Central cells of starchy endosperm"
single.integrated@meta.data$celltype[single.integrated@meta.data$seurat_clusters == 5] <- "Prismatic cells of starchy endosperm"
single.integrated@meta.data$celltype[single.integrated@meta.data$seurat_clusters == 6] <- "Inner Pericarp"
single.integrated@meta.data$celltype[single.integrated@meta.data$seurat_clusters == 7] <- "ESR"
single.integrated@meta.data$celltype[single.integrated@meta.data$seurat_clusters == 8] <- "Cavity fluidl"
single.integrated@meta.data$celltype[single.integrated@meta.data$seurat_clusters == 9] <- "Sub-aleurone"
single.integrated@meta.data$celltype[single.integrated@meta.data$seurat_clusters == 10] <- "Aleurone Layer"
single.integrated@meta.data$celltype[single.integrated@meta.data$seurat_clusters == 11] <- "Outer Pericarp"
```


```R
## 亚群聚类
Idents(single.integrated) <- single.integrated@meta.data$celltype
rds1 <- SplitObject(single.integrated,split.by='celltype')

data_al <- rds1$`Aleurone Layer`
data_sa <- rds1$`Sub-aleurone`
data_tc <- rds1$`Transfer cell`

rds2 <- data_al
name2 <- unique(rds2@meta.data$celltype)
name1 <- gsub(" ", "_", name2)
rds2 <- FindVariableFeatures(rds2, selection.method = "vst", nfeatures = 1000,verbose = FALSE)
rds2 <- ScaleData(rds2,verbose = FALSE)
rds2 <- RunPCA(rds2,verbose = FALSE)
rds2 <- FindNeighbors(rds2, dims = 1:30,verbose = FALSE)  
rds2 <- FindClusters(rds2, resolution =  0.5,verbose = FALSE)
rds2 <- RunUMAP(rds2, reduction = "pca", dims = 1:10, verbose = FALSE)
rds2 <- RunTSNE(rds2, reduction = "pca",check_duplicates=FALSE, dims = 1:10, verbose = FALSE)
plot2 <- SpatialPlot(rds2,pt.size.factor = 2,crop=F,image.alpha = 1)
```


```R
## 基因表达分布图
```


```R
plot3 <- SpatialFeaturePlot(single.integrated,features = "TraesCS6B02G418700")
plot4 <- SpatialFeaturePlot(rds2,features = "TraesCS6B02G418700")
```

##WGCNA



library(WGCNA)
options(stringsAsFactors = FALSE)
allowWGCNAThreads()
enableWGCNAThreads(nThreads = 10)
exp<-read.table("Anno.Content.txt",header=T,row.names=1)
 gsg = goodSamplesGenes(exp, verbose = 3)
#Checking data for excessive missing values and identification of outlier microarray samples
gsg$allOK
if TURE. then next,or need further trimming
#=========================================================================================================
if (!gsg$allOK)
{
  # Optionally, print the gene and sample names that were removed:
  if (sum(!gsg$goodGenes)>0)
     printFlush(paste("Removing genes:", paste(names(datExpr0)[!gsg$goodGenes], collapse = ", ")));
  if (sum(!gsg$goodSamples)>0)
     printFlush(paste("Removing samples:", paste(rownames(datExpr0)[!gsg$goodSamples], collapse = ", ")));
  # Remove the offending genes and samples from the data:
  exp = exp[gsg$goodSamples, gsg$goodGenes]
}
#==============================================================================================
if (!gsg$allOK)
{

  if (sum(!gsg$goodGenes)>0)
     printFlush(paste("Removing genes:", paste(names(exp)[!gsg$goodGenes], collapse = ", ")));
  if (sum(!gsg$goodSamples)>0)
     printFlush(paste("Removing samples:", paste(rownames(exp)[!gsg$goodSamples], collapse = ", ")));

  exp = exp[gsg$goodSamples, gsg$goodGenes]
}
 exp = goodSamplesGenes(exp, verbose = 3);
 gsg1$allOK
#=======================================================
sampleTree = hclust(dist(exp), method = "average");
# Plot the sample tree: Open a graphic output window of size 12 by 9 inches
# The user should change the dimensions if the window is too large or too small.
sizeGrWindow(12,9)
#pdf(file = "sampleClustering.pdf", width = 12, height = 9);
par(cex = 0.6);
par(mar = c(0,4,2,0))
plot(sampleTree, main = "Sample clustering to detect outliers", sub="", xlab="", cex.lab = 1.5,
    cex.axis = 1.5, cex.main = 2)
## if has outlier
clust = cutreeStatic(sampleTree, cutHeight = 20000, minSize = 10)
table(clust)
keepSamples = (clust==1)
datExpr = datExpr[keepSamples, ]
nGenes = ncol(datExpr)
nSamples = nrow(datExpr)
# to cut outlier samples

options(stringsAsFactors = FALSE);
Allow multi-threading within WGCNA. This helps speed up certain calculations.
# At present this call is necessary for the code to work.
# Any error here may be ignored but you may want to update WGCNA if you see one.
# Caution: skip this line if you run RStudio or other third-party R environments.
# See note above.
# Choose a set of soft-thresholding powers
powers = c(c(1:10), seq(from = 12, to=20, by=2))
# Call the network topology analysis function
sft = pickSoftThreshold(exp, powerVector = powers, verbose = 5)
# Plot the results:
sizeGrWindow(9, 5)
par(mfrow = c(1,2));
cex1 = 0.9;
# Scale-free topology fit index as a function of the soft-thresholding power
plot(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     xlab="Soft Threshold (power)",ylab="Scale Free Topology Model Fit,signed R^2",type="n",
    main = paste("Scale independence"));
text(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
    labels=powers,cex=cex1,col="red");
# this line corresponds to using an R^2 cut-off of h
abline(h=0.90,col="red")
# Mean connectivity as a function of the soft-thresholding power
plot(sft$fitIndices[,1], sft$fitIndices[,5],
    xlab="Soft Threshold (power)",ylab="Mean Connectivity", type="n",
    main = paste("Mean connectivity"))
text(sft$fitIndices[,1], sft$fitIndices[,5], labels=powers, cex=cex1,col="red")

sft$powerEstimate

#NEWT
net = blockwiseModules(exp, power = 16, maxBlockSize = 81000,
                       TOMType = "unsigned", minModuleSize = 30,
                       reassignThreshold = 0, mergeCutHeight = 0.25,
                       numericLabels = TRUE, pamRespectsDendro = FALSE,
                       saveTOMs = TRUE,
                       saveTOMFileBase = "All-TPM-TOM",
                       verbose = 3)



##Trajectory



#step1: prepare input data for monocle:
library(Seurat)
embryoendo.counts<-data.frame(embryoendo.@assays$Spatial@counts)
embryoendo.cell<-data.frame(cluster=embryoendo.$seurat_clusters,batch=embryoendo.$sample,celltype=embryoendo.$celltype)
embryoendo.gene<-data.frame(row.names=rownames(embryoendo.counts),gene_short_name=rownames(embryoendo.counts))
embryoendo.fea<-embryoendo.@assays$RNA@var.features
rownames(embryoendo.cell)<-gsub("-",".",rownames(embryoendo.cell))
#step2: constrcut trajectory of embryo/endosperm cells with three rounds of fine-tuning.
##round1:
cell.data<-new("AnnotatedDataFrame",data=embryoendo.cell)
gene.data<-new("AnnotatedDataFrame",data=embryoendo.gene)
embryoendo.cds<-newCellDataSet(as.matrix(embryoendo.counts), phenoData = cell.data, featureData = gene.data,expressionFamily=negbinomial.size())
embryoendo.cds<-estimateSizeFactors(embryoendo.cds)
embryoendo.cds<-estimateDispersions(embryoendo.cds)
embryoendo.cds <- setOrderingFilter(embryoendo.cds, embryoendo.fea)
embryoendo.cds <- reduceDimension(embryoendo.cds, max_components = 2,method = 'DDRTree')
embryoendo.cds <- orderCells(embryoendo.cds)
deg.by.pseudotime<-differentialGeneTest(embryoendo.cds,fullModelFormulaStr = "~sm.ns(Pseudotime)")
sig.deg.psudotime<-rownames(deg.by.pseudotime[deg.by.pseudotime$qval <0.01,])
##round2:
embryoendo.cds<-estimateSizeFactors(embryoendo.cds)
embryoendo.cds<-estimateDispersions(embryoendo.cds)
embryoendo.cds <- setOrderingFilter(embryoendo.cds, sig.deg.psudotime)
embryoendo.cds <- reduceDimension(embryoendo.cds, max_components = 2,method = 'DDRTree')
embryoendo.cds <- orderCells(embryoendo.cds)
P1deg.by.pseudotime<-differentialGeneTest(embryoendo.cds,fullModelFormulaStr = "~sm.ns(Pseudotime)")
P1deg.by.pseudotime.sorted<- P1deg.by.pseudotime[order(P1deg.by.pseudotime$qval),]
newfea<-as.character(rownames(P1deg.by.pseudotime.sorted[c(1:3000),]))
##round3:
embryoendo.cds<-estimateSizeFactors(embryoendo.cds)
embryoendo.cds<-estimateDispersions(embryoendo.cds)
embryoendo.cds <- setOrderingFilter(embryoendo.cds, newfea)
embryoendo.cds <- reduceDimension(embryoendo.cds, max_components = 2,method = 'DDRTree')
embryoendo.cds <- orderCells(embryoendo.cds)
pdf(file="embryoendo.pseudotime.P2fea.pdf",width=5,height=5)
plot_cell_trajectory(embryoendo.cds, color_by = "Pseudotime")
dev.off()
pdf(file="embryoendo.ct_P2fea.pdf",width=8,height=8)
plot_cell_trajectory(embryoendo.cds,color_by = "celltype")
dev.off()
pdf(file="embryoendo.sample_P2fea.pdf",width=5,height=5)
plot_cell_trajectory(embryoendo.cds,color_by = "batch")
dev.off()
P2deg.by.pseudotime<-differentialGeneTest(embryoendo.cds,fullModelFormulaStr = "~sm.ns(Pseudotime)")
