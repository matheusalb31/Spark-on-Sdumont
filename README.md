# Spark on Sdumont
This script exemplifies a submission of a job using the Apache Spark framework in the Santos Dumont supercomputer.
The script was tested using Spark 2.3.1.

## Description
The code to be processed, in particular, is a standard example of the Spark library, the approximate PI calculation.

## Configuration
The script was configured to run in the CPU queue, using 30 nodes, performing one task per node using 24 CPUs per task.
By default, Spark will start 1 Master and 30 Workers.

## Details and Output Files

Details of the execution can be found in the web interface of the Master node.
To know exactly the host and port, run this command

```
$ grep -Po '(?=host\s).*' /scratch/PROJECT-NAME/USER-NAME/sparkLogs/spark-JOB_ID-org.*master*.out
```

After that, using the next command, the Master UI will be open.
```
$ firefox <HOST>:WEB_UI_PORT

```

Finally, a directory will be created in the user's / home, containing the output file and also  files that were used by Spark during execution.

## Getting Started
At the beginning of the script, the required settings for the environment must be configured.
For more information, see [Sdumont Manual](https://sdumont.lncc.br/support_manual.php?pg=support#).

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

Specify the correct path to the user home directory on Scratch.

```
#Path to user home directory.
USER_HOME=/scratch/PROJECT-NAME/USER-NAME/
```

Configure the path to the code you want to run.
```
#Job submission.
${SPARK_HOME}bin/spark-submit \
        --master ${MASTER_URL} \
        --total-executor-cores $((SLURM_NTASKS * SLURM_CPUS_PER_TASK)) \
        /scratch/PATH-TO-THE-EXECUTABLE/
```

The time to consult the web interface before the Master stops is also configured according to your need.
```
#Suggested time to consult Spark web UI.
sleep TIME-IN-SECONDS
```
