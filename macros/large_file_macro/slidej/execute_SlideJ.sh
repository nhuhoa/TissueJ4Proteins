#!/bin/sh

## Parameter setting, depending on OS system, choosing one of the following config directory: 

## ImageJ/ Fiji can be installed to Applications, or put into any folder in your drive. 
# imagej_dir="/Applications/ImageJ.app" ## MacOS ImageJ java run folder
# imagej_dir="/Applications/Fiji.app" ## MacOS Fiji java run folder
# imagej_dir="/Users/htran/Downloads/Fiji.app/" ## MacOS Fiji java run folder - from my computer
# imagej_dir = "/Users/miu/Downloads/ImageJ.app" ## MacOS ImageJ java run folder
imagej_dir="/Applications/ImageJ.app/" ## MacOS ImageJ java run folder
imagej_exe_file=${imagej_dir}Contents/Java/ij.jar ## ImageJ exe file location, in general file name is ij.jar, sometimes include version here
macro_dir="/Users/hoatran/Documents/python_workspace/TissueJ4Proteins/macros/large_file_macro/"
input_dir = "/Users/hoatran/Documents/others/jean_project/data/MultiPDXs_Ms1134/NUC_raw/"




macro_fn = "${macro_dir}slidej/run_imagej_slideJ.txt"

## You can change memory amount, ex: 20000m to 30000m so program will run faster. For large file, I used 60000M memory from my Mac
## MacOS background mode here

## If you have java environment jre installed in your computer
# java -Xmx60000m -jar ${imagej_exe_file} -ijpath $imagej_dir/ -batch $macro_fn $input_dir

## Otherwise using existing jre env from Fiji here
# /Users/htran/Downloads/Fiji.app/java/macosx/adoptopenjdk-8.jdk/jre/Contents/Home/bin/java -Xmx20000m -jar ${imagej_dir}Contents/Java/ij.jar -ijpath ${imagej_dir} -batch $macro_fn $input_dir
# ${imagej_dir}java/macosx/adoptopenjdk-8.jdk/jre/Contents/Home/bin/java -Xmx20000m -jar ${imagej_exe_file} -ijpath ${imagej_dir} -batch $macro_fn ${input_dir}

${imagej_dir}jre/bin/java -Xmx60000m -jar $imagej_exe_file -ijpath $imagej_dir -batch $macro_fn $input_dir

## Linux background mode here, using xvfb-run in case you run in server (xvfb for graphical env), in local computer, java command is enough
# xvfb-run -a java -Xmx60000m -jar $imagej_dir/ij.jar -ijpath $imagej_dir/ -batch $macro_fn $input_dir 
# xvfb-run -a java -Xmx60000m -jar $imagej_exe_file -ijpath $imagej_dir -batch $macro_fn $input_dir 

## In Linux local computer, java command is sufficient
# java -Xmx15000m -jar $imagej_dir/ij.jar -ijpath $imagej_dir/ -batch $macro_fn $input_dir 
