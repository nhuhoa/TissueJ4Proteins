minSize=8; // minimum diameter
maxSize=14; // maximum diameter
name="C6-NUC.tif";
suffixe=".tif";
short_name = substring(name,0,lastIndexOf(name,suffixe));
seed_image="seed_img";
save_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/testing_dataset/testing_manual_SEG/"; 
 selectWindow(name);
					  run("Grays");
						run("Median...", "radius=2");
					  selectWindow(name);
					  run("Duplicate...", "title=["+ short_name +"_raw]");
 selectWindow(name);
						run("32-bit");
			      run("Bandpass Filter...", "filter_large="+maxSize+" filter_small="+minSize+" suppress=None tolerance=5");
						//run("Enhance Contrast...", "saturated=0");
						run("16-bit");

selectWindow(name);

run("Median...", "radius=2");
run("3D Spot Segmentation", "seeds_threshold=1 local_background=0 local_diff=0 radius_0=2 radius_1=4 radius_2=6 weigth=0.50 radius_max=20 sd_value=1.90 local_threshold=[Gaussian fit] seg_spot=Block watershed volume_min=5 volume_max=1000000 seeds=seed_img spots=C6-NUC radius_for_seeds=2 output=[Label Image]");
run("Enhance Contrast", "saturated=0.35");

						print("Segmenting...");
						//getStatistics(area, mean, min, max, std);
						//print(getTitle+"  mean value: "+mean);
						//sd=500;
						//spot_seeds_threshold=floor(mean)+sd;  // if you obtain too many objects, you can increase the sd value here. And in contrast, if you obtain small number of objects than you expected, you can decrease the sd value here
						spot_seeds_threshold=1;
						print("_________________________________________");
						print("ATTENTION: seeds threshold value is:  "+spot_seeds_threshold);
						// usually seeds_threshold=30000 for 16 bits image
						run("3D Spot Segmentation", "seeds_threshold="+spot_seeds_threshold+" local_background=0 radius_0=2 radius_1=4 radius_2=6 weigth=0.50 radius_max=20 sd_value=1.90 local_threshold=[Gaussian fit] seg_spot=Block watershed volume_min=15 volume_max=1000000 seeds="+seed_image+" spots="+short_name+" radius_for_seeds=2 output=[Label Image]"); 

						selectWindow("seg");
						run("3-3-2 RGB");
					 	saveAs("Tiff",save_dir+short_name+"_SEG.tif");	
					 	
						run("3D Draw Rois", "raw="+short_name+"_raw seg="+short_name+"_SEG");
						saveAs("Tiff", save_dir+short_name+"_SEG_demo_only.tif");






run("Median...", "radius=2");
run("3D Spot Segmentation", "seeds_threshold=1 local_background=0 local_diff=0 radius_0=2 radius_1=4 radius_2=6 weigth=0.50 radius_max=100 sd_value=1.90 local_threshold=[Gaussian fit] seg_spot=Block watershed volume_min=2 volume_max=1000000 seeds=seed_img spots=C6-NUC radius_for_seeds=2 output=[Label Image]");
run("Enhance Contrast", "saturated=0.35");

run("3D Watershed Split", "binary=C6-NUC-BINARY seeds=seed_img radius=2");
run("3-3-2 RGB");


