/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package mcib_testing.CellType;

import fiji.util.gui.GenericDialogPlus;
import ij.IJ;
import ij.ImagePlus;
import ij.WindowManager;
import ij.measure.ResultsTable;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
//import java.util.Arrays;
import java.util.HashMap;
//import java.util.Iterator;
import mcib3d.geom.Object3D;
//import mcib3d.geom.Object3DVoxels;
import mcib3d.geom.Objects3DPopulation;
//import mcib3d.image3d.ImageByte;
//import mcib3d.image3d.ImageFloat;
//import mcib3d.image3d.ImageHandler;
import mcib3d.image3d.ImageInt;
//import mcib3d.image3d.distanceMap3d.EDT;
//import mcib3d.image3d.regionGrowing.Watershed3DVoronoi;
import mcib3d.utils.ArrayUtil;
import mcib_testing.Utils.Cell;
//import DecimalFormat;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import mcib3d.geom.Object3DPoint;
import mcib3d.image3d.ImageFloat;


/**
 *
 * @author HoaTran
 */

public class DetectCellType_protein_large_image_v2 implements ij.plugin.PlugIn {
    private final int UNLABELED = 1;
    private final int MARKER = 255;
    int MARKER_VAL = 2;
    double wat_radius = 3;
//    private Objects3DPopulation popRegions = null;
    HashMap<Integer, Cell> region2Cell = null;
    Objects3DPopulation popRegions = null;
    HashMap<Integer, Cell> nucleus2Cell=null;
    Objects3DPopulation popNuclei = null;
    ArrayList<Cell> popCells = null;
    String dir = null;
    private double ratioMarker = 0.2;
//    private float min = 0, maxInside = 4, maxOutside = 2;
//    private final int IN_OUTSIDE = 0, OUTSIDE_NUCLEUS = 1, INSIDE_NUCLEUS = 2, WATERSHED_REGION = 3;
    public boolean showUnlabelled = true;
    private static String none = "*None*";
    
    String save_dir = "";
    public boolean cell_zone_detection = true;
    String[] markerTypes = {"C1-BFP", "C2-tSapphire","C3-venus", "C4-tomato","C5-katushka"};
    public void run(String arg) 
    {
//        String[] regionObs = {"INSIDE_OUTSIDE NUCLEUS", "OUTSIDE NUCLEUS", "INSIDE NUCLEUS","WATERSHED REGION"};
          // 2, 3, 4, 5 pixel val
//        String[] markerObs = {"MYC", "Ki67"};
//        int marker_type = 0;
        
        int[] wList = WindowManager.getIDList();
//        if (wList==null) {
//            IJ.error("No images are open.");
//            return;
//        }
        if(wList==null || wList.length<2)
        {
            IJ.error("At least segmented nuclei, and label image, label binary should be open.");
            return;
        }  
        
        String[] titles = null;
        titles = new String[wList.length+1];
        for (int i=0; i<wList.length; i++) {
            ImagePlus imp = WindowManager.getImage(wList[i]);
            titles[i] = imp!=null?imp.getTitle():"";
        }
        titles[wList.length] = none;
        
        ImagePlus temp = WindowManager.getImage(wList[wList.length-1]);
        if (null !=temp){
            WindowManager.setTempCurrentImage(temp);
            save_dir = IJ.getDirectory("image");
        }
//        if(wList.length==2){
//            titles = new String[wList.length+1];
//            for (int i=0; i<wList.length; i++) {
//                ImagePlus imp = WindowManager.getImage(wList[i]);
//                titles[i] = imp!=null?imp.getTitle():"";
//            }
//            titles[wList.length] = none;
//        }else{
//            titles = new String[wList.length];
//            for (int i=0; i<wList.length; i++) {
//                ImagePlus imp = WindowManager.getImage(wList[i]);
//                titles[i] = imp!=null?imp.getTitle():"";
//            }
//            titles[wList.length] = none;
//        }
        
//        boolean save = true; 
        GenericDialogPlus gd = new GenericDialogPlus("EXTRACT CELL PROFILES");
        gd.addMessage("TissueJ4Proteins  ");
        gd.addMessage("Input : nuc segmented image");
        gd.addMessage("Input : cell zone segmented image");
        gd.addMessage("Input : binary objects-background image");
        gd.addMessage("Input : raw or pre-filtered image");
        gd.addMessage("Output: csv output of cell profiles");

        gd.addMessage(" ");
//        gd.addStringField("Save Dir: ", save_dir);
        gd.addDirectoryField("Save_Dir: ", save_dir, 30);
        gd.addChoice("SEGMENTED_NUC:  ", titles, titles[0]);
        gd.addChoice("CELL_ZONE:  ", titles, titles[0]);
        gd.addMessage(" ");
//        gd.addChoice("Watershed: ", titles, titles[1]);
        gd.addChoice("BINARY_C1_BFP: ", titles, titles[0]);
        gd.addChoice("RAW_C1_BFP: ", titles, titles[0]);
        gd.addMessage(" ");
        gd.addChoice("BINARY_C2_tSapphire: ", titles, titles[0]);
        gd.addChoice("RAW_C2_tSapphire: ", titles, titles[0]);
        gd.addMessage(" ");
        gd.addChoice("BINARY_C3_Venus: ", titles, titles[0]);
        gd.addChoice("RAW_C3_Venus: ", titles, titles[0]);
        gd.addMessage(" ");
        gd.addChoice("BINARY_C4_Tomato: ", titles, titles[0]);
        gd.addChoice("RAW_C4_Tomato: ", titles, titles[0]);
        gd.addMessage(" ");
        gd.addChoice("BINARY_C5_Katushka: ", titles, titles[0]);
        gd.addChoice("RAW_C5_Katushka: ", titles, titles[0]);
        gd.addMessage(" ");
        
//        gd.addChoice("Region Observed : ", regionObs, regionObs[reg]);
//        gd.addChoice("Marker Observed : ", markerObs, markerObs[marker_type]);
        gd.addNumericField("Percent Marker : ", (double)ratioMarker, 1);
//        gd.addNumericField("Watershed Cell Radius : ", wat_radius, 0);
//        gd.addCheckbox("Detect Cell Zone", cell_zone_detection);
//        gd.addNumericField("Max_Distance_Inside : ", maxInside, 1);
//        gd.addNumericField("Max_Distance_Outside : ", maxOutside, 3);
//        gd.addCheckbox("Save the output into folder", true);
//        gd.addCheckbox("Show unlabelled nucleus", true);
        gd.showDialog();
        if (gd.wasCanceled())
            return;
        
        save_dir = gd.getNextString();
        
        if ("".equals(save_dir)) 
        {
                return;
        }

        File wdir = new File(save_dir);
        
        if (!wdir.exists()) { //!wdir.isDirectory() ||  || !wdir.canRead()
            wdir.mkdirs();
            IJ.log("Creating a directory: "+save_dir);
//                IJ.showMessage("Working directory error");
//                return;
        }

        int[] index = new int[12];
        index[0] = gd.getNextChoiceIndex();
        index[1] = gd.getNextChoiceIndex();
        index[2] = gd.getNextChoiceIndex();
        index[3] = gd.getNextChoiceIndex();
        index[4] = gd.getNextChoiceIndex();
        index[5] = gd.getNextChoiceIndex();
        index[6] = gd.getNextChoiceIndex();
        index[7] = gd.getNextChoiceIndex();
        index[8] = gd.getNextChoiceIndex();
        index[9] = gd.getNextChoiceIndex();
        index[10] = gd.getNextChoiceIndex();
        index[11] = gd.getNextChoiceIndex();
//        for(int i=0; i<=10; i++){
//            IJ.log("Idx: "+i+" :"+index[0]+"  img: "+wList[index[0]]);
//        }
//        marker_type =  (int)(gd.getNextChoiceIndex());
        ratioMarker = (double) gd.getNextNumber();
//        wat_radius = (double) gd.getNextNumber();
//        cell_zone_detection = gd.getNextBoolean();
//        min = (float) gd.getNextNumber();
//        maxInside = (float) gd.getNextNumber();
//        maxOutside = (float) gd.getNextNumber();
//        save  = gd.getNextBoolean();
//        showUnlabelled  = gd.getNextBoolean();
        IJ.log("Ratio marker to assign a cell type: "+ratioMarker);
        
//        IJ.log("Detecting cell type: "+markerObs[marker_type]);
        
//        ImageInt imgSeg = ImageInt.wrap(WindowManager.getImage(wList[index[0]]));
//        IJ.log("Segmented image: " + imgSeg.getTitle());
        
        ImageFloat imgSeg = (ImageFloat)ImageFloat.wrap(WindowManager.getImage(wList[index[0]]));
        IJ.log("Segmented image: " + imgSeg.getTitle());
        ImageFloat imgWat = (ImageFloat)ImageFloat.wrap(WindowManager.getImage(wList[index[1]]));
        IJ.log("Cell zone image: " + imgWat.getTitle());
        
//        ImageInt imgWat = null;
//        if(none.equals(wList[index[1]])){ //(wList.length==2) || 
//            IJ.log("Dont exist wat img. compute it later");
//        }else{
//            imgWat = ImageInt.wrap(WindowManager.getImage(wList[index[1]]));
//            IJ.log("Wat: " + imgWat.getTitle());
//        }
        
        
        
        
        ArrayList<ImageInt> lsbin = new ArrayList<ImageInt>();
        ArrayList<ImageInt> lsraw = new ArrayList<ImageInt>();
        int count=0;
        
        for(int i=2; i<=10; i=i+2){
            ImageInt imgLabel = ImageInt.wrap(WindowManager.getImage(wList[index[i]]));
            ImageInt imgRawLabel = ImageInt.wrap(WindowManager.getImage(wList[index[i+1]]));
//            imgLabel.setTitle("BIN_"+markerTypes[count]);
            lsbin.add(imgLabel);
            lsraw.add(imgRawLabel);
        }   
        
        IJ.log("Nb images bin is: " + lsbin.size());
        IJ.log("Nb images raw is: " + lsraw.size());
        if (lsbin.size()!=lsraw.size()) 
        {
                return;
        }
        
//        ImageFloat imgWat = imgSeg;
        analysis_v2(imgSeg, imgWat, lsbin, lsraw, save_dir);
      
        IJ.log("Completed!!!");
        
        
        
    }
    public void analysis_v2(ImageFloat imgSeg, ImageFloat imgWat, 
                            ArrayList<ImageInt> lsbin, ArrayList<ImageInt> lsraw, String save_dir){
        double background_threshold = 0;
        
//        ImageInt imgLabel;
//        HashMap<Integer, Cell> region2Cell=null;
        
        String image_fn = imgSeg.getTitle();
        Pattern p = Pattern.compile("_SEG");
        Matcher m = p.matcher(image_fn); 
        image_fn = m.replaceAll("");
        IJ.log(image_fn);
        
        
 
        initCells(imgSeg, imgWat); //, image_fn, save_dir
        computeCellType_large_data(lsbin, lsraw, save_dir, image_fn);
    }   
    private void computeCellType_large_data(ArrayList<ImageInt> lsbin, ArrayList<ImageInt> lsraw, 
                                            String save_dir, String image_fn) 
    {
        
        IJ.log("Computing cell type...");
        ResultsTable nodes = new ResultsTable();
//        ResultsTable edges = new ResultsTable();
        
        
        for(int m=0; m<=4; m++){
                IJ.log(markerTypes[m]);
        }  
        int nb_cells = popCells.size();
        IJ.log("Nb cells is: "+ nb_cells);
        
        IJ.log("Computing cell profiles...");
        int c = 0;
//        DecimalFormat df = new DecimalFormat("#.##");
        for (Cell C : popCells) {
//            if(C.region==null) continue;
            nodes.incrementCounter();
//            IJ.log("NUC: " + C.nucleus.getValue());
            nodes.setValue("cell_id", c, C.nucleus.getValue()); //index
            nodes.setValue("cell_zone_id", c, C.region.getValue()); 
            nodes.setValue("x", c, Math.round(C.nucleus.getCenterX()));
            nodes.setValue("y", c, Math.round(C.nucleus.getCenterY()));
            nodes.setValue("NucPixVol", c, Math.round(C.nucleus.getVolumePixels()));
            nodes.setValue("CellPixVol", c, Math.round(C.region.getVolumePixels()));
 
            for(int m=0; m<=4; m++){
                ArrayUtil non_zero_pxs_nuc = C.nucleus.listValues(lsbin.get(m));
                ArrayUtil non_zero_pxs_cellzone = C.region.listValues(lsbin.get(m));    
                int nbM = non_zero_pxs_nuc.countValueAbove(0);
                int nbCZ = non_zero_pxs_cellzone.countValueAbove(0);
//                double vol = C.nucleus.getVolumePixels();
//                double coverage = nbM /vol;
//                nodes.setValue(markerTypes[m]+"_mean_intensity_cellzone", c, Math.round(C.region.getPixMeanValue(lsraw.get(m))));
//                nodes.setValue(markerTypes[m]+"_median_intensity_cellzone", c, Math.round(C.region.getPixMedianValue(lsraw.get(m))));
//                nodes.setValue(markerTypes[m]+"_pct_coverage_cellzone", c, Math.round(100*nbM /C.region.getVolumePixels()));
                nodes.setValue(markerTypes[m]+"_pct_coverage_cellzone", c, Math.round(100*nbCZ /C.region.getVolumePixels()));
                nodes.setValue(markerTypes[m]+"_mean_intensity_cellzone", c, Math.round(C.region.getPixMeanValue(lsraw.get(m))));
                nodes.setValue(markerTypes[m]+"_median_intensity_cellzone", c, Math.round(C.region.getPixMedianValue(lsraw.get(m))));
                
                nodes.setValue(markerTypes[m]+"_pct_coverage_nuc", c, Math.round(100*nbM /C.nucleus.getVolumePixels()));
                nodes.setValue(markerTypes[m]+"_mean_intensity_nuc", c, Math.round(C.nucleus.getPixMeanValue(lsraw.get(m))));
                nodes.setValue(markerTypes[m]+"_median_intensity_nuc", c, Math.round(C.nucleus.getPixMedianValue(lsraw.get(m))));
                

            }    
            
            c = c + 1;
            if(c%10000==0){
                IJ.log("Progress Done: "+Math.round(100*c/nb_cells)+"%\n");
            }
            
            
        }
//        IJ.selectWindow(image_fn);
//        IJ.saveAs("Tiff", save_dir + image_fn + ".tif");
        
        try {
            String node_fn = save_dir+image_fn+"_cell_profiles.csv";
//            String edge_fn = save_dir+image_fn+"_cells_interaction_network.csv";
            IJ.log(node_fn);
//            IJ.log(edge_fn);
            nodes.saveAs(node_fn);
//            edges.saveAs(edge_fn);
        } catch (IOException ex) {
            IJ.log("Have the problem in storing csv file, double check scripts");
        }
        
        
    }
    
    private void initCells(ImageFloat nucLabel, ImageFloat regionLabel) //, String image_fn, String save_dir
    {
        popNuclei = new Objects3DPopulation(nucLabel);
//        popRegions = new Objects3DPopulation(regionLabel, 1); // exclude value 1 used by borders
        popRegions = new Objects3DPopulation(regionLabel); 

        popCells = new ArrayList<Cell>(popNuclei.getNbObjects());

//        region2Cell = new HashMap<Integer, Cell>(popNuclei.getNbObjects());
//        nucleus2Cell = new HashMap<Integer, Cell>(popNuclei.getNbObjects());

        // get nucleus label for each region
//        int c = 1;
        //int count = 0;
        for (Object3D nc : popNuclei.getObjectsList()) 
        {
            Object3DPoint vnuc = new Object3DPoint(nc.getValue(), nc.getCenterAsPoint());
            int reg = (int) vnuc.getPixModeNonZero(regionLabel);
            //IJ.log("nuc " + nuc);
            if(reg==-1){ continue;}
            else
            {
                Cell cell = new Cell();
                cell.nucleus = nc;
                cell.region = popRegions.getObjectByValue(reg);
                popCells.add(cell);
                cell.id = nc.getValue();
//                region2Cell.put(cell.region.getValue(), cell);
//                nucleus2Cell.put(nc.getValue(), cell);
            }
            
                  
        }
        IJ.log("Number of cells is: " + popCells.size());
        
//        popNuclei.saveObjects(save_dir+image_fn+"_SEG.zip");
//        popRegions.saveObjects(save_dir+image_fn+"_WAT.zip");
        
    }
//    private void initCells(ImageFloat nucLabel, String image_fn, String save_dir) 
//    {
//        popNuclei = new Objects3DPopulation(nucLabel);
////        popRegions = new Objects3DPopulation(regionLabel); // exclude value 1 used by borders
//
//        popCells = new ArrayList<Cell>(popNuclei.getNbObjects());
//
////        region2Cell = new HashMap<Integer, Cell>(popRegions.getNbObjects());
////        nucleus2Cell = new HashMap<Integer, Cell>(popNuclei.getNbObjects());
//
//        // get nucleus label for each region
//        int c = 0;
//        //int count = 0;
//        for (Object3D nc : popNuclei.getObjectsList()) 
//        {
////            int nuc = (int) region.getPixModeNonZero(nucLabel);
////            int nuc = nc.getValue();
//            //IJ.log("nuc " + nuc);
////            if(nuc==-1){ continue;}
////            else
////            {
////                Cell cell = new Cell();
////                cell.region = null;
////                cell.nucleus = popNuclei.getObjectByValue(nuc);
////                popCells.add(cell);
////                cell.id = c++;
////                
////            }
//            Cell cell = new Cell();
//            cell.region = null;
//            cell.nucleus = nc;
//            popCells.add(cell);
//            cell.id = c++;
//                  
//        }
//        IJ.log("DEBUG");
//        IJ.log("Number of cells is: " + popCells.size());
////        IJ.log("Number of regions is: " + popRegions.getNbObjects());
//        
////        popNuclei.saveObjects(save_dir+image_fn+"_SEG.zip");
////        popRegions.saveObjects(save_dir+image_fn+"_WAT.zip");
//        
//    }
}   