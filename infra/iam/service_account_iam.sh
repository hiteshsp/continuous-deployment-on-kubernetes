#!/bin/bash
export GOOGLE_CLOUD_PROJECT=concise-flame-118023

gcloud iam roles create kubernetesIAMRole --project=$GOOGLE_CLOUD_PROJECT \
  --file=iam/kubernetes-iam-role.yaml

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member='serviceAccount:jenkins-sa@concise-flame-118023.iam.gserviceaccount.com' \
  --role="projects/$GOOGLE_CLOUD_PROJECT/roles/kubernetesIAMRole"