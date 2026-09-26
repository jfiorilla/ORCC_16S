#!/bin/bash
#SBATCH -c 4  # Number of Cores per Task
#SBATCH --mem=16G  # Requested Memory
#SBATCH -p cpu  # Partition
#SBATCH -t 12:00:00  # Job time limit
#SBATCH --mail-type=ALL
#SBATCH -o /scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/trimmed/slurm-trimgalore-%j.out  # %j = job ID

module load conda/latest

# Run qc with trim galore and fastqc
conda activate seqproc-env

# Define the paths and variables
FILEPATH='/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/fastq'
OUTPUT_RESULTS='/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/trimmed'
NSLOTS=4  

#create filename if not already created
ls $FILEPATH -1 | sed 's/_R.*_001.fastq.gz//' | uniq > "$OUTPUT_RESULTS/sampleids.txt"

SAMPLE_NAMES_FILE="/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/trimmed/sampleids.txt"

# Check if the file exists
if [ ! -e "$SAMPLE_NAMES_FILE" ]; then
    echo "Error: $SAMPLE_NAMES_FILE does not exist."
    exit 1
fi

# Read each line from the file and perform actions
while IFS= read -r sample_id; do
    # Form the full file names
    input_r1="$FILEPATH/${sample_id}_R1_001.fastq.gz"
    input_r2="$FILEPATH/${sample_id}_R2_001.fastq.gz"
    
    # Ensure the input files exist before running the tools
    if [ ! -e "$input_r1" ] || [ ! -e "$input_r2" ]; then
        echo "Error: Input files do not exist for sample $sample_id"
        continue
    fi

    echo "Running Trim Galore on: $sample_id"

    # Run trim_galore
    trim_galore -j "$NSLOTS" --paired $input_r1 $input_r2 --fastqc -o $OUTPUT_RESULTS


done < "$SAMPLE_NAMES_FILE"