resource "google_compute_address" "hpa-k8s-ip" {
  name = "hpa-k8s-ip"
  region = "europe-west4"
}

resource "google_dns_record_set" "hpa-dns-record" {
  name         = "hpa.oktanium.im."
  type         = "A"
  ttl          = "60"
  managed_zone = "oktanium-zone"
  rrdatas      = ["${google_compute_address.hpa-k8s-ip.address}"]
}

resource "google_dns_record_set" "hpa-grafana-dns-record" {
  name         = "hpa-grafana.oktanium.im."
  type         = "A"
  ttl          = "60"
  managed_zone = "oktanium-zone"
  rrdatas      = ["${google_compute_address.hpa-k8s-ip.address}"]
}

resource "google_container_cluster" "hpa" {
  name                     = "hpa"
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
resource "google_container_node_pool" "hpa-n1s2-pool" {
  name               = "hpa"
  location           = "europe-west4-b"
  cluster            = "${google_container_cluster.hpa.name}"
  initial_node_count = "5"
  autoscaling {
    min_node_count   = "5"
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
