#!/bin/bash

ZIP_FILE_1="book-ack-function.zip"
FOLDER_1="book-ack-function"
ZIP_FILE_2="cancel-ack-function.zip"
FOLDER_2="cancel-ack-function"
# Check if the zip file already exists
if [ -e "$ZIP_FILE_1" ]; then
    # If it exists, remove it
    rm "$ZIP_FILE_1"
    echo "$ZIP_FILE_1 Removed Successfully"
fi
# Create the zip file
cd "$FOLDER_1"/
zip -r "$ZIP_FILE_1" *
mv "$ZIP_FILE_1" ../.
cd ..

# Check if the zip file already exists
if [ -e "$ZIP_FILE_2" ]; then
    # If it exists, remove it
    rm "$ZIP_FILE_2"
    echo "$ZIP_FILE_2 Removed Successfully"
fi
cd "$FOLDER_2"/
zip -r "$ZIP_FILE_2" *
mv "$ZIP_FILE_2" ../.