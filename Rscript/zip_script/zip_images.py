"""
a zip function
"""
import argparse
import os
import sys
from tifffile import imread, imsave
from zipfile import ZIP_DEFLATED


def zip_images_folder(input_dir, output_dir):
    
    if not os.path.exists(output_dir): 
        os.makedirs(output_dir)
    
    image_files = [ f for f in os.listdir(input_dir) if f.endswith(".tif") & os.path.isfile(os.path.join(input_dir,f)) ]
    print('Number of images in folder:')
    print(len(image_files))
    
    print('Reading images files and compressing...')
    for f in image_files:
        obs_img = imread(os.path.join(input_dir, f))
        # print(f)
        # f1 = f # can change the name of f1 in case neceassary
        # imsave(os.path.join(output_dir, f1), obs_img, compress=ZIP_DEFLATED)        
        imsave(os.path.join(output_dir, f), obs_img, compress=ZIP_DEFLATED)        
    



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_dir', required=True)  #dir that contain input image 
    parser.add_argument('--output_dir', required=True) #dir to save compressed images
    args = vars(parser.parse_args())
    print(args['input_dir'])
    print(args['output_dir'])
    zip_images_folder(args['input_dir'], args['output_dir'])
    
    
