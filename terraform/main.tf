terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

variable "project_id" {
  type        = string
  description = "Google Cloud project ID"
}

variable "cf_secret_token" {
  type        = string
  description = "Clouflare authorization token"
  sensitive   = true
}

provider "google" {
  project = var.project_id
  region  = "europe-central2"
}

# cv bucket
locals {
  bucket_name = "miloszgilga-cv"
}

resource "google_storage_bucket" "cv_bucket" {
  name                        = local.bucket_name
  location                    = "europe-central2"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

resource "google_service_account" "github_actions_sa" {
  account_id   = "github-cv-deployer"
  display_name = "GitHub Actions CV Deployer"
}

resource "google_service_account_key" "github_key" {
  service_account_id = google_service_account.github_actions_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_storage_bucket_iam_member" "sa_bucket_access" {
  bucket = google_storage_bucket.cv_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# serverless processing function
resource "google_storage_bucket" "function_source_bucket" {
  name     = "cv-miloszgilga"
  location = "europe-central2"
}

data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../serverless-protector"
  output_path = "${path.module}/serverless-protector.zip"
}

resource "google_storage_bucket_object" "function_archive" {
  name   = "source-${data.archive_file.function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_source_bucket.name
  source = data.archive_file.function_zip.output_path
}

resource "google_project_service" "cf_api" {
  project = var.project_id
  service = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cb_api" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "sa_cloud_run_viewer" {
  project = var.project_id
  role    = "roles/run.viewer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "sa_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "sa_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "sa_artifact_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_project_iam_member" "sa_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_cloudfunctions2_function" "serve_cv_function" {
  depends_on = [
    google_project_service.cf_api,
    google_project_service.cb_api
  ]

  name        = "serve-cv"
  location    = "europe-central2"

  build_config {
    runtime     = "nodejs20"
    entry_point = "serveCV"
    service_account = google_service_account.github_actions_sa.id
    source {
      storage_source {
        bucket = google_storage_bucket.function_source_bucket.name
        object = google_storage_bucket_object.function_archive.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    service_account_email = google_service_account.github_actions_sa.email
    environment_variables = {
      CF_SECRET_TOKEN = var.cf_secret_token
      CV_BUCKET_NAME  = local.bucket_name
    }
  }
}

resource "google_cloud_run_service_iam_member" "public_invoker" {
  location = google_cloudfunctions2_function.serve_cv_function.location
  service  = google_cloudfunctions2_function.serve_cv_function.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "local_file" "github_key_file" {
  content  = base64decode(google_service_account_key.github_key.private_key)
  filename = "${path.module}/../secrets/gcp-key.json"
}

output "cloud_function_url" {
  value = google_cloudfunctions2_function.serve_cv_function.service_config[0].uri
}
