

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
//dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/small_tissue/";
dir="/Users/hoatran/Documents/jean_project/data/MultiPDXs_Ms1134/";
save_dir=File.getParent(dir)+"/analysis/";
if(!File.exists(save_dir)) 
      File.mkdir(save_dir);

composite_image_fn="MultiPDXs_Ms1134_Tum_ROI800_quickscan20x_Stitch.czi";
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


setBatchMode(false);
