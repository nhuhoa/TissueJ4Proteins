## Installation 
## Install R packages
# BiocManager::install("dplyr")
# BiocManager::install("stringr")
# BiocManager::install("RColorBrewer")
# BiocManager::install("ggplot2")
# BiocManager::install("viridis")
# install.packages("igraph")
# BiocManager::install("ComplexHeatmap")
# BiocManager::install("argparse")
suppressPackageStartupMessages({
  # library(dplyr)
  # library(stringr)
  # library(RColorBrewer)
  # library(ggplot2)
  # library(viridis)
  library(argparse)
})

print("Identifing cell types based on cell profiles")

parser <- ArgumentParser(description = "Identifing cell types based on cell profiles")
parser$add_argument('--cell_profiles_fn', metavar='FILE', type='character',
                    help="Path to cell profiles file, ex: cell_profiles.csv.gz")
parser$add_argument('--meta_clones_fn', type = 'character', 
                    help="Meta data file with predefined clone labels")
parser$add_argument('--datatag', type = 'character', 
                    help="Datatag")
parser$add_argument('--save_dir', type = 'character',default = NULL,
                    help="Directory where to save output of computation, if null, using the input directory where contains cell profiles input file")
parser$add_argument('--thres_pct_marker', type = 'character', default = '15',
                    help="Optional param, percentage of given marker to consider the present, absent, default at least 15% of marker cover the cell zone, input a value between [1,100]")
parser$add_argument('--oriImg_sizeX', type = 'character', default = NULL,
                    help="Optional param, size of input image in X direction, to reconstruct the visualization")
parser$add_argument('--oriImg_sizeY', type = 'character', default = NULL,
                    help="Optional param, size of input image in Y direction, to reconstruct the visualization")
parser$add_argument('--small_objs_area', type = 'character', default = '50',
                    help="Optional param, remove objects with pixel volume smaller than this size")
parser$add_argument('--visualize_data', type = 'character', default = 'YES',
                    help="Optional param, to visualizing cells profiles within tissue space")

args <- parser$parse_args()





main <- function(cell_profiles_fn, datatag, save_dir, thres_pct_marker=15,
                 oriImg_sizeX=NULL, oriImg_sizeY=NULL, small_objs_area=50, visualize_data='YES'){
  
  # small_objs_area <- as.numeric(small_objs_area)
  
  ## First, loading all functions from utils_graph.R file under script_dir. You can change script_dir to point to where you keep untils_graph.R file
  script_dir <- paste0(dirname(cell_profiles_fn),'/')
  source(paste0(script_dir, 'utils_graph.R')) ## loading utility functions from this R script file  
  
  # edges_fn <- paste0(input_dir,datatag,'/cell_interactions.csv.gz')
  ## Filtering out the small cells
  if(is.null(save_dir)){
    save_dir <- paste0(dirname(cell_profiles_fn),'/')
  }
  if(!dir.exists(save_dir)){
    dir.create(save_dir)  
  }
  
  ## Defining different clones/ cell types
  meta_clones_fn <- paste0(save_dir,'predefined_clones.csv')
  meta_clones <- get_reference_clones(meta_clones_fn)
  nodes_df <- data.table::fread(cell_profiles_fn) %>% as.data.frame()
  print(dim(nodes_df))
  # edges_df <- data.table::fread(edges_fn) %>% as.data.frame() ## To Do
  # print(dim(edges_df))
  # colnames(nodes_df)
  
  
  ## Removing too small objects
  if(small_objs_area>0){
    print(paste0("Filtering very small objects with size smalller than ",small_objs_area))
    # print(dim(nodes_df)[1])
    nb_cells <- dim(nodes_df)[1]
    nodes_df <- nodes_df %>%
      dplyr::filter(CellPixVol>small_objs_area)
    # print(dim(nodes_df)[1])
    nb_cells <- nb_cells-dim(nodes_df)[1]
    print(paste0("Excluded ", nb_cells, " small objects from analysis"))
  }
  
  edges_df <- NULL # To Do, need to write a function to compute the cell-cell contact for big dataset
  
  
  ## Define cell type based on percentage of coverage and mean intensity of each marker within a cell region
  res <- get_celltype_v4(nodes_df, edges_df, 
                         save_dir, datatag, 
                         celltype_by_pct=T, save_data=T, thres_vol_marker=thres_pct_marker)

  ## Define cell type based on percentage of coverage and mean intensity of each marker within a cell region
  # res <- get_celltype_v4(nodes_df, edges_df, 
  #                        save_dir, datatag, 
  #                        celltype_by_pct=F, save_data=T, thres_vol_marker=15, 
  #                        thrsBFP=20, thrstSapphire=50, thrsVenus=50,
  #                        thrsTomato=70, thrsKatushka=20)
  
  
  
  # cols_use <- meta_clones$cluster_color
  # names(cols_use) <- meta_clones$clone_id
  if(visualize_data=='YES'){
    if(is.null(oriImg_sizeX) || is.null(oriImg_sizeY)){
      viz_wholetissue_v2(res$nodes, save_dir, datatag, meta_clones_fn, 
                         col=NULL, invert_coord=T, marker_intensity_viz=F, xmax= NULL, ymax=NULL)  
    }else{
      oriImg_sizeX <- as.numeric(oriImg_sizeX)
      oriImg_sizeY <- as.numeric(oriImg_sizeY)
      viz_wholetissue_v2(res$nodes, save_dir, datatag, meta_clones_fn, 
                         col=NULL, invert_coord=T, marker_intensity_viz=F, xmax=oriImg_sizeX, ymax=oriImg_sizeY)  
    }  
  }else{
    cell_type_stat(res$nodes, meta_clones, save_dir, datatag)
  }
  
  
}




## How to run the file from terminal on MacOS, Linux
# Rscript detect_clone_label_MultiPDX_Ms1134.R --save_dir /Users/htran/Documents/storage_tmp/TissueJ4Proteins-main/analysis/MultiPDXs_Ms1134/results/ --thres_pct_marker 15 --cell_profiles_fn /Users/htran/Documents/storage_tmp/TissueJ4Proteins-main/analysis/MultiPDXs_Ms1134/cell_profiles.csv.gz --datatag MultiPDXs_Ms1134 --oriImg_sizeX 27864 --oriImg_sizeY 25920 --small_objs_area 50 --visualize_data NO

## How to run the file from Windows command line CMD 
## https://datacornering.com/how-to-run-r-scripts-from-the-windows-command-line-cmd/
## ex: "C:\Program Files\R\R-3.4.3\bin\Rscript.exe" C:\yourDirectory\detect_clone_label_MultiPDX_Ms1134.R
## Execute file
# save_dir <- args$save_dir
# cell_profiles_fn <- args$cell_profiles_fn
# datatag <- args$datatag
# oriImg_sizeX <- as.numeric(args$oriImg_sizeX)
# oriImg_sizeY <- as.numeric(args$oriImg_sizeY)
# small_objs_area <- as.numeric(args$small_objs_area)

main(args$cell_profiles_fn, args$datatag, args$save_dir, as.numeric(args$thres_pct_marker),
     args$oriImg_sizeX, args$oriImg_sizeY, as.numeric(args$small_objs_area), args$visualize_data)


## Or include the input parameters here
## Execute file
# datatag <- 'MultiPDXs_Ms1134'
# save_dir <- "/Users/htran/Documents/storage_tmp/TissueJ4Proteins-main/analysis/MultiPDXs_Ms1134/results/"
# cell_profiles_fn <- "/Users/htran/Documents/storage_tmp/TissueJ4Proteins-main/analysis/MultiPDXs_Ms1134/cell_profiles.csv.gz"
# # meta_clones_fn <- paste0(input_dir,datatag,'/predefined_clones.csv')
# oriImg_sizeX=27864
# oriImg_sizeY=25920
# small_objs_area=50
# 
# main(cell_profiles_fn, datatag, save_dir, oriImg_sizeX, oriImg_sizeY, small_objs_area)



# cell_profiles_fn <- "/Users/htran/Documents/storage_tmp/TissueJ4Proteins-main/analysis/MultiPDXs_Ms1134/cell_profiles.csv.gz"
# df <- data.table::fread(cell_profiles_fn)
# colnames(df)
# 
# 
# View(head(df))


