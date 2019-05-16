resource "google_compute_address" "example-full-k8s-ip" {
  name = "example-full-k8s-ip"
  region = "europe-west4"
}

resource "google_container_cluster" "example-full" {
  name                     = "example-full"
  location                 = "europe-west4-b"
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = "1.12.6-gke.10"
  enable_legacy_abac       = false
  maintenance_policy {
    daily_maintenance_window {
      start_time = "01:00"
    }
  }
  master_auth {
    username = ""
    password = ""
    client_certificate_config {
      issue_client_certificate = false
    }
  }
}
resource "google_container_node_pool" "example-full-n1s2-pool" {
  name               = "example-full"
  location           = "europe-west4-b"
  cluster            = "${google_container_cluster.example-full.name}"
  initial_node_count = "7"
  autoscaling {
    min_node_count   = "4"
    max_node_count   = "14"
  }
  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }
  version        = "1.12.6-gke.10"
  node_config {
    disk_type    = "pd-ssd"
    disk_size_gb = "30"
    metadata {
      disable-legacy-endpoints = "true"
    }
    preemptible  = "false"
    machine_type = "n1-standard-2"
    oauth_scopes = [ "https://www.googleapis.com/auth/compute", "https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring" ]
    tags         = ["ssh-wan"]
  }
}
