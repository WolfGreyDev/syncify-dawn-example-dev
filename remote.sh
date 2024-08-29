#!/bin/bash

SOURCE_DIR="./source"
THEME_DIR="./theme"
REMOTE_DIR="./remote"

# Make folders if they don't exist
printf "Making the following folders if they don't exist\n"
mkdir -p -v "$REMOTE_DIR/"{assets,config,layout,locales,sections,snippets,templates,templates/customers,templates/metaobject}
printf "\n\n"

# Clean the desintation folders
printf "Cleaning the destination\n"
rm -f -v "$REMOTE_DIR/assets/"*
rm -f -v "$REMOTE_DIR/layout/"*
rm -f -v "$REMOTE_DIR/locales/"*
rm -f -v "$REMOTE_DIR/sections/"*
rm -f -v "$REMOTE_DIR/snippets/"*

rm -f -v "$REMOTE_DIR/config/settings_schema.json"
printf "\n\n"

# Copy folders from source to destination
printf "Copying files from $THEME_DIR to $REMOTE_DIR\n"
cp -R -v "$THEME_DIR/assets/." "$REMOTE_DIR/assets"
cp -R -v "$THEME_DIR/config/." "$REMOTE_DIR/config"
cp -R -v "$THEME_DIR/layout/." "$REMOTE_DIR/layout"
cp -R -v "$THEME_DIR/locales/." "$REMOTE_DIR/locales"
cp -R -v "$THEME_DIR/sections/." "$REMOTE_DIR/sections"
cp -R -v "$THEME_DIR/snippets/." "$REMOTE_DIR/snippets"
printf "\n\n"

# Copy files from source to destination
printf "Copying settings schema file\n"
cp -v "$THEME_DIR/config/settings_schema.json" "$REMOTE_DIR/config/settings_schema.json"
printf "\n\n"

printf "Adding settings data file if it doesn't exist\n"
cp -R -n -v "$SOURCE_DIR/config/settings_data.json" "$REMOTE_DIR/config/settings_data.json"
printf "\n\n"

# Copy templates that aren't present in the destination
printf "Adding new templates if they don't exist\n"
cp -R -n -v "$THEME_DIR/templates/." "$REMOTE_DIR/templates"
cp -R -n -v "$SOURCE_DIR/templates/." "$REMOTE_DIR/templates"
printf "\n\n"

printf "$REMOTE_DIR is now up to date. Check log before commiting changes."

exit 0