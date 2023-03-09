//======================================================================================
//// STEP3: Nucleus segmentation
//// In 16 bits images, the intensity values are from 0 to 65536, so above 29000 can consider as signal intensity for maximal local intensity values
//// Similar to in 8 bits, ex: values above 120 from the image intensity range of [0, 255]
//// You can manually enter a threshold here or use automatic estimation. I suggest to use automatic seeds threshold estimation because some nucleus images have very low range of intensity, you can not detect object with high threshold above. 
//// For automatic threshold mode, program will calculate the mean value of image, and define the seeds threshold = mean + sd, I define a sd here is 500
//// You can run automatic mode and observe the results, if as not you expected --> increase or decrease threshold and use manual threshold mode. See the log file to have an idea here. 
//// It take ~ 3 mins for this step


setBatchMode(true);
print("___________________________________________");


small_nucleus_diameter_thrs=19;
large_nucleus_diameter_thrs=34;
//save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/"; 
save_dir="/Users/hoatran/Documents/jean_project/data/MultiPDXs_Ms1134/NUC_SEG/";
nuc_image_fn_zip="C6-NUC-crop2.zip";


suffixe_filename=substring(nuc_image_fn_zip,lastIndexOf(nuc_image_fn_zip,"."), lengthOf(nuc_image_fn_zip));
image_fn_short = substring(nuc_image_fn_zip,0,lastIndexOf(nuc_image_fn_zip,suffixe_filename));
nuc_image_fn = image_fn_short + ".tif";
open(save_dir+nuc_image_fn_zip);

//// Using automatic seeds selection mode
run("SEGMENTING NUCLEUS", "save_dir=["+save_dir+"] dapi="+nuc_image_fn+" maximal="+large_nucleus_diameter_thrs+" minimal="+small_nucleus_diameter_thrs+" seed=20000 automatic");
//selectWindow("dapi-seg.tif"); //automatic save results into folder
// Automatic Seed Threshold estimated is: 18937 - capture many backgrounds as object, need to increase seed threshold here

// Using manual seed threshold setting mode
//run("SEGMENTING NUCLEUS", "save_dir=["+save_dir+"] dapi="+nuc_image_fn+" maximal="+large_nucleus_diameter_thrs+" minimal="+small_nucleus_diameter_thrs+" seed=20000");


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
