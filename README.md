# Spark on Sdumont
This script exemplifies a submission of a job using the Apache Spark framework in the Santos Dumont supercomputer.
The script was tested using Spark 2.3.1.

## Description
The code to be processed, in particular, is a standard example of the Spark library, the approximate PI calculation.

## Configuration
The script was configured to run in the CPU queue, using 30 nodes, performing one task per node using 24 CPUs per task.
By default, Spark will start 1 Master and 50 Workers.

## Details and Output Files

## Getting Started
At the beginning of the script, the required settings for the environment must be configured.
For more information, see [Sdumont Manual](https://sdumont.lncc.br/support_manual.php?pg=support#6.1).

```
#!/bin/sh
#SBATCH --nodes=N
#SBATCH --ntasks-per-node=TPN
#SBATCH --cpus-per-task=CPT
#SBATCH -p QUEUE
#SBATCH -J JOB
#SBATCH --output=sparkjob-%j.out

#Load all necessary modules.
source /scratch/app/modulos/intel-psxe-2016.2.062.sh
module load MODULE
```

Note: The required modules may vary depending on the application.
