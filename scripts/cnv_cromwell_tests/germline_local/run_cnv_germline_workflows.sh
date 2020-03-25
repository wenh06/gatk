#!/bin/bash -l
set -e

#cd in the directory of the script in order to use relative paths
script_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$script_path"

ln -fs /home/slee/working/gatk/scripts/cnv_wdl/cnv_common_tasks.wdl
ln -fs /home/slee/working/gatk/scripts/cnv_wdl/germline/cnv_germline_case_workflow.wdl

WORKING_DIR=/home/slee/working
CROMWELL_JAR=${WORKING_DIR}/gatk/cromwell-47.jar

pushd .
echo "Building docker without running unit tests... ========="
cd $WORKING_DIR/gatk
HASH_TO_USE=d6a3c0fc6f436ec2456af358a88c5ab86c9d9250
#sudo bash build_docker.sh -e ${HASH_TO_USE} -s -u -d /mnt/4AB658D7B658C4DB/working/tmp;
echo "Docker build done =========="

popd

echo "Inserting docker image into json ========"
CNV_CROMWELL_TEST_DIR="${WORKING_DIR}/gatk/scripts/cnv_cromwell_tests/germline_local/"
sed -r "s/__GATK_DOCKER__/broadinstitute\/gatk\:$HASH_TO_USE/g" ${CNV_CROMWELL_TEST_DIR}/cnv_germline_cohort_workflow.json >cnv_germline_cohort_workflow_mod.json
sed -r "s/__GATK_DOCKER__/broadinstitute\/gatk\:$HASH_TO_USE/g" ${CNV_CROMWELL_TEST_DIR}/cnv_germline_case_scattered_workflow.json >cnv_germline_case_scattered_workflow_mod.json
echo "Running ========"

# Cohort WES w/ explicit GC correction
java -jar ${CROMWELL_JAR} run /home/slee/working/gatk/scripts/cnv_wdl/germline/cnv_germline_cohort_workflow.wdl -i cnv_germline_cohort_workflow_mod.json

# Scattered case WES w/ explicit GC correction
java -jar ${CROMWELL_JAR} run /home/slee/working/gatk/scripts/cnv_wdl/germline/cnv_germline_case_scattered_workflow.wdl -i cnv_germline_case_scattered_workflow_mod.json
