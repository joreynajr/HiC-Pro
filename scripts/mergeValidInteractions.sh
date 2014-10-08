#!/bin/bash
## Nicolas Servant
## mergeValidInteraction.sh

dir=$(dirname $0)

. $dir/hic.inc.sh

################### Initialize ###################

while [ $# -gt 0 ]
do
    case "$1" in
	(-c) ncrna_conf=$2; shift;;
	(-h) usage;;
	(--) shift; break;;
	(-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
	(*)  break;;
    esac
    shift
done

################### Read the config file ###################

read_config $ncrna_conf

################### Define Variables ###################

DATA_DIR=${MAPC_OUTPUT}/data/

################### Combine Bowtie mapping ###################

for RES_FILE_NAME in ${DATA_DIR}/*
do
    RES_FILE_NAME=$(basename $RES_FILE_NAME)
    echo $RES_FILE_NAME
    if [ -d ${DATA_DIR}/${RES_FILE_NAME} ]; then
	if [ ${RMDUP} != 1 ]
	then
	    cat ${DATA_DIR}/${RES_FILE_NAME}/*.validPairs > ${DATA_DIR}/${RES_FILE_NAME}/${RES_FILE_NAME}_allValidPairs
	else
	    echo "Remove duplicates ..."
	    cat ${DATA_DIR}/${RES_FILE_NAME}/*.validPairs | sort -k2,2V -k3,3n -k5,5V -k6,6n | awk -F"\t" 'BEGIN{c1=0;c2=0;s1=0;s2=0}(c1!=$2 || c2!=$5 || s1!=$3 || s2!=$6){print;c1=$2;c2=$5;s1=$3;s2=$6}' > ${DATA_DIR}/${RES_FILE_NAME}/${RES_FILE_NAME}_allValidPairs
	fi
    fi
    wait
done