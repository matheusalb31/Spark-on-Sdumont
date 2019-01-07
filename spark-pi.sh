#!/bin/sh
#SBATCH --nodes=30
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH -p cpu
#SBATCH -J Spark-Pi
#SBATCH --output=sparkjob-%j.out

#Load all necessary modules.
source /scratch/app/modulos/intel-psxe-2016.2.062.sh
module load openmpi/1.10_intel
module load R/3.3.1_intel
module load java/jdk-8u102
module load spark

export SPARK_IDENT_STRING=$SLURM_JOBID

#Path to user home directory.
USER_HOME=/scratch/ebiodiv/matheus.albuquerque/

#Creates all necessary directories.
mkdir ${USER_HOME}sparkLogs/
mkdir ${USER_HOME}sparkWorker/
mkdir ${USER_HOME}sparkLocal/

#Redirects the directories.
export SPARK_HOME=/scratch/app/spark/2.3.1+hadoop2.7/
export SPARK_LOG_DIR=${USER_HOME}sparkLogs/
export SPARK_WORKER_DIR=${USER_HOME}sparkWorker/
export SPARK_LOCAL_DIRS=${USER_HOME}sparkLocal/

#Show the list of nodes allocated for the job.
echo NODE-LIST
echo $SLURM_JOB_NODELIST
echo

#Starts the Master.
${SPARK_HOME}sbin/start-master.sh
echo Starting Master...
echo
sleep 60 #Time to start the Master.

#Master Address.
MASTER_URL=$(grep -Po '(?=spark://).*' ${SPARK_LOG_DIR}spark-${SPARK_IDENT_STRING}-org.*master*.out)
echo MASTER_URL
echo ${MASTER_URL}
echo

#Spark Configuration.
export SPARK_WORKER_CORES=${SLURM_CPUS_PER_TASK:-1}
export SPARK_MEM=$(( ${SLURM_MEM_PER_CPU:-4096} * ${SLURM_CPUS_PER_TASK:-1} ))M
export SPARK_DAEMON_MEMORY=$SPARK_MEM
export SPARK_WORKER_MEMORY=$SPARK_MEM
export SPARK_EXECUTOR_MEMORY=$SPARK_MEM
export SPARK_NO_DAEMONIZE=1

#Starts the Workers.
srun --output=${SPARK_LOG_DIR}spark-%j-workers.out --label ${SPARK_HOME}sbin/start-slave.sh ${MASTER_URL} &

#Job submission.
${SPARK_HOME}bin/spark-submit \
        --master ${MASTER_URL} \
        --total-executor-cores $((SLURM_NTASKS * SLURM_CPUS_PER_TASK)) \
	--class org.apache.spark.examples.SparkPi \
        ${SPARK_HOME}examples/jars/spark-examples_2.11-2.3.1.jar \
        1000000

#Cancels job when execution finishes.
scancel ${SLURM_JOBID}.0

#Suggested time to consult Spark web UI.
sleep 120

#Stops the Master and all Workers.
$SPARK_HOME/sbin/stop-master.sh

#Creates a directory to store all the files that were needed for Spark.
mkdir sparkjob-${SPARK_IDENT_STRING}
mv sparkjob-${SPARK_IDENT_STRING}.out ${USER_HOME}sparkjob-${SPARK_IDENT_STRING}
mv ${SPARK_WORKER_DIR} ${USER_HOME}sparkjob-${SPARK_IDENT_STRING}/Worker/
mv ${SPARK_LOG_DIR} ${USER_HOME}sparkjob-${SPARK_IDENT_STRING}/Log/
mv ${SPARK_LOCAL_DIRS} ${USER_HOME}sparkjob-${SPARK_IDENT_STRING}/Local/
