//======================================================================================
////  STEP2: Hysteresis Threshold for background cut off 
//// I know the way we define the threshold is a bit manual here 
//// but if you have same microscopy setting, you may need to define it once 
//// and reuse the set of parameters many times


//======================================================================================
////  STEP2: Hysteresis Threshold for background cut off 

function remove_background_using_hysteresis_threshold(image_fn, low_thrs, high_thrs, save_dir, normalize_img) {
open(save_dir + image_fn);  
image_fn_short = substring(image_fn,0,lastIndexOf(image_fn,".tif"));
print("Removing background using hysteresis threshold method from image: "+image_fn)
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
saveAs("Tiff", save_dir+image_fn_short+"_binary.tif");

selectWindow("Result of "+image_fn);
saveAs("Tiff", save_dir+image_fn_short+"_filtered.tif");
if( normalize_img=="yes"){
print("Normalizing filtered image");
run("NORMALIZING IMAGE", "save_dir="+save_dir+" input_image="+image_fn_short+"_filtered.tif threshold=5");
selectWindow("normalized_"+image_fn_short+"_filtered.tif");
saveAs("Tiff", save_dir+image_fn_short+"_filtered.tif");
File.delete(save_dir+"normalized_"+image_fn_short+"_filtered.tif")


} else{
	print("Without normalizing step");
	
}

//======================================================================================
////  STEP22: Hysteresis Threshold for background cut off 

////Processing tSapphire marker channels, cut off background, background and intra tissue environment=0
save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_macros/"; 
low_thrs=15;
high_thrs=25;
observed_marker_fn="C2-tSapphire.tif";
remove_background_using_hysteresis_threshold(observed_marker_fn, low_thrs, high_thrs, save_dir,"yes");

	
//selectWindow(image_fn);
//saveAs("Tiff", save_dir+image_fn);
run("Close All"); 
print("Completed!");


}

