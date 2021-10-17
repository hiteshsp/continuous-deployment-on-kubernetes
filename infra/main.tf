provider "google" {
  project = var.project
  region  = "asia-east1"
}

module "gcp-gke" {
  source = "git::https://github.com/hiteshsp/terraform-gcp-modules.git//kubernetes-engine"

  project         = var.project
  location        = var.location
  service_account = var.service_account

  cluster_name       = var.cluster_name
  description        = var.description
  oauth_scopes       = var.oauth_scopes
  initial_node_count = var.initial_node_count
  min_master_version = var.min_master_version

  nodepool_name         = var.nodepool_name
  node_count            = var.node_count
  nodepool_machine_type = var.nodepool_machine_type
  is_node_preemptibile  = var.is_node_preemptibile
}