#!/bin/sh

# imagej_dir="/home/htran/storage/install_software/ImageJ"
imagej_dir="/Applications/ImageJ.app"
macro_dir="/Users/hoatran/Documents/images_HE/HE_immuno_image_analysis/macro_large_tissue"
macro_fn="$macro_dir/color_deconv/rescale_image.txt"
#macro_fn="$macro_dir/slidej/run_imagej_slideJ.txt"
#input_dir="/Users/hoatran/Documents/images_HE/images/3_08/"
# input_dir="/home/htran/backup/home/htran/storage/images_dataset/large_tissue/3_08/"

#log_dir="/home/htran/storage/images_dataset/large_tissue/macro"
#log_file="$macro_dir/slidej/slidej_3_08.log"
# exec >> $log_file 2>&1 && tail $log_file

#echo "Crop big image into many blocks"
# xvfb-run -a java -Xmx20000m -jar $imagej_dir/ij.jar -ijpath $imagej_dir/ -batch $macro_fn $input_dir 
#java -Xmx20000m -jar $imagej_dir/Contents/Java/ij.jar -ijpath $imagej_dir/ -batch $macro_fn $input_dir 
#echo "Completed"


echo "Rescale images"
input_dir3="/Users/hoatran/Documents/images_HE/images/3_08/"
java -Xmx20000m -jar $imagej_dir/Contents/Java/ij.jar -ijpath $imagej_dir/ -batch $macro_fn $input_dir3 
echo "Completed"

echo "Rescale images"
input_dir4="/Users/hoatran/Documents/images_HE/images/4_S01/"
java -Xmx20000m -jar $imagej_dir/Contents/Java/ij.jar -ijpath $imagej_dir/ -batch $macro_fn $input_dir4
echo "Completed"

echo "Rescale images"
input_dir5="/Users/hoatran/Documents/images_HE/images/5_06/"
java -Xmx20000m -jar $imagej_dir/Contents/Java/ij.jar -ijpath $imagej_dir/ -batch $macro_fn $input_dir5
echo "Completed"

#echo "Rescale images"
#input_dir6="/Users/hoatran/Documents/images_HE/images/6_10AS/"
#java -Xmx20000m -jar $imagej_dir/Contents/Java/ij.jar -ijpath $imagej_dir/ -batch $macro_fn $input_dir6
#echo "Completed"