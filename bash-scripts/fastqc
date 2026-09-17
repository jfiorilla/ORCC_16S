#!/bin/bash
#SBATCH -c 5  # Number of Cores per Task
#SBATCH --mem=100G  # Requested Memory
#SBATCH -p cpu  # Partition
#SBATCH -t 7:00:00  # Job time limit
#SBATCH --mail-type=ALL
#SBATCH -o /scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/slurm-fastqc-%j.out  # %j = job ID


module load conda/latest

conda activate seqproc-env

# Where to find the sequence files
FILEPATH='/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/fastq'
OUTPUT_RESULTS='/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/fastqc'

# Create filename if not already created
ls $FILEPATH -1 | sed 's/_R.*_001.fastq.gz//' | uniq > "$OUTPUT_RESULTS/sampleids.txt"

SAMPLE_NAMES_FILE="/scratch4/workspace/jade_fiorilla_student_uml_edu-rawseqorcc/fastqc/sampleids.txt"

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

    # Run fastqc
    fastqc -o $OUTPUT_RESULTS $input_r1
    fastqc -o $OUTPUT_RESULTS $input_r2


done < "$SAMPLE_NAMES_FILE"