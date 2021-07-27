terraform {
  backend "gcs" {
    bucket  = "gcs-tf-state-prod"
    prefix  = "terraform/state"
  }
}

provider "google" { 
  project = "groovy-legacy-312114"
  region  = "us-central1"
  zone    = "us-central1-c"
}

