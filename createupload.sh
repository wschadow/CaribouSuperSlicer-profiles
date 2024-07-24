# script.sh
# This script processes .ini files and directories in the current directory to create an output structure, modify file contents, copy directory contents, handle .idx files, and zip them.

# Create the output directories if they don't exist
mkdir -p output/uploads/vendors
mkdir -p output/profiles
mkdir -p output/uploads/idx

# Loop through each .ini file in the current directory
for file in *.ini; do
  # Extract the base name (without .ini extension)
  name="${file%.ini}"
  
  # Create a temporary file to store the modified content
  temp_file="temp_$file"
  
  # Modify the config_version to 2.0.0 and replace the config_update_url with the specified URL
  sed 's/^config_version = .*/config_version = 2.0.0/' "$file" | \
  sed "s|^config_update_url = .*|config_update_url = https://caribou3d.com/CaribouSlicerV2/repository/vendors/$name|" | \
  sed '/^#https:\/\/files\.prusa3d\.com\/wp-content\/uploads\/repository\/PrusaSlicer/d' | \
  sed 's|^# changelog_url = https://.*|changelog_url =|' | \
  sed 's|^changelog_url = https://.*|changelog_url =|' > "$temp_file"
  
  # Create the respective subdirectory inside output/uploads/vendors
  mkdir -p "output/uploads/vendors/$name"
  
  # Copy the modified .ini file to the subdirectory with the new name 2.0.0.ini
  cp "$temp_file" "output/uploads/vendors/$name/2.0.0.ini"
  
  # Copy the modified .ini file to the output/profiles directory with the new name $name.ini
  cp "$temp_file" "output/profiles/$name.ini"
  
  # Remove the temporary file
  rm "$temp_file"
done

# Loop through each directory in the current directory and copy its contents
for dir in */; do
  # Remove trailing slash from directory name
  dir_name="${dir%/}"
  
  # Skip the output directory itself
  if [[ "$dir_name" != "output" ]]; then
    # Copy the content of the directory to the respective subdirectory inside output/uploads/vendors
    mkdir -p "output/uploads/vendors/$dir_name"
    cp -r "$dir_name/." "output/uploads/vendors/$dir_name/"

    # Copy the content of the directory to the respective subdirectory inside output/profiles
    mkdir -p "output/profiles/$dir_name"
    cp -r "$dir_name/." "output/profiles/$dir_name/"
  fi
done

# Loop through each .idx file in the current directory
for idx_file in *.idx; do
  # Copy the idx file to the output/uploads/idx directory
  cp "$idx_file" "output/uploads/idx/"
  
  # Add specific lines to the beginning of the copied idx file
  sed -i '1i min_slic3r_version = 2.7.0\n2.0.0 Updated for CaribouSlicerV2 2.7.0' "output/uploads/idx/$idx_file"
  
  # Copy the modified idx file to the output/profiles directory
  cp "output/uploads/idx/$idx_file" "output/profiles/$idx_file"
done

# Go to the idx directory
cd output/uploads/idx

# Create the zip file vendor_indices.zip containing all .idx files
zip vendor_indices.zip *.idx

# Move the vendor_indices.zip one level up
mv vendor_indices.zip ..

# Go back to the main directory
cd ../../..

# Delete the idx directory
rm -r output/uploads/idx
