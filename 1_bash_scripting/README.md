# Lab work 1: Bash scripting
    Task: 1 - Resize image to given width proportionaly.
    Author: Yuriy Pasichnyk


## Requirements 

You shoud install ImageMagick

## Usage

```$shell
./resize_img.sh
  Usage: ./resize_img.sh (new_width:int) (file_name_pattern:str) [options]

  Description:
  	Resize images, that are matched under suplaed pattern, to given width and
  	with saved proportions. Output file name format:
  		"<original-file-name>-<width>-<height>.<ext>"

  Options:
    -o    --output        Path where to store output images
    -p    --path          Create not existing directories in the output path.


./resize_img.sh 1000 './tesl*.jpg' -o out_dir -p
```
