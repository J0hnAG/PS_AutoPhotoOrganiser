# PS_AutoPhotoOrganiser
Automatically renames and moves photos into destination directory

To get this setup you need a source directory and destination directory. You will also need the Exiftool installed - https://exiftool.org/.


You will then need to update the follow text in the script:

Example:
  
**Windows**  
  
$sourcePath = "C:\Media\PhotoImport"
  
$destinationPath = "D:\Media\PhotoLibrary"
  
$exifToolPath = "C:\exiftool\exiftool"
  
  
**Linux**  (With Powershell installed)
  
$sourcePath = "/mnt/Media/PhotoImport"

$destinationPath = "/mnt/Media/PhotoLibrary"

$exifToolPath = "/usr/localuser/exiftool/exiftool"
  

The source directory will be a "dumping" location for all your photos. It will then rename these files in the following format, based on the "date taken" exif metadata:

Photos = Photo_dd-MM-yyyy_x
  
Videos = Video_dd-MM-yyyy_x


The x is a consectutive number to handle any file taken on the same day.

NOTE: If the photo does not have any "date taken" metadata, it will fallback to using the last modified date.

Once renamed, the script will move the files into the destination directory in the structure as follows:

-> Year
  
-------> Month

Example: 

-> 2023
  
-------> January
  
----------------> Photo_20-01-2023_1.jpg
  
----------------> Photo_20-01-2023_2.jpg
  
----------------> Video_25-01-2023_1.mp4

Once the script has run, it will output the actions taken into a log file. This is useful if you schedule the task to run daily to automatically organise any photos or videos dumped into the source location.

