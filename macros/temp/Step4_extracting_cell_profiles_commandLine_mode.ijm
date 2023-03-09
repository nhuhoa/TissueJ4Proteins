//======================================================================================
//// STEP4: Extracting cell profiles

// Parameters
save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/"; 
percent_marker= 0.2;
radius_extension_nuc_cellPeriphery = 3; //change this threshold if your cell zone area in the image is smaller, depend on image resolution, in general 3 to 5 is a good one. 

seg_nuc_image_fn="C6-NUC_SEG.tif";
open(save_dir+seg_nuc_image_fn);

// filtered marker channels
open(save_dir+"C1-BFP_filtered.tif");
open(save_dir+"C2-tSapphire_filtered.tif");
open(save_dir+"C3-venus_filtered.tif");
open(save_dir+"C4-tomato_filtered.tif");
open(save_dir+"C5-katushka_filtered.tif");

// binary image: object and background
open(save_dir+"C1-BFP_binary.tif");
open(save_dir+"C2-tSapphire_binary.tif");
open(save_dir+"C3-venus_binary.tif");
open(save_dir+"C4-tomato_binary.tif");
open(save_dir+"C5-katushka_binary.tif");


run("EXTRACTING CELL PROFILES", "save_dir="+save_dir+" segmeted="+seg_nuc_image_fn+" binary=C1-BFP_binary.tif raw=C1-BFP_filtered.tif binary_0=C2-tSapphire_binary.tif raw_0=C2-tSapphire_filtered.tif binary_1=C3-venus_binary.tif raw_1=C3-venus_filtered.tif binary_2=C4-tomato_binary.tif raw_2=C4-tomato_filtered.tif binary_3=C5-katushka_binary.tif raw_3=C5-katushka_filtered.tif percent_marker="+percent_marker+" watershed_cell_radius="+radius_extension_nuc_cellPeriphery);
print("Complete!!!");
run("Close All"); 
