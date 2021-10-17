#!/bin/bash

TF_VARS=$1

terraform fmt -recursive
terraform validate
terraform init
terraform plan --var-file=$TF_VARS
terraform apply --var-file=$TF_VARS --auto-approve
