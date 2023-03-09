/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package mcib_testing.Segmentation;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 *
 * @author miu
 */
public class Testing {
  public static void write2File(List<String[]> records, String output_fn) throws IOException{
        File csvFile = new File(output_fn);
        FileWriter fileWriter = new FileWriter(csvFile);
        for (String[] data : records) {
        StringBuilder line = new StringBuilder();
        for (int i = 0; i < data.length; i++) {
            line.append(data[i]);
            if (i != data.length - 1) {
                line.append(',');
            }
        }
        line.append("\n");
        fileWriter.write(line.toString());
        }
        fileWriter.close();
        System.out.println("Writen output into file: "+output_fn);
  }  
 
//  public static void main(String[] args){
//      
////    String[][] employees = {
////                        {"Man", "Sparkes", "msparkes0@springhow.com", "Engineering"},
////                        {"Dulcinea", "Terzi", "dterzi1@springhow.com", "Engineering"},
////                        {"Tamar", "Bedder", "tbedder2@springhow.com", "Legal"},
////                        {"Vance", "Scouller", "vscouller3@springhow.com", "Sales"},
////                        {"Gran", "Jagoe", "gjagoe4@springhow.com", "Business Development"}
////        };
////    List<String[]> employees = new ArrayList<>();
////    employees.add(new String[] 
////        { "John", "Doe", "38", "dsdsddsd" });
////    employees.add(new String[] 
////        { "Jane", "Doe", "19", "ddddfdfff" });
////    String output_fn = "/Users/miu/Documents/workspace/testing/employees.csv";
////    String t = "aaaa" + (8+10);
////    System.out.println(t);
//    
//    String suffix = "0_WAT_SEG.tif";
//    suffix=suffix.substring(1, suffix.length());
//    System.out.println(suffix);
////    try {
////        write2File(employees, output_fn);
////    } catch (IOException ex) {
////        Logger.getLogger(Testing.class.getName()).log(Level.SEVERE, null, ex);
////    }    
////    String myStr = "NUC.tif__1_0_0_SEG.tif";
////    System.out.println(myStr.lastIndexOf("."));
////    
////    // Suffix
////    System.out.println(myStr.substring(myStr.lastIndexOf("."), myStr.length()));
//
//
////    String[] ini_strlist = {"NUC.tif__1_0_0_SEG.tif","NUC.tif__1_0_250_SEG.tif",
////    "NUC.tif__1_500_250_SEG.tif","NUC.tif__1_0_750_SEG.tif"};
//////    String mystr = "NUC.tif";
////    for(int i=1; i<mystr.length(); i++){
////        System.out.println("from 0 to "+i+": "+mystr.substring(0, i));
////    }
////    String res = "";
////    ArrayList<String> seg_tiles = new ArrayList<String>(
////            Arrays.asList("NUC.tif__1_0_0_SEG.tif","NUC.tif__1_0_250_SEG.tif",
////    "NUC.tif__1_500_250_SEG.tif","NUC.tif__1_0_750_SEG.tif","NUC.tif__1_750_750_SEG.tif"));
//
////    String prefix = "NUC.tif__1_";
////    String suffix = "_SEG.tif";
////    int xmax=0, ymax=0;
////    for(int i=1; i<seg_tiles.size(); i++){
////        String tmp = seg_tiles.get(i);
////        String desc = tmp.substring(prefix.length(), tmp.indexOf(suffix));
////        int X = Integer.parseInt(desc.substring(0, desc.indexOf("_")));
////        int Y = Integer.parseInt(desc.substring(desc.indexOf("_")+1, desc.length()));
////        System.out.println("out: "+desc+"  X: "+X+"  Y: "+Y);
////        if(xmax<X){
////            xmax=X;
////        }
////        if(ymax<Y){
////            ymax=Y;
////        }
////    }
////    System.out.println("out:  X: "+xmax+"  Y: "+ymax);
////    String borderX_image = prefix + xmax + "_0" + suffix;
////    String borderY_image = prefix + "0_" + ymax + suffix;
////    // loading images and get size of image from here 
////    System.out.println("final X: "+borderX_image);
////    System.out.println("final Y: "+borderY_image);
//    
////    String prefix = ini_strlist[0];
//////    System.out.println(prefix);
////    int minVal = Math.min(ini_strlist[1].length(), prefix.length());
//////    System.out.println(minVal);
//////    System.out.println(ini_strlist[1].substring(0, minVal));
////    prefix = prefix.substring(0, minVal);
////    for(int i=1; i<ini_strlist.length; i++){
////        minVal = Math.min(ini_strlist[i].length(), prefix.length());
////        while(!ini_strlist[i].substring(0, minVal).equals(prefix)
////                    && minVal>=2){
////    //            minVal = Math.min(minVal, prefix.length());
////                minVal = minVal - 1;
////                prefix = prefix.substring(0, minVal);
//////                System.out.println(prefix);
//////                System.out.println(minVal);
////        }
////        System.out.println("Out: " + i + prefix);
////    }
////    System.out.println("final output: "+prefix);
//
//    
//////    String mystr = "NUC.tif";
//////    for(int i=1; i<mystr.length(); i++){
//////        System.out.println("from 0 to "+i+": "+mystr.substring(0, i));
//////    }
//////    String res = "";
////    String prefix = seg_tiles.get(0);
////    System.out.println(prefix);
////    int minVal = Math.min(seg_tiles.get(1).length(), prefix.length());
//////    System.out.println(minVal);
////    System.out.println(seg_tiles.get(1).substring(0, minVal));
////    prefix = prefix.substring(0, minVal);
////    int minVal = prefix.length(); 
////    for(int i=1; i<seg_tiles.size(); i++){
////        minVal = Math.min(seg_tiles.get(i).length(), prefix.length());
////        while(!seg_tiles.get(i).substring(0, minVal).equals(prefix)
////                    && minVal>=2){
////    //            minVal = Math.min(minVal, prefix.length());
////                minVal = minVal - 1;
////                prefix = prefix.substring(0, minVal);
//////                System.out.println(prefix);
//////                System.out.println(minVal);
////        }
////        System.out.println("Out: " + i +": "+ prefix);
////    }
////    System.out.println("final PREFIX: "+prefix);
//    
////    String suffix = seg_tiles.get(0);
////    
////    int sx = suffix.length();
////    int maxVal = 0; 
////    System.out.println(suffix);
////    System.out.println(suffix.length());
////    String suffix_tmp = suffix;
////    for(int i=1; i<seg_tiles.size(); i++){
//////        maxVal = Math.min(seg_tiles.get(i).length(), prefix.length());
////        
////        while(!seg_tiles.get(i).substring(seg_tiles.get(i).length()-suffix_tmp.length(), seg_tiles.get(i).length()).equals(suffix_tmp)
////                    && maxVal<sx){
////    //            minVal = Math.min(minVal, prefix.length());
//////                System.out.println("\n test: "+seg_tiles.get(i).substring(seg_tiles.get(i).length()-suffix_tmp.length(), seg_tiles.get(i).length()));
//////                System.out.println("suffix is: "+suffix_tmp);
////                maxVal = maxVal + 1;
////                suffix_tmp = suffix.substring(maxVal, suffix.length());
////                
//////                System.out.println("suffix is: "+suffix_tmp);
//////                System.out.println("maxVal is: "+maxVal);
////        }
////        System.out.println("Out: " + i +": "+ suffix_tmp);
////    }
////    System.out.println("final output: "+suffix_tmp);
////    
////    suffix = suffix_tmp;
////    int idx = suffix.lastIndexOf("_");
////    if(idx>0){
////        suffix=suffix.substring(idx, suffix.length());
////    }
//    
////    for(int i=1; i<ini_strlist.length; i++){
////        while(!ini_strlist[i].substring(0, prefix.length()-1).equals(prefix)
////                && prefix!=null){
////            prefix = prefix.substring(0, prefix.length()-1);
////            System.out.println(prefix);
////        }
////        if(prefix!=null){
////            break;
////        }
////        
////    }
////    res = prefix;
////    System.out.println("Output is: "+res);
//    
////    for(string in ini_strlist[1:]):
////        while string[:len(prefix)] != prefix and prefix:
////            prefix = prefix[:len(prefix)-1]
////        if not prefix:
////            break
////    res = prefix
//      
//    }
   
}
