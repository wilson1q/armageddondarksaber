terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.27.0"
    }
  }
}

provider "google" {
  credentials = "gcp-class5-e86cecf167a3.json"
  project = "gcp-class5"
  region = "us-east1"
}

resource "google_storage_bucket" "bucket" {
  name     = "darksaber-bucket-3"
  location = "US"
  force_destroy = true
}

resource "google_storage_bucket_acl" "public_read" {
  bucket = google_storage_bucket.bucket.name
  role_entity = [
    "READER:allUsers",
  ]
}

resource "google_storage_bucket_object" "object" {
  name   = "index.html"
  bucket = google_storage_bucket.bucket.name
  source = "index.html"
}

output "bucket_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.bucket.name}"
  description = "The URL of the bucket."
}