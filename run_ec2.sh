#!/bin/bash

error(){
    echo ${1}
    exit 1
}

[ -n "${KS_AL_PROFILE}" ] || error "KS_AL_PROFILE is empty"
[ -n "${KS_AL_SUBNET}" ] || error "KS_AL_SUBNET is empty"
[ -n "${KS_AL_TYPE}" ] || error "KS_AL_TYPE is empty"
[ -n "${KS_AL_ARM}" ] || error "KS_AL_ARM is empty"
[ -n "${KS_AL_DISK}" ] || error "KS_AL_DISK is empty"
[ -n "${KS_AL_KEY}" ] || error "KS_AL_KEY is empty"

if [ "${KS_AL_ARM}" == "true" ]; then
    # ARM
    AMI="ami-035e7f804dad9c65b"
else
    # x86
    AMI="ami-052652af12b58691f"
fi

BDM=$(
cat <<- EOF
[
    {
        "DeviceName": "/dev/xvda",
        "VirtualName": "string",
        "Ebs": {
            "DeleteOnTermination": true,
            "VolumeSize": ${KS_AL_DISK},
            "VolumeType": "gp2",
            "Encrypted": true
        }
    }
]
EOF
)

aws --profile ${KS_AL_PROFILE} \
    ec2 run-instances \
    --subnet-id "${KS_AL_SUBNET}" \
    --security-group-ids "${KS_AL_SEC}" \
    --instance-type "${KS_AL_TYPE}" \
    --image-id "${AMI}" \
    --block-device-mappings "${BDM}" \
    --ebs-optimized \
    --key-name "${KS_AL_KEY}" \
    --user-data "file://user-data.sh" \
    > result.json
