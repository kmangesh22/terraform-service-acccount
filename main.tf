provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}


resource "google_service_account" "sa_for_sql" {
  account_id   = "sql-service-account"
  display_name = "A service account that only access sql"
}

resource "google_project_iam_binding" "cloudsql-sa-cloudsql-admin-role" {
    role    = "roles/cloudsql.admin"
    members = [
        "serviceAccount:${google_service_account.sa_for_sql.email}"
    ]
}


resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  allow_stopping_for_update = true
  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
   service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_for_sql.email
    scopes = ["sql-admin"]
  }
}

