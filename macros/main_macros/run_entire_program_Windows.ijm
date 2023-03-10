//======================================================================================
//// Installation
//// First, you can copy 4 plugins folders '3D_suite', '3D_viewer', 'utils', 'spatial3dtissuej_plugin' from https://github.com/nhuhoa/TissueJ4Proteins/tree/main/ImageJ_plugins_jar/ into yourDir/Fiji/plugins/ or yourDir/ImageJ/plugins/ and quick check if there is any duplicated plugin, ex: //// 3DViewer_versionXX.jar, Fiji_Plugin_versionXX.jar. You can keep only one version for each plugin. 

//// 3D_suite: contains core functions, developed by Thomas Boudier's group
//// 3D_viewer: contains visualization functions
//// utils: contains image processing functions
//// ImageJ_plugins_jar: contains functions for protein marker processing

//// If you use ImageJ platform instead of Fiji platform, you also need to add Bio-Format jar package into yourDir/ImageJ/plugins/ folder: download package from: https://downloads.openmicroscopy.org/bio-formats/6.12.0/artifacts/bioformats_package.jar
//// To update plugins, you can replace the older version, ex: spatial3dtissuej_plugin/TissueJ4Protein_v21.jar by the most updated plugin from my github, ex: spatial3dtissuej_plugin/TissueJ4Protein_v25.jar

//======================================================================================
//// Preparation
//// Create a folder for each tissue image and put composite image of a given tissue image of different channels into this folder, ex: TissueJ4Proteins-main/testing_dataset/small_tissue/ in this github. 
//// You can download an testing data file from this github and test program
//// Downloading github: https://github.com/nhuhoa/TissueJ4Proteins/tree/main which contains: testing_dataset/small_tissue/small_tissue.czi

//======================================================================================
//// How to run a macro here
//// I divide macro into many steps, you can run one by one step here
//// And then when you don't see any error, you can try to run entire pipeline
//// Macros works well in Linux, Mac, Windows system. If you encounter any issue, pls inform me to fix it.

//// Change the input dir here by input dir, point to image in your directory and select the script from setBatchMode(true); to setBatchMode(false); and run selected script. 
//// Input dir: ex: yourDir/testing_dataset/small_tissue/: contain composite input image
//// Output dir: ex: yourDir/testing_dataset/testing_macros/: contain all results of computation


//======================================================================================
//// STEP1: Splitting composite images into different channels using Bio-Formats plugins
//// Example of windows input directory
//// dir="C:/Users/SALAB VR/Documents/Hoa/Spatial3DTissueJ-master/small_tissue/";

//// Noted: I name the images as: "C1-BFP.tif", "C2-tSapphire.tif", "C3-venus.tif", "C4-tomato.tif", "C5-katushka.tif", "C6-NUC.tif"
//// just a naming convention, easy to remember it. 
//// 6 channels image with channel 1: BFP / 2: tSapphire / 3:Venus / 4:Tomato/ 5:Katushka/ 6:Draq5 (nuclei staining)
//// Save images as zip compressed format



setBatchMode(true);
print("_________________Step 1__________________________");

// Please modify the dir input parameter here
//dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/small_tissue/";         //Mac, Linux
dir="C:/Users/htran/Downloads/TissueJ4Proteins-main/TissueJ4Proteins-main/testing_dataset/small_tissue/"; //Windows
composite_image_fn="small_tissue.czi";


save_dir=File.getParent(dir)+"/testing_macros/";
if(!File.exists(save_dir)) 
      File.mkdir(save_dir);

run("Bio-Formats Importer", "open="+dir+composite_image_fn+" autoscale color_mode=Default split_channels view=Hyperstack stack_order=XYCZT");

//selectWindow(composite_image_fn+" - C=0");     //Mac, Linux
selectWindow(dir+composite_image_fn+" - C=0");   //Windows
saveAs("ZIP", save_dir+"C1-BFP.zip");

//selectWindow(composite_image_fn+" - C=1");
selectWindow(dir+composite_image_fn+" - C=1");    //Windows
saveAs("ZIP", save_dir+"C2-tSapphire.zip");

//selectWindow(composite_image_fn+" - C=2");
selectWindow(dir+composite_image_fn+" - C=2");    //Windows
saveAs("ZIP", save_dir+"C3-venus.zip");

//selectWindow(composite_image_fn+" - C=3");
selectWindow(dir+composite_image_fn+" - C=3");    //Windows
saveAs("ZIP", save_dir+"C4-tomato.zip");

//selectWindow(composite_image_fn+" - C=4");
selectWindow(dir+composite_image_fn+" - C=4");    //Windows
saveAs("ZIP", save_dir+"C5-katushka.zip");

//selectWindow(composite_image_fn+" - C=5");
selectWindow(dir+composite_image_fn+" - C=5");    //Windows
saveAs("ZIP", save_dir+"C6-NUC.zip");

print("Splitting images and save into folders with the naming convention: ");
print("1: BFP, 2: tSapphire, 3:Venus, 4:Tomato, 5:Katushka, 6:Draq5 (nuclei staining)");
print("Save separated images into folder: "+save_dir);
print("First step completed!");
run("Close All"); 

setBatchMode(false);





//======================================================================================
////  STEP2: Hysteresis Threshold for background cut off 
//// I know the way we define the threshold is a bit manual here 
//// but if you have same microscopy setting, you may need to define it once 
//// and reuse the set of parameters many times


////  STEP21: Hysteresis Threshold for background cut off 

setBatchMode(true);
print("_________________Step 2__________________________");

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

////  STEP21: Hysteresis Threshold for background cut off 


// Please modify the dir input parameter here, point to channel images folder
////Processing BFP marker channels, cut off background, background and intra tissue environment=0
//save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/";             //Mac, Linux
save_dir="C:/Users/htran/Downloads/TissueJ4Proteins-main/TissueJ4Proteins-main/testing_dataset/testing_macros/";     //Windows
low_thrs=20;
high_thrs=25;
observed_marker_fn="C1-BFP.zip";
remove_background_using_hysteresis_threshold(observed_marker_fn, low_thrs, high_thrs, save_dir,"yes");



////  STEP22: Hysteresis Threshold for background cut off 
// Please modify the dir input parameter here, point to channel images folder
////Processing tSapphire marker channels, cut off background, background and intra tissue environment=0
//save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/";              //Mac, Linux
save_dir="C:/Users/htran/Downloads/TissueJ4Proteins-main/TissueJ4Proteins-main/testing_dataset/testing_macros/";     //Windows
low_thrs=15;
high_thrs=25;
observed_marker_fn="C2-tSapphire.zip";
remove_background_using_hysteresis_threshold(observed_marker_fn, low_thrs, high_thrs, save_dir,"yes");


////  STEP23: Hysteresis Threshold for background cut off 
// Please modify the dir input parameter here, point to channel images folder
//save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/";              //Mac, Linux
save_dir="C:/Users/htran/Downloads/TissueJ4Proteins-main/TissueJ4Proteins-main/testing_dataset/testing_macros/";    //Windows
low_thrs=15;
high_thrs=25;
observed_marker_fn="C3-venus.zip";
remove_background_using_hysteresis_threshold(observed_marker_fn, low_thrs, high_thrs, save_dir,"yes");



////  STEP24: Hysteresis Threshold for background cut off 

//save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/";             //Mac, Linux
save_dir="C:/Users/htran/Downloads/TissueJ4Proteins-main/TissueJ4Proteins-main/testing_dataset/testing_macros/";    //Windows
low_thrs=15;
high_thrs=25;
observed_marker_fn="C4-tomato.zip";
remove_background_using_hysteresis_threshold(observed_marker_fn, low_thrs, high_thrs, save_dir,"yes");


////  STEP25: Hysteresis Threshold for background cut off 

//save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/";             //Mac, Linux
save_dir="C:/Users/htran/Downloads/TissueJ4Proteins-main/TissueJ4Proteins-main/testing_dataset/testing_macros/";    //Windows
low_thrs=5;
high_thrs=10;
observed_marker_fn="C5-katushka.zip";
remove_background_using_hysteresis_threshold(observed_marker_fn, low_thrs, high_thrs, save_dir,"yes");

setBatchMode(false);






//======================================================================================
//// STEP3: Nucleus segmentation
//// In 16 bits images, the intensity values are from 0 to 65536, so above 29000 can consider as signal intensity for maximal local intensity values
//// Similar to in 8 bits, ex: values above 120 from the image intensity range of [0, 255]
//// You can manually enter a threshold here or use automatic estimation. I suggest to use automatic seeds threshold estimation because some nucleus images have very low range of intensity, you can not detect object with high threshold above. 
//// For automatic threshold mode, program will calculate the mean value of image, and define the seeds threshold = mean + sd, I define a sd here is 500
//// You can run automatic mode and observe the results, if as not you expected --> increase or decrease threshold and use manual threshold mode. See the log file to have an idea here. 
//// It take ~ 3 mins for this step
// Please modify the dir input parameter here, point to nucleus image folder

setBatchMode(true);
print("_______________Step 3____________________________");
//// Set parameters
small_nucleus_diameter_thrs=8;
large_nucleus_diameter_thrs=14;
//save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/";              //Mac, Linux
save_dir="C:/Users/htran/Downloads/TissueJ4Proteins-main/TissueJ4Proteins-main/testing_dataset/testing_macros/";    //Windows
nuc_image_fn_zip="C6-NUC.zip";


suffixe_filename=".zip";
image_fn_short = substring(nuc_image_fn_zip,0,lastIndexOf(nuc_image_fn_zip,suffixe_filename));
nuc_image_fn = image_fn_short + ".tif";
open(save_dir+nuc_image_fn_zip);

//// Using automatic seeds selection mode
//run("SEGMENT NUCLEUS", "save_dir=["+save_dir+"] dapi="+nuc_image_fn+" maximal="+large_nucleus_diameter_thrs+" minimal="+small_nucleus_diameter_thrs+" seed=20000 automatic");
//selectWindow("dapi-seg.tif"); //automatic save results into folder
// Automatic Seed Threshold estimated is: 18937 - capture many backgrounds as object, need to increase seed threshold here

// Using manual seed threshold setting mode
run("SEGMENT NUCLEUS", "save_dir=["+save_dir+"] dapi="+nuc_image_fn+" maximal="+large_nucleus_diameter_thrs+" minimal="+small_nucleus_diameter_thrs+" seed=20000");


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

setBatchMode(false);





//======================================================================================
//// STEP4: cell zone estimation, SKIP THIS STEP, ALREADY INCLUDED IN STEP 5
//// Estimating a cell zone for each cell, from each nucleus, extend into space a radius R, ex: R=5 here, then obtained region will be a cell zone. I observe image of dapi and markers to define a max radius for region growing. 
//// Then later, program will look into each cell zone and check the amount of marker that cover this cell zone. 
//// It take ~ 1 mins for this step
// Please modify the dir input parameter here, point to nucleus image folder


setBatchMode(true);
print("_______________Step 4____________________________");

radius_extension_nuc_cellPeriphery = 3; //change this threshold if your cell zone area in the image is smaller, depend on image resolution, in general 3 to 5 is a good one. 
//save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/";               //Mac, Linux
save_dir="C:/Users/htran/Downloads/TissueJ4Proteins-main/TissueJ4Proteins-main/testing_dataset/testing_macros/";    //Windows
seg_nuc_image_fn="C6-NUC_SEG.tif";
image_fn_short = substring(seg_nuc_image_fn,0,lastIndexOf(seg_nuc_image_fn,".tif"));
open(save_dir+image_fn_short+".zip");
run("DETECT CELL ZONE", "save_dir="+save_dir+" nuclei="+seg_nuc_image_fn+" radius_max="+radius_extension_nuc_cellPeriphery+" save");

//// Functions for visualization, and facilitate validation step
selectWindow("dapi-seg-wat.tif");
run("3-3-2 RGB");
saveAs("Tiff", save_dir+image_fn_short+ "_WAT.tif"); //color map for better visualization
File.delete(save_dir+"dapi-seg-wat.tif"); //delete temporary files
print("Complete!!!");
run("Close All"); 

setBatchMode(false);

//======================================================================================
//// STEP5: Extracting cell profiles
// Please modify the dir input parameter here, point to nucleus image and channels images folder

setBatchMode(true);
print("_______________Step 5____________________________");

//// Set parameters here
//save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/";              //Mac, Linux 
save_dir="C:/Users/htran/Downloads/TissueJ4Proteins-main/TissueJ4Proteins-main/testing_dataset/testing_macros/";    //Windows
percent_marker= 0.2; // just keep it here, will remove this parameter in future, in current version, using R script with different threshold of percent coverage.  
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

run("EXTRACT CELL PROFILES", "save_dir="+save_dir+" segmented=C6-NUC_SEG.tif binary=C1-BFP_binary.tif raw=C1-BFP_filtered.tif binary_0=C2-tSapphire_binary.tif raw_0=C2-tSapphire_filtered.tif binary_1=C3-venus_binary.tif raw_1=C3-venus_filtered.tif binary_2=C4-tomato_binary.tif raw_2=C4-tomato_filtered.tif binary_3=C5-katushka_binary.tif raw_3=C5-katushka_filtered.tif percent=0.2 watershed=3 detect");

// Save to zip format, reduce file size
seg_cellZone_image_fn="C6-NUC_SEG_WAT";
open(save_dir+seg_cellZone_image_fn+".tif");
saveAs("ZIP", save_dir+seg_cellZone_image_fn+".zip");
File.delete(save_dir+seg_cellZone_image_fn+".tif"); //delete temporary files, using compressed format

print("Completed!!!");
run("Close All"); 


setBatchMode(false);




