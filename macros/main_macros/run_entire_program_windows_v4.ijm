//======================================================================================
//// Installation
//// See at https://github.com/nhuhoa/Spatial3DTissueJ/tree/master/ImageJ_plugins_jar/list_plugin_readme.txt
//// First, you can copy these 3 folders into Fiji/plugins/ or ImageJ/plugins/ and quick check if there is any duplicate plugin, ex: 3DViewerXXXvXXX//// .jar, Fiji_PluginXXX.jar. You can keep only one version for each plugin. 
//// To update plugins, you can delele the folder 3D_suite/ and replace by the most updated folder from my github, most updated plugin: Spatial3DTissueJ_v22_windows.jar

//======================================================================================
//// Preparation
//// Create a folder for each islet, ex: H1536_islet1/ and put composite image of a given islet into this folder. 
//// Copy the color mapping file into this folder H1536_islet1/: cell_type_colormap.lut
////When you download github files, you have this file in the github folder: https://github.com/nhuhoa/Spatial3DTissueJ/tree/master/macro/macro_windows/cell_type_colormap.lut
//// Noted: cell_type_colormap.lut is just a color map for visualization, if macro has an issue with this file, you can just remove the line 

//======================================================================================
//// How to run a macro here
//// I divide macro into many steps, you can run one by one step here
//// And then when you don't see any error, you can try to run entire pipeline
//// Macros works well in Linux, Mac. I fix some bugs in Windows system before, so I think macro works well with Windows too. If you see any issue, pls inform me to fix it.



setBatchMode(true);
print("___________________________________________");


//======================================================================================
//// STEP1: Splitting composite images into different channels using Bio-Formats plugins
//// Example of windows input directory
//// dir="C:/Users/SALAB VR/Documents/Hoa/Spatial3DTissueJ-master/small_tissue/";

//// Noted: I name the images as: "C1-BFP.tif", "C2-tSapphire.tif", "C3-venus.tif", "C4-tomato.tif", "C5-katushka.tif", "C6-NUC.tif"
//// just a convention, easy to remember it. 
//// 6 channels image with channel 1: BFP / 2: tSapphire / 3:Venus / 4:Tomato/ 5:Katushka/ 6:Draq5 (nuclei staining)**


// Please modify the dir input directory parameter here
//dir="/Users/hoatran/Documents/jean_project/data/small_tissue/raw_channels/";
dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/small_tissue/";
save_dir=File.getParent(dir)+"/testing_macros/";
if(!File.exists(save_dir)) 
      File.mkdir(save_dir);

composite_image_fn="Ms870_Co_MDA5C_D5_Lung1_Stich_Met01.czi";
run("Bio-Formats Importer", "open="+dir+composite_image_fn+" autoscale color_mode=Default split_channels view=Hyperstack stack_order=XYCZT");

selectWindow(composite_image_fn+" - C=0");
saveAs("ZIP", save_dir+"C1-BFP.zip");

selectWindow(composite_image_fn+" - C=1");
saveAs("ZIP", save_dir+"C2-tSapphire.zip");

selectWindow(composite_image_fn+" - C=2");
saveAs("ZIP", save_dir+"C3-venus.zip");

selectWindow(composite_image_fn+" - C=3");
saveAs("ZIP", save_dir+"C4-tomato.zip");

selectWindow(composite_image_fn+" - C=4");
saveAs("ZIP", save_dir+"C5-katushka.zip");

selectWindow(composite_image_fn+" - C=5");
saveAs("ZIP", save_dir+"C6-NUC.zip");

print("Splitting images and save into folders with the naming convention: ");
print("1: BFP, 2: tSapphire, 3:Venus, 4:Tomato, 5:Katushka, 6:Draq5 (nuclei staining)");
print("Save separated images into folder: "+save_dir);
print("First step completed!");
run("Close All"); 





//======================================================================================
////  STEP2: Hysteresis Threshold for background cut off 
//// I know the way we define the threshold is a bit manual here 
//// but if you have same microscopy setting, you may need to define it once 
//// and reuse the set of parameters many times


//======================================================================================
////  STEP21: Hysteresis Threshold for background cut off 

function remove_background_using_hysteresis_threshold(image_fn_zip, low_thrs, high_thrs, save_dir, normalize_img) {
open(save_dir + image_fn_zip);  
suffixe_filename=".zip";
image_fn_short = substring(image_fn_zip,0,lastIndexOf(image_fn_zip,suffixe_filename));
image_fn = image_fn_short + ".tif";
print("Removing background using hysteresis threshold method from image: "+image_fn);
print("Low threshold: "+low_thrs);
print("High threshold: " + high_thrs);
selectWindow(image_fn);
run("Duplicate...", "duplicate title=["+image_fn_short+"_hysteresis_thresh]");
selectWindow(image_fn_short+"_hysteresis_thresh");
if (bitDepth > 8) {run("8-bit");}
run("Median...", "radius=2");
////if you have same microscopy setting, you may need to define it once and reuse the set of parameters many times
run("3D Hysteresis Thresholding", "high="+high_thrs+" low="+low_thrs+" connectivity"); 

selectWindow(image_fn);
if (bitDepth > 8) {run("8-bit");}
run("Median...", "radius=2");
imageCalculator("AND create stack", image_fn, image_fn_short+"_hysteresis_thresh");

selectWindow(image_fn_short+"_hysteresis_thresh");
//saveAs("Tiff", save_dir+image_fn_short+"_binary.tif");
saveAs("ZIP", save_dir+image_fn_short+"_binary.zip");


selectWindow("Result of "+image_fn);
rename(image_fn_short+"_filtered");

if( normalize_img=="yes"){
print("Normalizing filtered image");
run("NORMALIZING IMAGE", "save_dir="+save_dir+" input_image="+image_fn_short+"_filtered threshold=5");
selectWindow("normalized_"+image_fn_short+"_filtered.tif");
//saveAs("Tiff", save_dir+image_fn_short+"_filtered.tif");
saveAs("ZIP", save_dir+image_fn_short+"_filtered.zip");
File.delete(save_dir+"normalized_"+image_fn_short+"_filtered.tif")


} else{
	print("Without normalizing step");
selectWindow(image_fn_short+"_filtered");
saveAs("ZIP", save_dir+image_fn_short+"_filtered.zip");
	
}

	
//selectWindow(image_fn);
//saveAs("Tiff", save_dir+image_fn);
run("Close All"); 
print("Completed!");


}









//======================================================================================
////  STEP21: Hysteresis Threshold for background cut off 

////Processing BFP marker channels, cut off background, background and intra tissue environment=0
low_thrs=20;
high_thrs=25;
observed_marker_fn="C1-BFP.zip";
save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/"; 
remove_background_using_hysteresis_threshold(observed_marker_fn, low_thrs, high_thrs, save_dir,"yes");

//======================================================================================
////  STEP22: Hysteresis Threshold for background cut off 

////Processing tSapphire marker channels, cut off background, background and intra tissue environment=0
save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/"; 
low_thrs=15;
high_thrs=25;
observed_marker_fn="C2-tSapphire.zip";
remove_background_using_hysteresis_threshold(observed_marker_fn, low_thrs, high_thrs, save_dir,"yes");


//======================================================================================
////  STEP23: Hysteresis Threshold for background cut off 

save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/"; 
low_thrs=15;
high_thrs=25;
observed_marker_fn="C3-venus.zip";
remove_background_using_hysteresis_threshold(observed_marker_fn, low_thrs, high_thrs, save_dir,"yes");



//======================================================================================
////  STEP24: Hysteresis Threshold for background cut off 

save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/"; 
low_thrs=15;
high_thrs=25;
observed_marker_fn="C4-tomato.zip";
remove_background_using_hysteresis_threshold(observed_marker_fn, low_thrs, high_thrs, save_dir,"yes");



//======================================================================================
////  STEP25: Hysteresis Threshold for background cut off 

save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/"; 
low_thrs=5;
high_thrs=10;
observed_marker_fn="C5-katushka.zip";
remove_background_using_hysteresis_threshold(observed_marker_fn, low_thrs, high_thrs, save_dir,"yes");








//======================================================================================
//// STEP3: Nucleus segmentation
//// In 16 bits images, the intensity values are from 0 to 65536, so above 29000 can consider as signal intensity for maximal local intensity values
//// Similar to in 8 bits, ex: values above 120 from the image intensity range of [0, 255]
//// You can manually enter a threshold here or use automatic estimation. I suggest to use automatic seeds threshold estimation because some nucleus images have very low range of intensity, you can not detect object with high threshold above. 
//// For automatic threshold mode, program will calculate the mean value of image, and define the seeds threshold = mean + sd, I define a sd here is 500
//// You can run automatic mode and observe the results, if as not you expected --> increase or decrease threshold and use manual threshold mode. See the log file to have an idea here. 
//// It take ~ 3 mins for this step

small_nucleus_diameter_thrs=8;
large_nucleus_diameter_thrs=14;
save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/"; 
nuc_image_fn_zip="C6-NUC.zip";
suffixe_filename=".zip";
image_fn_short = substring(nuc_image_fn_zip,0,lastIndexOf(nuc_image_fn_zip,suffixe_filename));
nuc_image_fn = image_fn_short + ".tif";
open(save_dir+nuc_image_fn_zip);

//// Using automatic seeds selection mode
//run("SEGMENTING NUCLEUS", "save_dir=["+save_dir+"] dapi="+nuc_image_fn+" maximal="+large_nucleus_diameter_thrs+" minimal="+small_nucleus_diameter_thrs+" seed=20000 automatic");
//selectWindow("dapi-seg.tif"); //automatic save results into folder
// Automatic Seed Threshold estimated is: 18937 - capture many backgrounds as object, need to increase seed threshold here

// Using manual seed threshold setting mode
run("SEGMENTING NUCLEUS", "save_dir=["+save_dir+"] dapi="+nuc_image_fn+" maximal="+large_nucleus_diameter_thrs+" minimal="+small_nucleus_diameter_thrs+" seed=20000");


// Functions for visualization, and facilitate validation step
selectWindow("dapi-seg.tif"); //segmented results from above command
rename(image_fn_short+"_SEG");
//setOption("ScaleConversions", true);
selectWindow(image_fn_short+"_SEG"); 
run("Enhance Contrast", "saturated=0.35");
run("3-3-2 RGB"); //color map for better visualization
//saveAs("Tiff", save_dir+image_fn_short+"_SEG.tif");
saveAs("ZIP", save_dir+image_fn_short+"_SEG.zip");

run("3D Draw Rois", "raw="+image_fn_short+" seg="+image_fn_short+"_SEG");
selectWindow("DUP_"+nuc_image_fn); 
run("Enhance Contrast", "saturated=0.35");
//saveAs("Tiff", save_dir+image_fn_short+"_ROI_"+"_demo_only.tif"); // very useful for validation, and quick check accuracy of nucleus object detection
saveAs("ZIP", save_dir+image_fn_short+"_ROI_"+"_demo_only.zip");
File.delete(save_dir+"BP_C4-dapi.tif"); //delete temporary files
File.delete(save_dir+"dapi-seg.tif"); //delete temporary files
print("Complete!!!");
run("Close All"); 







//======================================================================================
//// STEP31: cell zone estimation, SKIP THIS STEP, ALREADY INCLUDED IN STEP 4
//// Estimating a cell zone for each cell, from each nucleus, extend into space a radius R, ex: R=5 here, then obtained region will be a cell zone. I observe image of dapi and markers to define a max radius for region growing. 
//// Then later, program will look into each cell zone and check the amount of marker that cover this cell zone. 
//// It take ~ 1 mins for this step

//radius_extension_nuc_cellPeriphery = 3; //change this threshold if your cell zone area in the image is smaller, depend on image resolution, in general 3 to 5 is a good one. 
//save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/"; 
//seg_nuc_image_fn="C6-NUC_SEG.tif";
//image_fn_short = substring(seg_nuc_image_fn,0,lastIndexOf(seg_nuc_image_fn,".tif"));
//open(save_dir+seg_nuc_image_fn);
//run("DETECTING CELL ZONE", "save_dir="+save_dir+" nuclei="+seg_nuc_image_fn+" radius_max="+radius_extension_nuc_cellPeriphery+" save");

// Functions for visualization, and facilitate validation step
//selectWindow("dapi-seg-wat.tif");
//run("3-3-2 RGB");
//saveAs("Tiff", save_dir+image_fn_short+ "__WAT.tif"); //color map for better visualization
//File.delete(save_dir+"dapi-seg-wat.tif"); //delete temporary files
//print("Complete!!!");
//run("Close All"); 


//======================================================================================
//// STEP4: Extracting cell profiles

// Parameters
save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/"; 
percent_marker= 0.2;
radius_extension_nuc_cellPeriphery = 3; //change this threshold if your cell zone area in the image is smaller, depend on image resolution, in general 3 to 5 is a good one. 

seg_nuc_image_fn="C6-NUC_SEG.zip";

open(save_dir+seg_nuc_image_fn);
seg_nuc_image_fn="C6-NUC_SEG.tif"; // open from ImageJ, .zip become .tif default format

// filtered marker channels
open(save_dir+"C1-BFP_filtered.zip");
open(save_dir+"C2-tSapphire_filtered.zip");
open(save_dir+"C3-venus_filtered.zip");
open(save_dir+"C4-tomato_filtered.zip");
open(save_dir+"C5-katushka_filtered.zip");

// binary image: object and background
open(save_dir+"C1-BFP_binary.zip");
open(save_dir+"C2-tSapphire_binary.zip");
open(save_dir+"C3-venus_binary.zip");
open(save_dir+"C4-tomato_binary.zip");
open(save_dir+"C5-katushka_binary.zip");


run("EXTRACTING CELL PROFILES", "save_dir="+save_dir+" segmeted="+seg_nuc_image_fn+" binary=C1-BFP_binary.tif raw=C1-BFP_filtered.tif binary_0=C2-tSapphire_binary.tif raw_0=C2-tSapphire_filtered.tif binary_1=C3-venus_binary.tif raw_1=C3-venus_filtered.tif binary_2=C4-tomato_binary.tif raw_2=C4-tomato_filtered.tif binary_3=C5-katushka_binary.tif raw_3=C5-katushka_filtered.tif percent_marker="+percent_marker+" watershed_cell_radius="+radius_extension_nuc_cellPeriphery);

// Save to zip format, reduce file size
seg_cellZone_image_fn="C6-NUC_SEG_WAT";
open(save_dir+seg_cellZone_image_fn+".tif");
saveAs("ZIP", save_dir+seg_cellZone_image_fn+".zip");
File.delete(save_dir+seg_cellZone_image_fn+".tif"); //delete temporary files

print("Complete!!!");
run("Close All"); 


setBatchMode(false);




