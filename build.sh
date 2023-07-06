#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to display the menu
display_menu() {
  echo -e "${YELLOW}Please select an option:${NC}"
  echo -e "1. Run 'm updatepackage'"
  echo -e "2. Run 'm otapackage'"
}

# Function to clean the out folder
clean_out_folder() {
  read -p "Clean the out folder? (y/n): " choice
  case $choice in
    [Yy])
      echo -e "${GREEN}Running 'm clean'...${NC}"
      m clean
      echo -e "${YELLOW}Full clean done.${NC}"
      ;;
    [Nn])
      echo -e "${GREEN}Running 'm installclean'...${NC}"
      m installclean
      echo -e "${YELLOW}Partial clean done.${NC}"
      ;;
    *)
      echo -e "${RED}Invalid choice. Cleaning partially.${NC}"
      m installclean
      echo -e "${YELLOW}Cleaning partially.${NC}"
      ;;
  esac
}

# Function to execute 'm updatepackage'
run_updatepackage() {
  echo -e "${GREEN}Running 'm updatepackage'...${NC}"
  m updatepackage
}

# Function to execute 'm otapackage'
run_otapackage() {
  echo -e "${GREEN}Running 'm otapackage'...${NC}"
  m otapackage
}

# Function to rename and upload the build
upload_build() {
  read -p "Upload the new build to Github Releases? (y/n): " choice

  case $choice in
    [Yy])
      # Rename the generated zip file
      date=$(date +"%d%b%Y") # Format the date as desired
      buildName = lineage-$date-amogus.zip
      echo -e "${YELLOW}Uploading the new build: ${buildName} ${NC}"

      mv out/target/product/amogus/lineage_amogus-img-eng.*.zip out/target/product/amogus/"${buildName}".zip

      cd device/motorola/amogus

      # Fill the tag and file path in the git release upload command
      git release upload --tag "$date" --file ../../../out/target/product/amogus/"${buildName}".zip
      echo -e "${GREEN}Upload: succesfull!${NC}"
      
      #cd ../../..
      # already in root's sources
      ;;
    [Nn])
      echo -e "${YELLOW}No upload. ${NC}"
      ;;
  esac
}


# Run apply.sh script
echo -e "${GREEN}Running apply.sh script...${NC}"
if ! bash device/huawei/hwcan/patches/apply.sh; then
  echo -e "${RED}Failed to apply patches. Stopping the build.${NC}"
  exit 1
fi

# Get ready for build commands
#cd ../../..
# already in lineage's root folder with sources
source build/envsetup.sh
lunch lineage_amogus-userdebug

# Clean the out folder
clean_out_folder

# Prompt for user input
choice=""
while [[ ! "$choice" =~ ^[1-2]$ ]]; do
  display_menu
  read -p "Enter your choice: " choice

  case $choice in
    1)
      run_updatepackage
      ;;
    2)
      run_otapackage
      ;;
    *)
      echo -e "${RED}Invalid choice.${NC}"
      ;;
  esac
done

# upload the build
upload_build