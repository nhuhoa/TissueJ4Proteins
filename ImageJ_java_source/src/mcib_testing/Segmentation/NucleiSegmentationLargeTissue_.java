/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package mcib_testing.Segmentation;

import ij.IJ;
import ij.ImagePlus;
import ij.WindowManager;
import fiji.util.gui.GenericDialogPlus;
import ij.io.Opener;
import ij.plugin.PlugIn;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import mcib3d.geom.Object3D;
import mcib3d.geom.Object3DVoxels;
import mcib3d.geom.Objects3DPopulation;
import mcib3d.geom.Voxel3D;
import mcib3d.image3d.ImageFloat;
import mcib3d.image3d.ImageHandler;
import mcib3d.image3d.ImageInt;
import mcib3d.image3d.ImageShort;
/**
 *
 * @author tranhoa
 */
public class NucleiSegmentationLargeTissue_ implements PlugIn
{
    public String input_dir="", save_dir = "";
    public boolean verbose = false;
    int overlap_size = 50, tile_size = 300; //max_radius_nuc = 10, 
//    String prefix_img = "NUC.tif__1_", suffix_img="_SEG.tif";
    int img_sizeX=0, img_sizeY=0; // TO DO: using code to get this values, fixed values for testing first

    public void run(String arg) 
    {	
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
        gd.addMessage("Input : a folder of segmented images");
        gd.addMessage("Output: combined segmented images");
        gd.addMessage(" \n");
        gd.addDirectoryField("Input Dir: ", input_dir, 30);
        gd.addDirectoryField("Save Dir: ", save_dir, 30);
        gd.addNumericField("Overlapping Tile Size ", overlap_size, 0, 10, "");
//        gd.addNumericField("Maximal Nucleus Radius", max_radius_nuc, 0, 10, "");
        gd.addNumericField("Tile Size", tile_size, 0, 10, "");
        gd.addNumericField("Combined Image Width X", img_sizeX, 0, 10, "");
        gd.addNumericField("Combined Image Height Y", img_sizeY, 0, 10, "");
        gd.addCheckbox("Display Output", verbose);
        
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
        overlap_size = (int) gd.getNextNumber();
        tile_size = (int) gd.getNextNumber();
        img_sizeX = (int) gd.getNextNumber();
        img_sizeY = (int) gd.getNextNumber();
        verbose = gd.getNextBoolean();
        IJ.log("Tile size: " + tile_size);
        IJ.log("Overlapping_size: " + overlap_size);
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
        IJ.log("====================================================================");
        IJ.log("Initializing...");
        ArrayList<String> seg_tiles = getFilesFromFolder(input_dir);
        String suffix_img = getSuffixImage(seg_tiles);
        String prefix_img = getPrefixImage(seg_tiles);
        
        if(img_sizeX==0 || img_sizeY==0){
            int[] img_size = getCombinedImageSize(seg_tiles, prefix_img, suffix_img, input_dir);
            img_sizeX = img_size[0];
            img_sizeY = img_size[1];
        }
        IJ.log("Combined image size: "+img_sizeX + " ht: "+img_sizeY);
        int max_radius_nuc = Math.round(overlap_size/2);
        create_tile_number(seg_tiles, img_sizeX, img_sizeY, tile_size, tile_size, 
                           overlap_size, max_radius_nuc, prefix_img, suffix_img);
        // TO DO: get csv files of cells info
        IJ.log("Completed!");
        IJ.log("====================================================================");
    }
    public void create_tile_number(ArrayList<String> seg_tiles, int img_sizeX, int img_sizeY, 
                                       int sizeX, int sizeY, int overlap_size, int max_radius_nuc,
                                       String prefix_img, String suffix_img){
        IJ.log("Creating tile list: ");
//        ArrayList<String> imgs = new ArrayList<>();
        int nbX = (int)Math.ceil((double)img_sizeX/sizeX) + 1;
        int nbY = (int)Math.ceil((double)img_sizeY/sizeY) + 1;
        IJ.log("nbX: "+nbX);
        IJ.log("nbY: "+nbY);
        int x=0, y=0;
        Objects3DPopulation df = null;
        
        int count=0;
        for(int j=1; j<=nbY; j++){
            for(int i=1; i<=nbX; i++){
                if(i==1){
                    x = 0;
                }else{
                    x = (i-1) * (sizeX-overlap_size);
                }
                if(j==1){
                    y = 0;
                }else{
                    y = (j-1) * (sizeY-overlap_size);
                }
                
                if(x<img_sizeX & y < img_sizeY){
                    String tile = prefix_img +  x +"_"+ y + suffix_img;
//                    imgs.add(tile);
//                    IJ.log("Tile: "+tile);
                    if(seg_tiles.contains(tile)){
                        IJ.log("--------------------------------\n");
                        IJ.log("Process Tile: "+tile);
                        Opener opener = new Opener();
                        opener.setSilentMode(true);
                        IJ.redirectErrorMessages(true);
                        ImagePlus imp = opener.openImage(input_dir, tile);
                        IJ.redirectErrorMessages(false);
                        if (imp!=null) {
                            ImageInt imgSegTile = ImageInt.wrap(imp);
                            Objects3DPopulation pop_df = null;
                            count++;
                            if(df==null){ // first block, x==0 && y==0 in common case
                                Objects3DPopulation tmp = new Objects3DPopulation(imgSegTile);
                                if(tmp.getNbObjects()>0){
                                    if(x!=0 || y!=0){
                                        tmp = translation_coordinates(tmp, x, y);
                                    }
                                    df = tmp;
                                }
//                                IJ.log("**** Testing first df: "+df.getNbObjects());
//                                pop_df = null; 
                            }else{
                                pop_df = new Objects3DPopulation(imgSegTile);
                                pop_df = translation_coordinates(pop_df, x, y);
//                                IJ.log("Testing pop_df: "+pop_df.getNbObjects());
                            }
                            df = merging_given_blocks(df, pop_df, x, y, max_radius_nuc, overlap_size, 
                                                      sizeX, sizeY, verbose);
                            
                            
                        }
                    }
                }    
                        
                   
            }
        }
        IJ.log("Number of processed tiles: "+count);
        if(df!=null){
            df = reIndex(df);
            String image_fn = "combined_"+prefix_img;
            drawImage(df, img_sizeX, img_sizeY, save_dir, image_fn, verbose);
        }
        
    }
    public void drawImage(Objects3DPopulation pop, int img_sizeX, int img_sizeY, 
                          String save_dir, String image_fn, boolean verbose){ //
        ImageHandler draw = null;
        if(pop.getNbObjects()<65535){
            draw = new ImageShort(image_fn, img_sizeX, img_sizeY, 1); //16 bits images
        }else{
            draw = new ImageFloat(image_fn, img_sizeX, img_sizeY, 1); //32 bits images
        }

//        for (Object3D c : pop.getObjectsList()) {
//            c.draw(draw,c.getValue());
//        }
        pop.draw(draw);
        if(verbose){
            draw.show();
        }
        
//        IJ.selectWindow(image_fn);
//        IJ.saveAs("Tiff", save_dir + image_fn + ".tif"); // TO DO save as .zip file
//        IJ.saveAs(draw.getImagePlus(), "Tiff", save_dir + image_fn + ".tif");
        IJ.saveAs(draw.getImagePlus(), "ZIP", save_dir + image_fn + ".zip");
        pop.saveObjects(save_dir + image_fn + "_listObjs.zip");
        IJ.log("Save combined image as: "+save_dir + image_fn + ".zip");
        IJ.log("Save list of segmented objects as: "+save_dir + image_fn + "_listObjs.zip");
        
    }
    public Objects3DPopulation translation_coordinates(Objects3DPopulation pop, int currX, int currY){
//        IJ.log("Debug translation");
        int currZ=0; // in case we want to process 3D image
//        for (int z = 0; z < img.sizeZ; z++) {
//                for (int y = 0; y < img.sizeY; y++) {
//                    for (int x = 0; x < img.sizeX; x++) {
//                        px = img.getPixel(x, y, z);
//                        
//                        }
//                    }
//                }
//            }
        ArrayList<Object3D> pop_ls = new ArrayList<Object3D>();
        for (Object3D o : pop.getObjectsList()) 
        {
            ArrayList<Voxel3D> lsvox = o.getObject3DVoxels().getVoxels();
            ArrayList<Voxel3D> modified_lsvox = new ArrayList<>();
            for(int v=0; v<lsvox.size(); v++){
                Voxel3D vo = lsvox.get(v);
                vo.setVoxel(vo.getX()+currX, vo.getY()+ currY, currZ, vo.getValue());
                modified_lsvox.add(vo);
            }
            Object3DVoxels new_obj = new Object3DVoxels(modified_lsvox);
            pop_ls.add(new_obj);
        }
        Objects3DPopulation new_pop = new Objects3DPopulation(pop_ls);
//        IJ.log("Debug translation done");
        return(new_pop);
    }
    public Objects3DPopulation merging_blocks_XY(Objects3DPopulation df, Objects3DPopulation pop_df,
                                  int currX, int currY, String merge_direction,
                                  int sizeX, int sizeY, int overlap_size, boolean verbose){
        
//        if(df==null){
//            return(null);
//        }
//        IJ.log("current df: "+df.getNbObjects());
//        if(pop_df!=null && pop_df.getNbObjects()>0){
//            IJ.log("pop df: "+pop_df.getNbObjects());
//        }
        ArrayList<Integer> excludeX = new ArrayList<>();
        ArrayList<Integer> excludeY = new ArrayList<>();
        ArrayList<Integer> exclude_total = new ArrayList<>();
        Objects3DPopulation combined_df = null;
        int curr_idx = 0; 
        int eps = 0; 
        for (Object3D c : df.getObjectsList()) 
        {
            if(curr_idx < c.getValue()){
                curr_idx = c.getValue();
            }
            if(c.getCenterX() >= (currX-eps) && c.getCenterX() <= (currX+overlap_size) 
                    && c.getCenterY()>=currY && c.getCenterY() <= (currY+sizeY)){
                excludeX.add(c.getValue());
            }
            if(c.getCenterY() >= (currY-eps) && c.getCenterY() <= (currY+overlap_size) 
                    && c.getCenterX()>=currX && c.getCenterX() <= (currX+sizeY)){
                excludeY.add(c.getValue());
            }
        }
        
        IJ.log("Merging in "+ merge_direction + " direction");
        ArrayList<Object3D> tmp = new ArrayList<Object3D>();
        Objects3DPopulation pop_df1 = null;
        if(merge_direction.equals("X")){
            if(excludeX.size()>0){
                exclude_total.addAll(excludeX);
//                IJ.log("Excluded X: "+excludeX.size());
            }
            
            for (Object3D o : pop_df.getObjectsList()) 
            {
                if(o.getCenterX()>=currX){
//                    pop_df.removeObject(o.getValue());
                    tmp.add(o);
                }
            }
            pop_df1 = new Objects3DPopulation(tmp);
            
        } else if(merge_direction.equals("Y")){
            if(excludeY.size()>0){
                exclude_total.addAll(excludeY);
//                IJ.log("Excluded Y: "+excludeY.size());
            }
            
            for(Object3D o : pop_df.getObjectsList()) 
            {
                if(o.getCenterY()>=currY){
//                    pop_df.removeObject(o.getValue());
                    tmp.add(o);
                }
            }
            pop_df1 = new Objects3DPopulation(tmp);
            
        }else if(merge_direction.equals("XY")){
            if(excludeX.size()>0){
                exclude_total.addAll(excludeX);
//                IJ.log("Excluded X: "+excludeX.size());
            }
            if(excludeY.size()>0){
                exclude_total.addAll(excludeY);
//                IJ.log("Excluded Y: "+excludeY.size());
            }
            for (Object3D o : pop_df.getObjectsList()) 
            {
                if(o.getCenterX()>=currX && o.getCenterY()>=currY){
//                    pop_df.removeObject(o.getValue());
                    tmp.add(o);
                }
            }
            pop_df1 = new Objects3DPopulation(tmp);
        }else{
            IJ.log("");
        }
        
        ArrayList<Object3D> pop_ls = new ArrayList<Object3D>();   
        ArrayList<Object3D> tmp_df = new ArrayList<Object3D>();
        if(!exclude_total.isEmpty()){
            for (Object3D c : df.getObjectsList()) 
            {
                if(!exclude_total.contains(c.getValue())){
                    tmp_df.add(c);
                }

            }
            pop_ls.addAll(tmp_df);
        }else{
            pop_ls.addAll(df.getObjectsList());
        }
                
        
//            Objects3DPopulation df1 = new Objects3DPopulation(tmp_df);
//            for (int e=0; e < exclude_total.size(); e++) 
//            {
//                df.removeObject(exclude_total.get(e));
//            }
//            IJ.log("Current index: " + curr_idx);
         
        
        if(pop_df1!=null){
            
            for (Object3D o : pop_df1.getObjectsList()) 
            {
                o.setValue(curr_idx + o.getValue());
                pop_ls.add(o);
            }
        }
        
        
        IJ.log("# objs: "+pop_ls.size());
        combined_df = new Objects3DPopulation(pop_ls);
        
        
        return(combined_df);
    }
    public Objects3DPopulation reIndex(Objects3DPopulation pop){
        ArrayList<Object3D> pop_ls = new ArrayList<Object3D>();
        int ct = 0;
        for (Object3D o : pop.getObjectsList()) 
        {   
            ct++;
            o.setValue(ct);
            pop_ls.add(o);
        }
            
        Objects3DPopulation new_pop = new Objects3DPopulation(pop_ls);
        return(new_pop);
    }
    
    public Objects3DPopulation merging_given_blocks(Objects3DPopulation df, Objects3DPopulation pop_df,
                                  int startX, int startY, int max_radius, int overlap_size, 
                                  int sizeX, int sizeY, boolean verbose){
        if(startY==0 && startX==0){  //do not merge, starting block
            IJ.log("First block");
        }else if(startY==0 && startX>0 && df!=null & pop_df!=null && pop_df.getNbObjects()>0){  //merging X direction
            startX = startX + max_radius;
            df = merging_blocks_XY(df, pop_df, startX, startY, "X", sizeX, sizeY, overlap_size, verbose);
        }else if(startY>0 && startX==0 && df!=null && pop_df!=null && pop_df.getNbObjects()>0){  //merging X direction
            startY = startY + max_radius;
            df = merging_blocks_XY(df, pop_df, startX, startY, "Y", sizeX, sizeY, overlap_size, verbose);
        }else if(startY>0 && startX>0 && df!=null && pop_df!=null && pop_df.getNbObjects()>0){  //merging X direction
            startX = startX + max_radius;
            startY = startY + max_radius;
            df = merging_blocks_XY(df, pop_df, startX, startY, "XY", sizeX, sizeY, overlap_size, verbose);
        }
        return(df);
    }
    



    
//    create_tile_number <- function(img_sizeX, img_sizeY, sizeX, sizeY, overlap_size,
//                               prefix_img='', suffix_img='.tif'){
//  imgs <- c()
//  nbX <- ceiling(img_sizeX/sizeX)+1
//  nbY <- ceiling(img_sizeY/sizeY)+1
//  for(i in seq(1:nbX)){
//    # xprev <- 0
//    for(j in seq(1:nbY)){
//      # yprev <- 0
//      if(i==1){
//        x <- 0
//      }else{
//        # x <- xprev + sizeX - overlap_size
//        x <- (i-1) * (sizeX-overlap_size)
//        
//        # xprev <- x
//      }
//      if(j==1){
//        y <- 0
//      }else{
//        # y <- yprev + sizeY - overlap_size
//        # yprev <- y
//        y <- (j-1) * (sizeY-overlap_size)
//      }
//      if(x<img_sizeX & y < img_sizeY){
//        tile = paste0(prefix_img,'_',x,'_',y,suffix_img)
//        imgs <- c(imgs, tile)  
//        print(tile)
//      }
//      
//      
//    }  
//  }
//  length(imgs)
    
//}
    public int[] getCombinedImageSize(ArrayList<String> seg_tiles, String prefix, String suffix, String input_dir){
        int xmax=0, ymax=0;
        for(int i=1; i<seg_tiles.size(); i++){
            String tmp = seg_tiles.get(i);
            String desc = tmp.substring(prefix.length(), tmp.indexOf(suffix));
            int X = Integer.parseInt(desc.substring(0, desc.indexOf("_")));
            int Y = Integer.parseInt(desc.substring(desc.indexOf("_")+1, desc.length()));
//            System.out.println("out: "+desc+"  X: "+X+"  Y: "+Y);
            if(xmax<X){
                xmax=X;
            }
            if(ymax<Y){
                ymax=Y;
            }
        }
//        IJ.log("out:  X: "+xmax+"  Y: "+ymax);
        String borderX_image = prefix + xmax + "_0" + suffix;
        String borderY_image = prefix + "0_" + ymax + suffix;
        // loading images and get size of image from here 
//        IJ.log("final X: "+borderX_image);
//        IJ.log("final Y: "+borderY_image);
        int img_wd = 0, img_ht = 0;
        Opener opener = new Opener();
        opener.setSilentMode(true);
        IJ.redirectErrorMessages(true);
        ImagePlus imp = opener.openImage(input_dir, borderX_image);
        IJ.redirectErrorMessages(false);
        
        if (imp!=null) {
            img_wd = xmax + imp.getWidth();
        }
        IJ.redirectErrorMessages(true);
        ImagePlus imp1 = opener.openImage(input_dir, borderY_image);
        IJ.redirectErrorMessages(false);
        
        if (imp1!=null) {
            img_ht = ymax + imp1.getHeight();
        }
        int[] image_size={img_wd, img_ht};
//        IJ.log("Combined image size: "+img_wd + " ht: "+img_ht);
        if(img_wd!=0 && img_ht!=0){
            return(image_size);
        }else{
            return(null);
        }
        
    }
    public String getPrefixImage(ArrayList<String> seg_tiles){
        String prefix = seg_tiles.get(0);
        int minVal = prefix.length(); 
        for(int i=1; i<seg_tiles.size(); i++){
            minVal = Math.min(seg_tiles.get(i).length(), prefix.length());
            while(!seg_tiles.get(i).substring(0, minVal).equals(prefix)
                        && minVal>=2){
        //            minVal = Math.min(minVal, prefix.length());
                    minVal = minVal - 1;
                    prefix = prefix.substring(0, minVal);
    //                System.out.println(prefix);
    //                System.out.println(minVal);
            }
//            System.out.println("Out: " + i +": "+ prefix);
        }
        if(!"".equals(prefix)){
            IJ.log("Prefix of image: " + prefix);
            return(prefix);
        }else{
            IJ.log("Issue with prefix of images or list files contain hidden files");
            return(null);
        }
    }
    public String getSuffixImage(ArrayList<String> seg_tiles){
        
        String suffix = seg_tiles.get(0);
        int sx = suffix.length();
        int maxVal = 0; 
        String suffix_tmp = suffix;
        for(int i=1; i<seg_tiles.size(); i++){
            while(!seg_tiles.get(i).substring(seg_tiles.get(i).length()-suffix_tmp.length(), seg_tiles.get(i).length()).equals(suffix_tmp)
                        && maxVal<sx){
                    maxVal = maxVal + 1;
                    suffix_tmp = suffix.substring(maxVal, suffix.length());
            }
//            System.out.println("Out: " + i +": "+ suffix_tmp);
        }
//        System.out.println("final output: "+suffix_tmp);

        suffix = suffix_tmp;
        int idx = suffix.lastIndexOf("_");
        if(idx>0){
            suffix=suffix.substring(idx, suffix.length());
        }
        if(!"".equals(suffix)){
            IJ.log("Suffix images is: "+suffix);
            return(suffix);
        }else{
            IJ.log("Issue with suffix of images or list files contain hidden files");
            return(null);
        }
        
        
    }
    public ArrayList<String> getFilesFromFolder(String directory) {
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
                return(null);
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
        IJ.log("\nList of files in given folder: ");
        for(int i=0; i<list.length; i++){
            IJ.log(" "+list[i]);
        }
        ArrayList<String> seg_tiles = new ArrayList<String>(Arrays.asList(list));
        return(seg_tiles);
    }
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
        String[] excludedTypes = {".txt",".lut",".roi",".pty",".hdr",".java",".ijm",
                                  ".py",".js",".bsh",".xml",".rar",".h5",".doc",".xls"};
        if (name==null) return true;
        for (int i=0; i<excludedTypes.length; i++) {
            if (name.endsWith(excludedTypes[i]))
                return true;
        }
        return false;
    }

    
            
}
