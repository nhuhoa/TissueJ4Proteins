run("TIFF Virtual Stack...", "open=/Users/hoatran/Documents/others/jean_project/data/MultiPDXs_Ms1134/analysis/C6-NUC_SEG.zip");
run("EXTRACT CELL PROFILES LARGE", "save_dir=/Users/hoatran/Documents/others/jean_project/data/MultiPDXs_Ms1134/results/cell_zone_full/ segmented_nuc=C6-NUC_SEG.tif cell_zone=combined_C6-NUC.tif__1___WAT_SEG.tif binary_c1_bfp=C1-BFP_binary.tif raw_c1_bfp=C1-BFP_filtered.tif binary_c2_tsapphire=C2-tSapphire_binary.tif raw_c2_tsapphire=C2-tSapphire_filtered.tif binary_c3_venus=C3-venus_binary.tif raw_c3_venus=C3-venus_filtered.tif binary_c4_tomato=C4-tomato_binary.tif raw_c4_tomato=C4-tomato_filtered.tif binary_c5_katushka=C5-katushka_binary.tif raw_c5_katushka=C5-katushka_filtered.tif percent=0.15");
close();
close();
close();
close();
close();
close();
close();
close();
close();
close();
close();
selectWindow("C1-BFP_binary.tif");
close();
run("Close");
