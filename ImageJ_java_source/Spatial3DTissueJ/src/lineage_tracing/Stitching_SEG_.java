/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package lineage_tracing;

import fiji.util.gui.GenericDialogPlus;
import ij.IJ;
import ij.ImageJ;
import ij.ImagePlus;
import ij.plugin.PlugIn;
import java.io.File;
import java.util.ArrayList;
import mcib3d.geom.Object3D;
import mcib3d.geom.Objects3DPopulation;
import mcib3d.image3d.ImageFloat;
import mcib3d.image3d.ImageHandler;
import mcib3d.image3d.ImageInt;
import mcib3d.image3d.ImageShort;
//import java.util.*;
/**
 *
 * @author miu
 */
public class Stitching_SEG_ implements PlugIn{
    private GenericDialogPlus gd;
    
public void run(String arg) {
	
        /* The interface of the plugin is a modal dialog that resembles the one implemented in ImageJ
           for batch macro execution. */
        gd = new GenericDialogPlus("SlideJ");
        gd.addDirectoryField( "input", "");
        gd.addDirectoryField( "output", "");
        gd.showDialog();

        String inputPath = gd.getNextString();
        String outputPath = gd.getNextString();
        
        if (gd.wasCanceled()) {
            return;
        }
        if (inputPath.equals("")) {
            error("Please choose an input folder");
            return;
        }
        inputPath = addSeparator(inputPath);
        IJ.log(inputPath);
        File f1 = new File(inputPath);
        //File f1 = new File("/Users/miu/Documents/test_stitching/");
        
        if (!f1.exists() || !f1.isDirectory()) {
            error("Input does not exist or is not a folder\n \n"+inputPath);
            return;
        }
        if (outputPath.equals("")) {
            error("Please choose an output folder");
            return;
        }
        outputPath = addSeparator(outputPath);
        IJ.log(outputPath);
        File f2 = new File(outputPath);
//        File f2 = new File("/Users/miu/Documents/out_stitching/");
        if (!f2.exists() || !f2.isDirectory()) {
            error("Output does not exist or is not a folder\n \n"+outputPath);
            return;
        }
        
        File[] list1=f1.listFiles();
        
        for(File path:list1) {
         
            // prints file and directory paths
            IJ.log(path.getName());
         }
        int MAX=list1.length;
        
//        Objects3DPopulation popSeg = new Objects3DPopulation();
        int count = 0; 
        int max_intensity=0;
        int previousX=0, previousY=0;
        int imgSX = 7371, imgSY=18036;
        String[] list_fn = {"01_SEG.tif","02_SEG.tif","03_SEG.tif","04_SEG.tif"};
        MAX = 4;
        String output_fn = "whole_tissue";
        ImageHandler imgwhole = new ImageFloat(output_fn, imgSX, imgSY, 1);
        for (int i = 0; i<MAX; i++){
//            String inputName =list1[i].getName();
            String inputName = list_fn[i];
            if(inputName.endsWith("_SEG.tif")){
                String imgPath = inputPath + inputName;
                IJ.log(imgPath);
                ImagePlus segPlus = IJ.openImage(imgPath);
//                ImagePlus segPlus = new ImagePlus(imgPath);
                ImageHandler img = ImageHandler.wrap(segPlus);
                img.setTitle(inputName);
                previousX = img.sizeX;
                
                
                Objects3DPopulation popObjs = new Objects3DPopulation(img);
                
                count = count + 1; 
                int z = 0;
                if(count==1){
//                    popSeg.addObjects(popObjs.getObjectsList());
                    max_intensity = popObjs.getNbObjects();
                    previousY = img.sizeY;
                    
                    for (int y = 0; y < img.sizeY; y++) {
                        for (int x = 0; x < img.sizeX; x++) {
                            float val = img.getPixel(x, y, z);
                            if (val > 0) {
                                imgwhole.setPixel(x, y, z, val);
                            }
                        }
                    }
                    
                }else{
//                    ArrayList<Object3D> ls = new ArrayList<Object3D>();
//                    for (Object3D cell : popObjs.getObjectsList()) 
//                    {
//                        cell.setValue(cell.getValue()+max_intensity);
//                        cell.setNewCenter(cell.getCenterX(),cell.getCenterY()+previousY, cell.getCenterZ());
//                        ls.add(cell);
//                    }
//                    popSeg.addObjects(ls);
                    for (int y = 0; y < img.sizeY; y++) {
                        for (int x = 0; x < img.sizeX; x++) {
                            float val = img.getPixel(x, y, z);
                            if (val > 0) {
                                imgwhole.setPixel(x, y+previousY, z, val+max_intensity);
                            }
                        }
                    }
                    max_intensity = max_intensity + popObjs.getNbObjects();
                    previousY = previousY + img.sizeY;
                }
                
                
//                IJ.log("Nb added objs: "+popSeg.getNbObjects());
                IJ.log("max_intensity_img: "+max_intensity);
            }
        }
        
//        ImageHandler imgwhole = new ImageShort(output_fn,imgSX, imgSY, 1);
//        ImageHandler imgwhole = new ImageFloat(output_fn, imgSX, imgSY, 1);
//        popSeg.draw(imgwhole);
        imgwhole.show();
        IJ.selectWindow(output_fn);
        IJ.saveAs("Tiff", outputPath + output_fn + ".tif");
        
        
        
}  
String addSeparator(String path) {
        if (path.equals("")) return path;
        if (!(path.endsWith("/")||path.endsWith("\\")))
                path = path + File.separator;
        return path;
}
void error(String msg) {
	IJ.error("Error:", msg);
}
public void run() {
        
    }	
    
}
