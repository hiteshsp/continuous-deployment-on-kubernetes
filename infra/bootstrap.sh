#!/bin/bash
# Copyright 2021 hitesh sp
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
region=$1
#######################################
# Run terraform tasks to create infra in GCP.
#
# OUTPUTS:
#   Create Infra in GCP with help of Terraform
# RETURN:
#   0 if print succeeds, non-zero on error.
#######################################
setup_infra () {

    ## Destroy Infra before create. We can omit it.
    #terraform destroy --var-file=tfvars/gke.tfvars --auto-approve

    bash terraform_deploy.sh tfvars/gke.tfvars
    cluster_name=$(terraform output -raw cluster_name)
    cluster_region=$region
    gcloud container clusters get-credentials --region=$cluster_region $cluster_name 

}
#######################################
# Installs CLI Clients such as Kubectl, Helm etc.
# 
# Setup kubectl and helm
# RETURN:
#   0 if print succeeds, non-zero on error.
#######################################
setup_clients () {

    ## Installing kubectl
    if [ ! -f "kubectl" ];
    then 
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
    fi

    if [ ! -f "kubectl.sha256" ];
    then
      curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"  
    fi

    echo "$(<kubectl.sha256)  kubectl" | shasum -a 256 --check
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    sudo chown root: /usr/local/bin/kubectl
    kubectl version --client
    
    ## Installing Helm
    if [! -f "get_helm.sh" ];
    then
      curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
      chmod 700 get_helm.sh
      sudo ./get_helm.sh
    fi
}

#######################################
# Setups up Jenkins installation and configuration on GKE
# 
# OUTPUTS:
#   Installs Jenkins on GKE
# RETURN:
#   0 if print succeeds, non-zero on error.
#######################################
setup_jenkins() {

    ## Install Jenkins
    kubectl create clusterrolebinding jenkins-deploy --clusterrole=cluster-admin --serviceaccount=default:cd-jenkins
    cd .. && \
    helm repo add jenkinsci https://charts.jenkins.io && \
         helm repo update && \
         helm install cd-jenkins -f jenkins/values.yaml jenkinsci/jenkins --wait
}

## Setup GCP Auth
bash credentials/credentials.sh
bash iam/service_account_iam.sh

setup_clients
setup_infra
setup_jenkins

