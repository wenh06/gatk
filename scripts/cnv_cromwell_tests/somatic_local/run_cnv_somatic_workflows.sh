#!/bin/bash -l
set -e
#cd in the directory of the script in order to use relative paths
script_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$script_path"

ln -fs /home/slee/working/gatk/scripts/cnv_wdl/cnv_common_tasks.wdl
ln -fs /home/slee/working/gatk/scripts/cnv_wdl/somatic/cnv_somatic_oncotator_workflow.wdl

WORKING_DIR=/home/slee/working
CROMWELL_JAR=${WORKING_DIR}/gatk/cromwell-36.jar

pushd .
echo "Building docker without running unit tests... ========="
cd $WORKING_DIR/gatk
HASH_TO_USE=a78411784fdb4436984ec2d8729b71810536ea73
#sudo bash build_docker.sh -e ${HASH_TO_USE} -s -u -d /mnt/4AB658D7B658C4DB/working/tmp;
echo "Docker build done =========="

popd

echo "Inserting docker image into json ========"
CNV_CROMWELL_TEST_DIR="${WORKING_DIR}/gatk/scripts/cnv_cromwell_tests/somatic_local/"
sed -r "s/__GATK_DOCKER__/broadinstitute\/gatk\:$HASH_TO_USE/g" ${CNV_CROMWELL_TEST_DIR}/cnv_somatic_panel_wes_no-gc_workflow.json >cnv_somatic_panel_wes_no-gc_workflow_mod.json
sed -r "s/__GATK_DOCKER__/broadinstitute\/gatk\:$HASH_TO_USE/g" ${CNV_CROMWELL_TEST_DIR}/cnv_somatic_panel_wgs_no-gc_workflow.json >cnv_somatic_panel_wgs_no-gc_workflow_mod.json
sed -r "s/__GATK_DOCKER__/broadinstitute\/gatk\:$HASH_TO_USE/g" ${CNV_CROMWELL_TEST_DIR}/cnv_somatic_panel_wes_do-gc_workflow.json >cnv_somatic_panel_wes_do-gc_workflow_mod.json
sed -r "s/__GATK_DOCKER__/broadinstitute\/gatk\:$HASH_TO_USE/g" ${CNV_CROMWELL_TEST_DIR}/cnv_somatic_panel_wgs_do-gc_workflow.json >cnv_somatic_panel_wgs_do-gc_workflow_mod.json
sed -r "s/__GATK_DOCKER__/broadinstitute\/gatk\:$HASH_TO_USE/g" ${CNV_CROMWELL_TEST_DIR}/cnv_somatic_pair_wes_no-gc_workflow.json >cnv_somatic_pair_wes_no-gc_workflow_mod.json
sed -r "s/__GATK_DOCKER__/broadinstitute\/gatk\:$HASH_TO_USE/g" ${CNV_CROMWELL_TEST_DIR}/cnv_somatic_pair_wgs_no-gc_workflow.json >cnv_somatic_pair_wgs_no-gc_workflow_mod.json
sed -r "s/__GATK_DOCKER__/broadinstitute\/gatk\:$HASH_TO_USE/g" ${CNV_CROMWELL_TEST_DIR}/cnv_somatic_pair_wes_do-gc_workflow.json >cnv_somatic_pair_wes_do-gc_workflow_mod.json
sed -r "s/__GATK_DOCKER__/broadinstitute\/gatk\:$HASH_TO_USE/g" ${CNV_CROMWELL_TEST_DIR}/cnv_somatic_pair_wgs_do-gc_workflow.json >cnv_somatic_pair_wgs_do-gc_workflow_mod.json
sed -r "s/__GATK_DOCKER__/broadinstitute\/gatk\:$HASH_TO_USE/g" ${CNV_CROMWELL_TEST_DIR}/cnv_somatic_pair_wgs_do-gc_tumor_only_workflow.json > cnv_somatic_pair_wgs_do-gc_tumor_only_workflow_mod.json
sed -r "s/__GATK_DOCKER__/broadinstitute\/gatk\:$HASH_TO_USE/g" ${CNV_CROMWELL_TEST_DIR}/cnv_somatic_pair_wes_no-gc_tumor_only_workflow.json > cnv_somatic_pair_wes_no-gc_tumor_only_workflow_mod.json

echo "Running ========"

# Panel WES
java -jar ${CROMWELL_JAR} run /home/slee/working/gatk/scripts/cnv_wdl/somatic/cnv_somatic_panel_workflow.wdl -i cnv_somatic_panel_wes_no-gc_workflow_mod.json
# Panel WGS
java -jar ${CROMWELL_JAR} run /home/slee/working/gatk/scripts/cnv_wdl/somatic/cnv_somatic_panel_workflow.wdl -i cnv_somatic_panel_wgs_no-gc_workflow_mod.json
# Panel WES w/ explicit GC correction
java -jar ${CROMWELL_JAR} run /home/slee/working/gatk/scripts/cnv_wdl/somatic/cnv_somatic_panel_workflow.wdl -i cnv_somatic_panel_wes_do-gc_workflow_mod.json
# Panel WGS w/ explicit GC correction
java -jar ${CROMWELL_JAR} run /home/slee/working/gatk/scripts/cnv_wdl/somatic/cnv_somatic_panel_workflow.wdl -i cnv_somatic_panel_wgs_do-gc_workflow_mod.json

# Pair WES
java -jar ${CROMWELL_JAR} run /home/slee/working/gatk/scripts/cnv_wdl/somatic/cnv_somatic_pair_workflow.wdl -i cnv_somatic_pair_wes_no-gc_workflow_mod.json
# Pair WGS
java -jar ${CROMWELL_JAR} run /home/slee/working/gatk/scripts/cnv_wdl/somatic/cnv_somatic_pair_workflow.wdl -i cnv_somatic_pair_wgs_no-gc_workflow_mod.json
# Pair WES w/ explicit GC correction
java -jar ${CROMWELL_JAR} run /home/slee/working/gatk/scripts/cnv_wdl/somatic/cnv_somatic_pair_workflow.wdl -i cnv_somatic_pair_wes_do-gc_workflow_mod.json
# Pair WGS w/ explicit GC correction
java -jar ${CROMWELL_JAR} run /home/slee/working/gatk/scripts/cnv_wdl/somatic/cnv_somatic_pair_workflow.wdl -i cnv_somatic_pair_wgs_do-gc_workflow_mod.json
# Tumor only WGS w/ explicit GC correction
java -jar ${CROMWELL_JAR} run /home/slee/working/gatk/scripts/cnv_wdl/somatic/cnv_somatic_pair_workflow.wdl -i cnv_somatic_pair_wgs_do-gc_tumor_only_workflow_mod.json
# Tumor only WES w/o explicit GC correction
java -jar ${CROMWELL_JAR} run /home/slee/working/gatk/scripts/cnv_wdl/somatic/cnv_somatic_pair_workflow.wdl -i cnv_somatic_pair_wes_no-gc_tumor_only_workflow_mod.json