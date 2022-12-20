#!/bin/bash

COUNT_NODES=6
COUNT_LB=2
COUNT_STOR=1

function tf_destroy
{
    terraform destroy -auto-approve
}

function tf_apply
{
    terraform apply -auto-approve
}

function virsh_shutdown
{
    for count in `seq ${COUNT_NODES}`
    do
        virsh shutdown kadmlabnode${count}
    done
    for count in `seq ${COUNT_STOR}`
    do
        virsh shutdown kadmlabstor${count}
    done    
    for count in `seq ${COUNT_LB}`
    do
        virsh shutdown kadmlablb${count}
    done
}

function virsh_start
{
    for count in `seq ${COUNT_LB}`
    do
        virsh start kadmlablb${count}
    done
    for count in `seq ${COUNT_STOR}`
    do
        virsh start kadmlabstor${count}
    done    
    for count in `seq ${COUNT_NODES}`
    do
        virsh start kadmlabnode${count}
    done
}

function virsh_snapshot
{
    TIMESTAMP=`date "+%Y%m%d-%H%M%S"`
    for count in `seq ${COUNT_LB}`
    do
        virsh snapshot-create-as kadmlablb${count} --name "make snapshot ${TIMESTAMP}"
    done
    for count in `seq ${COUNT_STOR}`
    do
        virsh snapshot-create-as kadmlabstor${count} --name "make snapshot ${TIMESTAMP}"
    done    
    for count in `seq ${COUNT_NODES}`
    do
        virsh snapshot-create-as kadmlabnode${count} --name "make snapshot ${TIMESTAMP}"
    done
}

function virsh_revert
{
    for count in `seq ${COUNT_LB}`
    do
        virsh snapshot-revert kadmlablb${count} --current --running
    done
    for count in `seq ${COUNT_STOR}`
    do
        virsh snapshot-revert kadmlabstor${count} --current --running
    done    
    for count in `seq ${COUNT_NODES}`
    do
        virsh snapshot-revert kadmlabnode${count} --current --running
    done
}

function ans_wait
{
    ansible kadmlab -m wait_for_connection -a "timeout=180 sleep=10"
}

function kadm_rebuild
{
    tf_destroy
    tf_apply
    ans_wait
}

function kadm_snapshot
{
    virsh_shutdown
    echo "Waiting for shutdown to complete..."
    sleep 60
    virsh_snapshot
    virsh_start
    ans_wait
}

function kadm_revert
{
    virsh_shutdown
    virsh_revert
    ans_wait
}

function kadm_reset
{
    kadm_rebuild
    ansible-playbook kadmlablb.yaml
    ansible-playbook kadmlabstor.yaml
    kadm_snapshot
    ansible-playbook kadmlabnode.yaml
}



# main

if [ "$#" != 1 ]
then
    echo "Usage: make_scripts.sh <action>"
    exit 1
fi

ACTION="$1"

if [ "${ACTION}" == "rebuild" ]
then
    kadm_rebuild
    exit 0
elif [ "${ACTION}" == "snapshot" ]
then
    kadm_snapshot
    exit 0
elif [ "${ACTION}" == "revert" ]
then
    kadm_revert
    exit 0
elif [ "${ACTION}" == "reset" ]
then
    kadm_reset
    exit 0
else
    echo "Invalid action \"${ACTION}\"."
    exit 1
fi
