#!/bin/bash

ZIP_FILE_1="book-ack-function.zip"
FOLDER_1="book-ack-function"
ZIP_FILE_2="cancel-ack-function.zip"
FOLDER_2="cancel-ack-function"
ZIP_FILE_3='book-payment-function.zip'
FOLDER_3='book-payment-function'
ZIP_FILE_4='cancel-payment-function.zip'
FOLDER_4='cancel-payment-function'
ZIP_FILE_5='book-entry-function.zip'
FOLDER_5='book-entry-function'
# Create the zip file
cd "$FOLDER_2"/
zip -r "$ZIP_FILE_2" *
mv "$ZIP_FILE_2" ../.
cd ..

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
cd ..

#Check if the zip file already exists
if [ -e "$ZIP_FILE_3" ]; then
    # If it exists, remove it
    rm "$ZIP_FILE_3"
    echo "$ZIP_FILE_3 Removed Successfully"
fi
cd "$FOLDER_3"/
zip -r "$ZIP_FILE_3" *
mv "$ZIP_FILE_3" ../.
cd ..

#Check if the zip file already exists
if [ -e "$ZIP_FILE_4" ]; then
    # If it exists, remove it
    rm "$ZIP_FILE_4"
    echo "$ZIP_FILE_4 Removed Successfully"
fi
cd "$FOLDER_4"/
zip -r "$ZIP_FILE_4" *
mv "$ZIP_FILE_4" ../.
cd ..

#Check if the zip file already exists
if [ -e "$ZIP_FILE_5" ]; then
    # If it exists, remove it
    rm "$ZIP_FILE_5"
    echo "$ZIP_FILE_5 Removed Successfully"
fi
cd "$FOLDER_5"/
zip -r "$ZIP_FILE_5" *
mv "$ZIP_FILE_5" ../.
cd ..