#!/bin/bash
#SBATCH -c 24  # Number of Cores per Task
#SBATCH --mem=180G  # Requested Memory
#SBATCH -p cpu  # Partition
#SBATCH -t 24:00:00  # Job time limit
#SBATCH --mail-type=ALL
#SBATCH -o /scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/slurm-checksum-%j.out  # %j = job ID


# Navigate to directory with sequencing files 
cd /scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc

# File to store the MD5 checksums of processed files
checksum_file="md5_checksums.txt"

# Loop through all .gz files in the current directory
for file in ./*.gz; do
    if [ -f "$file" ]; then
    
        # Extract the filename
        filename=$(basename "$file") 

        # Check if the file has already been processed
        if grep -q "$filename" "$checksum_file"; then
            echo "$filename has already been processed. Skipping..."
            continue  # Skip this file and move to the next one
        fi

        # Calculate the MD5 checksum of the decompressed file
        md5sum_output=$(md5sum "$file" | awk '{print $1}')
        
        # Append the checksum and filename to the output file
        echo "$md5sum_output  $filename" >> "$checksum_file"

        # Check for the corresponding .gz.md5 file and compare checksums
        md5_file="${file}.md5"
        if [ -f "$md5_file" ]; then
            md5=$(awk '{print $1}' "$md5_file")
            echo "$md5"
            if [ "$md5sum_output" == "$md5" ]; then
                echo "$filename: Good"
            else
                echo "$filename: NOT GOOD"
            fi
        else
            echo "$filename: checksum file not found"
        fi
    fi
done