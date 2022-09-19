library(ggplot2)
library(ggrepel)


# df: coordinates of sub populations of cell phenotypes
# xcoord, ycoord
# nb_cells: nb cells 
# celltype_desc: ex: Katuska_Venus
viz_downsample_phenotype <- function(df, col=NULL){
  
  if(is.null(col)){
    cts <- gtools::mixedsort(unique(df$celltype_desc))
    nbcelltypes <- length(cts)
    col <- colorRampPalette(brewer.pal(8, "Set2"))(nbcelltypes)
    names(col) <- cts
  }
  # df$nb_cells <- round(log2(sample(10:1000, dim(df)[1])),2)
  p <- ggplot(df, aes(x = xcoord, y = ycoord)) + 
    geom_point(aes(color = celltype_desc, size=nb_cells)) + 
    # geom_text(aes(label=celltype_desc))+
    annotate('text', x = genes$xcoord, y = -log10(genes$ycoord), label = genes$celltype_desc)+
    scale_color_manual(values = col) +
    theme_bw(base_size = 12) + 
    theme(legend.position = "bottom",
          panel.grid = element_blank(),
          axis.ticks = element_blank(),
          axis.text  = element_blank(),
          axis.title = element_blank()) + 
    geom_text_repel( data = genes, aes(label = celltype), max.overlaps = Inf,
                     size = 2, box.padding = unit(0.35, "lines"), point.padding = unit(0.3, "lines") )
  png(paste0(save_dir,"test_graph.png"), height = 2*400, width=2*400,res = 2*72)
  print(p)
  dev.off()
  return(p)
  
}
viz_downsample_phenotype(df)




# genes <- read.table("https://gist.githubusercontent.com/stephenturner/806e31fce55a8b7175af/raw/1a507c4c3f9f1baaa3a69187223ff3d3050628d4/results.txt", header = TRUE)
# genes$Significant <- ifelse(genes$padj < 0.05, "FDR < 0.05", "Not Sig")
# p <- ggplot(genes, aes(x = log2FoldChange, y = -log10(pvalue))) + 
#   geom_point(aes(color = Significant)) + 
#   scale_color_manual(values = c("red", "grey")) + 
#   theme_bw(base_size = 12) + 
#   theme(legend.position = "bottom") + 
#   geom_text_repel( data = subset(genes, padj < 0.05), aes(label = Gene), size = 5, box.padding = unit(0.35, "lines"), point.padding = unit(0.3, "lines") )
# p
# 
# genes <- genes[order(abs(genes$log2FoldChange)),]
# View(head(genes))
# genes <- genes[1:10,]
# genes$celltype <- paste0('C_',sample(1:5, dim(genes)[1], replace=T))
# genes$celltype_desc <- gsub('C_','',genes$celltype)
# genes$celltype <- gsub('C_','aaaaaaadddd',genes$celltype)
# cts <- gtools::mixedsort(unique(genes$celltype_desc))
# nbcelltypes <- length(cts)
# col <- colorRampPalette(brewer.pal(8, "Set2"))(nbcelltypes)
# names(col) <- cts
# genes$nb_cells <- round(log2(sample(10:1000, dim(genes)[1])),2)
# p <- ggplot(genes, aes(x = log2FoldChange, y = -log10(pvalue))) + 
#   geom_point(aes(color = celltype_desc, size=nb_cells)) + 
#   # geom_text(aes(label=celltype_desc))+
#   annotate('text', x = genes$log2FoldChange, y = -log10(genes$pvalue), label = genes$celltype_desc)+
#   scale_color_manual(values = col) +
#   theme_bw(base_size = 12) + 
#   theme(legend.position = "bottom",
#         panel.grid = element_blank(),
#         axis.ticks = element_blank(),
#         axis.text  = element_blank(),
#         axis.title = element_blank()) + 
#   geom_text_repel( data = genes, aes(label = celltype), max.overlaps = Inf,
#                    size = 2, box.padding = unit(0.35, "lines"), point.padding = unit(0.3, "lines") )
# p
# 
# 
