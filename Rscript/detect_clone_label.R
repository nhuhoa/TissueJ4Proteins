library(dplyr)
library(stringr)
library(RColorBrewer)
library(ggplot2)
library(viridis)

curr_dir <- getwd()
source(paste0(curr_dir, '/utils_graph.R'))

script_dir <- '/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/Rscript/'
input_dir <- '/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/analysis/'

script_dir <- '/Users/htran/Documents/storage_tmp/TissueJ4Proteins-main/Rscript/'
input_dir <- '/Users/htran/Documents/storage_tmp/TissueJ4Proteins-main/analysis/'

meta_clones_fn <- paste0(script_dir,'predefined_clones_v2.csv')
datatag <- 'MultiPDXs_Ms1134'
nodes_fn <- paste0(input_dir,datatag,'/cell_profiles.csv.gz')
save_dir <- paste0(input_dir,datatag,'/results/')
cell_profiles_fn <- paste0(save_dir,'filtered_cell_profiles.csv.gz')

## size of input image:
xmax=27864
ymax=25920
# edges_fn <- paste0(input_dir,datatag,'/cell_interactions.csv.gz')
## Filtering out the small cells
small_objs_area=50

viz_cells <- function(nodes_fn, edges_fn, meta_clones_fn, datatag, save_dir, small_objs_area=0){
  meta_clones <- get_reference_clones(meta_clones_fn)
  if(!dir.exists(save_dir)){
    dir.create(save_dir)  
  }
  
  nodes_df <- data.table::fread(nodes_fn) %>% as.data.frame()
  print(dim(nodes_df))
  # edges_df <- data.table::fread(edges_fn) %>% as.data.frame() ## To Do
  # print(dim(edges_df))
  colnames(nodes_df)
  if(small_objs_area>0){
    print(paste0("Filtering very small objects with size smalller than ",small_objs_area))
    print(dim(nodes_df)[1])
    nodes_df <- nodes_df %>%
      dplyr::filter(CellPixVol>small_objs_area)
    print(dim(nodes_df)[1])
  }
  
  
  res <- get_celltype_v4(nodes_df, edges_df, 
                        save_dir=T, datatag, 
                        celltype_by_pct=T, save_data=T, thres_vol_marker=15, 
                        thrsBFP=20, thrstSapphire=50, thrsVenus=50,
                        thrsTomato=70, thrsKatushka=20)
  metaclone_df <- data.table::fread(paste0(script_dir,'predefined_clones_v2.csv')) %>% as.data.frame()
  # head(metaclone_df)
  cols_use <- metaclone_df$cluster_color
  names(cols_use) <- metaclone_df$clone_id
  viz_wholetissue(save_dir, datatag, xmax, ymax, 
                  col=cols_use, invert_coord=T)
}




datatag <- "lung_Ms876"
# BiocManager::install("gtools")
# ls_clones <- list(markers, combn(markers, 2),combn(markers, 3),combn(markers, 4))
script_dir <- '/Users/hoatran/Documents/jean_project/data/script/'
meta_clones_fn <- paste0(save_dir,'predefined_clones_v2.csv')
nodes_fn <- paste0(input_dir,'testing_cell_type/CT/',datatag,'_nodes.csv')
edges_fn <- paste0(input_dir,'testing_cell_type/CT/',datatag,'_edges.csv')
datatag <- 'smalltissue'
viz_cells <- function(nodes_fn, edges_fn, meta_clones_fn, datatag, small_objs_area=0){
  meta_clones <- get_reference_clones(meta_clones_fn)
  input_dir <- '/Users/hoatran/Documents/jean_project/data/small_tissue/'
  save_dir <- paste0(input_dir,'testing_cell_type/CT/')
  nodes_df <- data.table::fread(nodes_fn) %>% as.data.frame()
  print(dim(nodes_df))
  edges_df <- data.table::fread(edges_fn) %>% as.data.frame()
  print(dim(edges_df))
  
  if(small_objs_area>0){
    nodes_df <- nodes_df %>%
      dplyr::filter(pixvol>small_objs_area)
    print(dim(nodes_df))
  }
  
  res <- get_celltype(nodes_df, edges_df, save_dir, datatag, 
                       save_data=T, thres_vol_marker=0.2)
  
  viz_wholetissue(save_dir, datatag, xmax=NULL, ymax=NULL, 
                              col=NULL, invert_coord=F)
}

cellsnetwork_analysis <- function(){
  g <- readRDS(paste0(save_dir,'graph_ct.rds'))
  res <- get_edges_nodes_from_igraph(g)
  edges <- res$edges
  nodes <- res$nodes
  connect_mtx <- compute_cell_cell_interaction(edges, nodes, save_dir)
  connect_mtx <- data.table::fread(paste0(save_dir,'connect_mtx.csv')) %>% as.data.frame()
  dim(connect_mtx)
  pct_ct <- table(nodes$cellphenotype)
  class(pct_ct)
  pct_ct <- pct_ct[rownames(connect_mtx)]
  pct_ct <- as.vector(pct_ct)
  rownames(meta_clones) <- meta_clones$clone_id
  meta_clones <- meta_clones[rownames(connect_mtx),]
  col=meta_clones$cluster_color
  names(col) <- meta_clones$clone_id
  hm <- viz_heatmap_cellphenotype(log2(connect_mtx), log2(pct_ct), save_dir, col)
  mat <- log2(connect_mtx+1)
  pct_ct <- log2(pct_ct)
  
}






script_dir <- '/Users/hoatran/Documents/jean_project/data/script/'
meta_clones_fn <- paste0(save_dir,'predefined_clones_v2.csv')
meta_clones <- get_reference_clones(meta_clones_fn)

View(meta_clones)
# meta_clones$clone_desc

datatag <- 'smalltissue'
xmax=1250
ymax=1250
input_dir <- '/Users/hoatran/Documents/jean_project/data/small_tissue/'
save_dir <- paste0(input_dir,'testing_cell_type/CT/')
nodes_df <- data.table::fread(paste0(input_dir,'testing_cell_type/CT/',datatag,'_nodes.csv')) %>% as.data.frame()
dim(nodes_df)
edges_df <- data.table::fread(paste0(input_dir,'testing_cell_type/CT/',datatag,'_edges.csv')) %>% as.data.frame()
dim(edges_df)

summary(nodes_df$C2_tSapphire_mean_corerage)
sum(nodes_df$C3_Venus_mean_intensity>50)
nodes_df <- data.table::fread(paste0(save_dir, datatag,'_nodes_ct.csv.gz')) %>% as.data.frame()
dim(nodes_df)


df <- data.table::fread(paste0(save_dir,'collapse_', datatag,'_nodes.csv')) %>% as.data.frame()
dim(df)
unique(df$celltype)

g <- readRDS(paste0(save_dir,'graph_ct.rds'))
res <- get_edges_nodes_from_igraph(g)
edges <- res$edges
nodes <- res$nodes
connect_mtx <- compute_cell_cell_interaction(edges, nodes, save_dir)
connect_mtx <- data.table::fread(paste0(save_dir,'connect_mtx.csv')) %>% as.data.frame()
dim(connect_mtx)
pct_ct <- table(nodes$cellphenotype)
class(pct_ct)
pct_ct <- pct_ct[rownames(connect_mtx)]
pct_ct <- as.vector(pct_ct)
rownames(meta_clones) <- meta_clones$clone_id
meta_clones <- meta_clones[rownames(connect_mtx),]
col=meta_clones$cluster_color
names(col) <- meta_clones$clone_id
hm <- viz_heatmap_cellphenotype(log2(connect_mtx), log2(pct_ct), save_dir, col)
mat <- log2(connect_mtx+1)
pct_ct <- log2(pct_ct)

datatag <- 'lung_Ms876'
xmax=7344
ymax=18036
input_dir <- '/Users/hoatran/Documents/jean_project/data/lung_Ms876/CELL_TYPE/'
save_dir <- paste0(input_dir,'figs/')
dir.create(save_dir)

nodes_df1 <- data.table::fread(paste0(input_dir,'Ms876_Lung_C1_nodes.csv')) %>% as.data.frame()
nodes_df2 <- data.table::fread(paste0(input_dir,'Ms876_Lung_C2_nodes.csv')) %>% as.data.frame()
nodes_df3 <- data.table::fread(paste0(input_dir,'Ms876_Lung_C3_nodes.csv')) %>% as.data.frame()
tag <- 'C01'
summary(nodes_df1$pixvol)
nodes_df1 <- nodes_df1 %>%
  dplyr::filter(pixvol>=50)
dim(nodes_df1)
nodes_df1 <- get_cell_type_stat(nodes_df1, tag, thres_vol=0.3, min_cells_counts=5)

tag <- 'C02'
nodes_df2 <- get_cell_type_stat(nodes_df2, tag, thres_vol=0.3, min_cells_counts=5)
nodes_df2$y <- nodes_df2$y + 6000

tag <- 'C03'
nodes_df3 <- get_cell_type_stat(nodes_df3, tag, thres_vol=0.3, min_cells_counts=5)
nodes_df3$y <- nodes_df3$y + 12000

nodes_df <- dplyr::bind_rows(nodes_df1, nodes_df2, nodes_df3)
data.table::fwrite(nodes_df, paste0(save_dir,'total_nodes_celltype.csv'))
dim(nodes_df)
nodes_df$cluster_label



datatag <- 'vitro'
xmax=12204
ymax=8721
input_dir <- '/Users/hoatran/Documents/jean_project/data/vitro_5533/'
save_dir <- paste0(input_dir,'cell_type_v2/')
dir.create(save_dir)
facs_fn <- '/Users/hoatran/Documents/jean_project/data/vitro_5533/FACS/FACS.csv'
nodes_df1 <- data.table::fread(paste0(input_dir,'cell_type_v2/nuc_model_2D_versatile_fluo_C01_nodes.csv'))
edges_df1 <- data.table::fread(paste0(input_dir,'cell_type_v2/nuc_model_2D_versatile_fluo_C01_edges.csv'))
nodes_df2 <- data.table::fread(paste0(input_dir,'cell_type_v2/nuc_model_2D_versatile_fluo_C02_nodes.csv'))
edges_df2 <- data.table::fread(paste0(input_dir,'cell_type_v2/nuc_model_2D_versatile_fluo_C02_edges.csv'))
datatag <- 'vitro_C01'
nodes_df1 <- nodes_df1 %>%
  dplyr::filter(pixvol>=50)
dim(nodes_df1)
res1 <- get_celltype(nodes_df1, edges_df1, save_dir, datatag, save_data=T, thres_vol_marker=0.2)

datatag <- 'vitro_C02'
nodes_df2 <- nodes_df2 %>%
  dplyr::filter(pixvol>=50)
dim(nodes_df2)
res2 <- get_celltype(nodes_df2, edges_df2, save_dir, datatag, save_data=T, thres_vol_marker=0.2)

nodes_df1 <- res1$nodes
nodes_df2 <- res2$nodes
dim(nodes_df1)

nodes_df1$pcell_id <- paste0('C01_',nodes_df1$cell_id)
nodes_df2$pcell_id <- paste0('C02_',nodes_df2$cell_id)
nodes_df <- dplyr::bind_rows(nodes_df1,nodes_df2)
data.table::fwrite(nodes_df, paste0(save_dir,'total_nodes_celltype_v3.csv'))
dim(nodes_df)
facs_df <- data.table::fread(facs_fn) %>% as.data.frame()
nodes_df$cluster_label[1]
facs_df$cluster_label <- facs_df$CellType
facs_df$cluster_label <- paste0('Clone_',facs_df$cluster_label)

nodes_df <- nodes_df %>%
  dplyr::filter(pixvol>=50)

t <- table(nodes_df$cluster_label)
stat <- data.frame(count=as.numeric(t), cluster_label=names(t))
data.table::fwrite(stat, paste0(save_dir,'nb_celltypes_v3.csv'))
stat <- data.table::fread(paste0(save_dir,'nb_celltypes_v1.csv'))
dim(stat)
df <- stat

colnames(df)
facs_df <- facs_df %>%
  dplyr::rename(FACS_counts=Counts)
df <- facs_df %>% inner_join(stat, by=c("cluster_label"))
View(df)
# df <- df %>% 
#   dplyr::filter(cluster_label!="Clone_31")
# 
# df <- df %>% 
#   dplyr::filter(cluster_label!="Clone_31")
# cr <- cor(df$FACS_counts[1:6], df$count[1:6], method = 'spearman')
# 
# cr <- cor(df$FACS_counts, df$count, method = 'spearman')
# cr

View(df)
df$cluster_label
df <- df %>%
  dplyr::rename(imaging_counts=count, FACS_CellType=CellType, FACS_Percent=Percent)
data.table::fwrite(df, paste0(save_dir,'total_nodes_celltype.csv'))
viz_facs_imaging_summary_results()

# input_dir <- '/Users/hoatran/Documents/storage_tmp/merfish_images/performance_XP37_05122021/'
# df <- data.table::fread(paste0(input_dir,'performance_set.csv'))
# View(head(df))
# genes <- unique(df$gene[!grepl('Blank',df$gene)])
# length(genes)
# blks <- unique(df$gene[grepl('Blank',df$gene)])
# length(blks)



# Correlation results between FACS and imaging cells type:
# 
#   1) For first 6 clones in this csv file: Clone1: eBFP2, Clone2: tSapphire, Clone 3: eBFP2, tSapphire, Clone4: Venus, Clone 5: eBFP2, Venus, Clone6: tSapphire, Venus
# 
#   - Version 1 of hyteresis thresholding: good Spearman correlation cor > 0.9
#   - Version 2 of hyteresis thresholding: Spearman correlation cor=0.771, version 1 provide better results.
# 
#   2) In case removing all clones that contain tdTomato:
#   - Version 1 of hyteresis thresholding:Acceptable Spearman correlation cor > 0.66 for ~15 clones
#   - Version 2 of hyteresis thresholding: Spearman correlation cor==0.598 for ~15 clones, version 1 provide better results.
#   
#   3) In case taking into account all clones:
#   - Version 1 of hyteresis thresholding: cor=0.23
#   - Version 2 of hyteresis thresholding: cor=0.324, version 2 provide better results.

