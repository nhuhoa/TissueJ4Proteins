/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package mcib_testing.PreProcessing;

import fiji.util.gui.GenericDialogPlus;
import ij.IJ;
import ij.ImagePlus;
import ij.WindowManager;
import ij.measure.ResultsTable;
import ij.plugin.PlugIn;
import java.io.File;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import mcib3d.image3d.ImageByte;
import mcib3d.image3d.ImageHandler;
import mcib3d.image3d.ImageInt;
import mcib3d.utils.ArrayUtil;
import java.io.File;
import java.util.ArrayList;
import ij.io.*;
import ij.plugin.FolderOpener;
import ij.process.ImageConverter;
import ij.process.ImageProcessor;
//import ucar.nc2.util.IO;

/**
 *
 * @author tranhoa
 */
public class BlurDetectorEntireFolder_ implements PlugIn
{
    
//    String dir = null, subdir = null;
    public String input_dir="", save_dir = "";
    public int sizeX=0, sizeY=0; 
    public boolean verbose = false, filter_verbose=true;
    public String nbObsNeighbor = "48";
    public void run(String arg) 
    {
        String[] nbNeighbors = {"8","24","48", "80"};
        if (IJ.versionLessThan("1.37f")) return;
        int[] wList = WindowManager.getIDList();

//        if (wList==null) {
//                IJ.showMessage("Calculating pixel distance at neighbourhood", "There must be at least one image open.");
//                return;
//        }
        if (wList!=null) {
            String[] titles = new String[wList.length];
        
            for (int i=0, k=0; i<wList.length; i++) {
                    ImagePlus imp = WindowManager.getImage(wList[i]);
                    if (null !=imp){
                            titles[k++] = imp.getTitle();
    //                        temp = imp;
                    }        
            }
            ImagePlus temp = WindowManager.getImage(wList[wList.length-1]);
            if (null !=temp){
                WindowManager.setTempCurrentImage(temp);
                input_dir = IJ.getDirectory("image");
                if (!(input_dir.endsWith("/") || input_dir.endsWith("\\"))){
                    input_dir = input_dir + "/";
                }
                save_dir = input_dir + "results/";
            }
        }
        
        GenericDialogPlus gd = new GenericDialogPlus("Neighborhood Pixel Distance");
//        GenericDialog gd = new GenericDialog("3D Filtering");
        gd.addMessage("    TissueJ4Proteins  ");
//        gd.addMessage("See and quote reference:\n A novel toolbox to investigate tissue\nspatial" +
//        "organization applied to \nthe study of the islets of Langerhans");
        gd.addMessage("Input : spot image");
        gd.addMessage("Output: pixel distance image");
        gd.addMessage("Output: intensity histogram");
        gd.addMessage(" \n");
        gd.addDirectoryField("Input Dir ", input_dir, 30);
        gd.addDirectoryField("Save Dir ", save_dir, 30);
//        gd.addChoice("Spot Image :", titles, titles[0]);
        gd.addChoice("Number Neighbors ", nbNeighbors, nbNeighbors[2]);
        gd.addCheckbox("Median Filter", filter_verbose);
        gd.addCheckbox("Show Output", verbose);
        
        gd.showDialog();
        if (gd.wasCanceled()) return;
        
        input_dir = gd.getNextString();
        if ("".equals(input_dir)) 
        {
                return;
        }
        
        save_dir = gd.getNextString();
        if ("".equals(save_dir)) 
        {
                return;
        }
        
//        int[] idx = new int[1];
//        int i1Index = gd.getNextChoiceIndex();
        int nbNei = gd.getNextChoiceIndex();
        filter_verbose = gd.getNextBoolean();
        verbose = gd.getNextBoolean();
//        IJ.log("Idx 0: "+idx[0]);
//        IJ.log("Idx 1: "+idx[1]);
//        IJ.log("Idx 2: "+idx[2]);
//        IJ.log("Idx 3: "+idx[3]);
//        IJ.log("Predefined intensity values: NONE = 0, DELTA = 1, BETA = 2, ALPHA = 3, DAPI = 4");
//        ImageHandler img = ImageHandler.wrap(WindowManager.getImage(wList[i1Index]));
//        WindowManager.setTempCurrentImage(imp1);
//        dir = IJ.getDirectory("image");
//        IJ.log("Automatic detecting image folder: ");
//        IJ.log(dir);
        File idir = new File(input_dir);
        if (!idir.exists()) { //!wdir.isDirectory() ||  || !wdir.canRead()
            IJ.error("Directory not found: " + input_dir);
            return;
        }
        if (!(save_dir.endsWith("/")||save_dir.endsWith("\\")))
            save_dir = save_dir + "/";
        File wdir = new File(save_dir);
        if (!wdir.exists()) { //!wdir.isDirectory() ||  || !wdir.canRead()
            wdir.mkdirs();
        }
        nbObsNeighbor = nbNeighbors[nbNei];
        IJ.log("Number of observed neighbors is: " + nbObsNeighbor);
        getFilesFromFolder(input_dir);
//        ArrayList<ImageHandler> input_imgs = getFilesFromFolder(input_dir);
//        if(input_imgs!=null){
//            //        IJ.log("Initializing...");
//        IJ.log("          ");
//        for (int i = 0; i < input_imgs.size(); i++){
//            calculatePixelDistance(input_imgs.get(i), nbNeighbors[nbNei], save_dir);
//        }
//        IJ.log("          ");
//        }
        
        IJ.log("---------------------------------------------------");
        IJ.log("Completed!");
        
//        IJ.selectWindow("Log");
//        IJ.saveAs("Text", save_dir+ "Log_Filtering.txt");
        
    }
    public void getFilesFromFolder(String directory) {
        IJ.log("Working directory: " +  directory);
        String suffix = ".tif";
        File file = new File(directory);
        String[] list = file.list();
        if (list==null) {
            String parent = file.getParent();
            if (parent!=null) {
                file = new File(parent);
                list = file.list();
            }
            if (list!=null)
                directory = parent;
            else {
                IJ.error("Directory not found: "+directory);
                return;
            }
        }
        if (!(directory.endsWith("/")||directory.endsWith("\\")))
            directory += "/";
        
        //remove subdirectories from list
        ArrayList fileList = new ArrayList();
        for (int i=0; i<list.length; i++) {
            File f = (new File(directory+list[i]));
            if (!f.isDirectory())
                fileList.add(list[i]);
        }
        if (fileList.size()<list.length)
            list = (String[])fileList.toArray(new String[fileList.size()]);
        list = trimFileList(list);
//        ArrayList<ImageHandler> input_imgs = new ArrayList<>();
        ImageConverter.setDoScaling(true);
        try {
            for (int i=0; i<list.length; i++) {
                Opener opener = new Opener();
                opener.setSilentMode(true);
                IJ.redirectErrorMessages(true);
                ImagePlus imp = opener.openImage(directory, list[i]);
                IJ.redirectErrorMessages(false);
                if (imp!=null) {
//                    IJ.log(list[i]);
                    IJ.run(imp, "Enhance Contrast", "saturated=0.35");
                    IJ.run(imp, "8-bit", "");
                    if(filter_verbose){
                        IJ.run(imp, "Median...", "radius=2");
                    }
//                    
//                    imp.show();
//                    ImageProcessor ip = imp.getProcessor();
//                    ip.convertToByte(true);
//                    ip.setMinAndMax(0, 255);
//                    ip.medianFilter();
//                    imp = new ImagePlus(imp.getTitle(), ip);
//                    IJ.log("Image Type: "+imp.getBitDepth());
                    ImageHandler img = ImageHandler.wrap(imp);
                    calculatePixelDistance(img, nbObsNeighbor, save_dir);
//                    input_imgs.add(img);
//                    imp.close();
//                    img.show();
                   
                }
            }  
        }catch(OutOfMemoryError e) {
            IJ.outOfMemory("FolderOpener");
        }    

        
//        return(input_imgs);
    }
    private void calculatePixelDistance(ImageHandler img, String nbNei, String save_dir)
    {
//        IJ.log("Bit depth: "+img.getImagePlus().getBitDepth());
        String image_fn = img.getTitle();
//        IJ.log("Input image: "+ image_fn);
        IJ.log(" "+ image_fn + " ");
        Pattern p = Pattern.compile(".tif");
        Matcher m = p.matcher(image_fn); 
        image_fn = m.replaceAll("");
        sizeX = img.sizeX;
        sizeY = img.sizeY;
//        IJ.log("Nb neighbours for each pixel: "+ nbNei);
        int rad;
        if(null == nbNei){
            rad=3;
        }else switch (nbNei) {
            case "8":
                rad=1;
                break;
            case "24":
                rad=2;
                break;
            case "48":
                rad=3;
                break;
            case "80":
                rad=4;
                break;   
            default:
                rad=3;
                break;
        }
        
//        IJ.log("Radius from a pixel: "+ rad);
        String dist_image_fn = image_fn+"_dist";
        ImageInt draw = new ImageByte(dist_image_fn, sizeX, sizeY, 1);
        for (int x = 0; x < img.sizeX; x++) {
            for (int y = 0; y < img.sizeY; y++) {
//                IJ.log(x+" "+y+"  "+getAvgGivenPixelDistance(img, x, y, rad));
                draw.setPixel(x, y, 0, getAvgGivenPixelDistance(img, x, y, rad));
            }
        } 
        if(verbose){
            draw.show();
        }
        getHistoStatistic(draw, image_fn, save_dir);
        
        
//        draw.save(save_dir, true);
//        IJ.selectWindow(dist_image_fn);
//        IJ.saveAs("Tiff", save_dir + dist_image_fn+".tif");
    } 
    private void getHistoStatistic(ImageInt draw, String image_fn, String save_dir){
        int maxObsIntensity = 40;
        int[] histo = draw.getHistogram();
        ResultsTable res = new ResultsTable();
        for(int idx = 0; idx <= maxObsIntensity; idx++){
            res.incrementCounter();
            res.setValue("intensity_val", idx, idx);
            res.setValue("counts", idx, histo[idx]);
        }
        
        int count = 0;
        for(int idx = (maxObsIntensity+1); idx <= 255; idx++){
            count += histo[idx];
        }
        
        res.incrementCounter();
        res.setValue("intensity_val", maxObsIntensity+1, "greater_"+maxObsIntensity);
        res.setValue("counts", maxObsIntensity+1, count);
        
        if(verbose){
            res.show("histo_distance");
        }
        try {
            String out_fn = save_dir+image_fn+"_histogram.csv";
            res.saveAs(out_fn);
//            IJ.log(out_fn);
        } catch (IOException ex) {
            IJ.log("Have the problem of save histogram output");
        }
        
    }
    private int getAvgGivenPixelDistance(ImageHandler img, int x, int y, int rad){
        
        double[] pix = new double[(2 * rad + 1) * (2 * rad + 1)];
        int index = 0;
        int obs_px = (int)img.getPixel(x, y, 0);
        for (int j = y - rad; j <= y + rad; j++) {
            for (int i = x - rad; i <= x + rad; i++) {
                if (i >= 0 && j >= 0 && i < sizeX && j < sizeY && i!= x && j!= y) {
                    pix[index] =  Math.abs(obs_px - img.getPixel(i, j, 0));
                    index++;
                }
            }
        }
        
        if (index > 0) {
            ArrayUtil t = new ArrayUtil(pix);
            t.setSize(index);
            return (int)t.getMean();
        } else {
            return 0;
        }
    }  
    /** Removes names that start with "." or end with ".db", ".txt", ".lut", "roi", ".pty", ".hdr", ".py", etc. */
    public String[] trimFileList(String[] rawlist) {
        if (rawlist==null)
            return null;
        int count = 0;
        for (int i=0; i< rawlist.length; i++) {
            String name = rawlist[i];
            if (name.startsWith(".")||name.equals("Thumbs.db")||excludedFileType(name))
                rawlist[i] = null;
            else
                count++;
        }
        if (count==0) return null;
        String[] list = rawlist;
        if (count<rawlist.length) {
            list = new String[count];
            int index = 0;
            for (int i=0; i< rawlist.length; i++) {
                if (rawlist[i]!=null)
                    list[index++] = rawlist[i];
            }
        }
        return list;
    }
    /* Returns true if 'name' ends with ".txt", ".lut", ".roi", ".pty", ".hdr", ".java", ".ijm", ".py", ".js" or ".bsh. */
    public static boolean excludedFileType(String name) {
        String[] excludedTypes = {".txt",".lut",".roi",".pty",".hdr",".java",".ijm",".py",".js",".bsh",".xml",".rar",".h5",".doc",".xls"};
        if (name==null) return true;
        for (int i=0; i<excludedTypes.length; i++) {
            if (name.endsWith(excludedTypes[i]))
                return true;
        }
        return false;
    }
}
