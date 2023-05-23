# Set the source and destination paths
$sourcePath = "<ENTER SOURCE DIRECTORY>"
$destinationPath = "<ENTER DESTINATION DIRECTORY>"

# Path to the ExifTool executable
$exifToolPath = "<EXIFTOOL INSTALL DIRECTORY>/exiftool"

# Get the current timestamp for the output file name
$timestamp = Get-Date -Format "dd-MM-yyy_HHmmss"

# Define the output file path
$outputFilePath = "<OUTPUT DIRECTORY>/AutoPhotoOrganiserOutput_$timestamp.txt"

# Redirect the output to the file
Start-Transcript -Path $outputFilePath

# Get all files in the source directory including subfolders
$files = Get-ChildItem -Path $sourcePath -Recurse

# Define an array of month names
$monthNames = @("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")

# Loop through each file
foreach ($file in $files) {
    # Get the file extension
    $extension = $file.Extension.ToLower()

    # Check if the file is a .jpg, .jpeg, or .png file
    if ($extension -eq ".jpg" -or $extension -eq ".jpeg" -or $extension -eq ".png" -or $extension -eq ".mp4") {
        # Determine the prefix based on the file extension
        $prefix = if ($extension -eq ".jpg" -or $extension -eq ".jpeg" -or $extension -eq ".png") { "Photo_" } else { "Video_" }

        # Get the "Date Taken" EXIF metadata value
        $dateTaken = & $exifToolPath "-DateTimeOriginal" "-s" "-s" "-s" $file.FullName

        # Use the "Date Taken" value if available; otherwise, use the file's modified date
        if ([string]::IsNullOrWhiteSpace($dateTaken)) {
            $date = $file.LastWriteTime.ToString("dd-MM-yyyy")
        } else {
            $date = [DateTime]::ParseExact($dateTaken, "yyyy:MM:dd HH:mm:ss", $null).ToString("dd-MM-yyyy")
        }

        # Set the initial consecutive number
        $consecutiveNumber = 1

        # Construct the new file name
        $newFileName = "{0}{1}_{2}{3}" -f $prefix, $date, $consecutiveNumber, $extension

        # Get the year and month from the file name
        $year = $date.Split('-')[2]
        $monthNumber = $date.Split('-')[1]
        $monthName = $monthNames[$monthNumber - 1]  # Subtract 1 to match array index

        # Create the year and month folders if they don't exist
        $yearFolder = Join-Path -Path $destinationPath -ChildPath $year
        $monthFolder = Join-Path -Path $yearFolder -ChildPath $monthName
        if (!(Test-Path $yearFolder)) {
            New-Item -ItemType Directory -Path $yearFolder | Out-Null
        }
        if (!(Test-Path $monthFolder)) {
            New-Item -ItemType Directory -Path $monthFolder | Out-Null
        }

        # Keep incrementing the consecutive number until a unique name is found
        while (Test-Path (Join-Path -Path $monthFolder -ChildPath $newFileName)) {
            $consecutiveNumber++
            $newFileName = "{0}{1}_{2}{3}" -f $prefix, $date, $consecutiveNumber, $extension
        }

        # Set the destination path for the file
        $destinationFilePath = Join-Path -Path $monthFolder -ChildPath $newFileName

        # Move the file to the destination directory
        Move-Item -Path $file.FullName -Destination $destinationFilePath

        # Output the renamed file's path
        Write-Output "Renamed and moved $($file.FullName) to $destinationFilePath"
    }
}

# Stop redirecting the output and close the transcript
Stop-Transcript
