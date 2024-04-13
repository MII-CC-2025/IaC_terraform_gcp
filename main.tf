terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.23.0"
    }
  }
}

provider "google" {
  # Configuration options

  project = "cc-2024"
  region  = "us-central1"
  zone    = "us-central1-a"
}