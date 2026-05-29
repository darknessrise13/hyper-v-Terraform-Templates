terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region = "us-east-1"
    endpoints = {
      s3 = "" #S3 Endpoint, add :port if required.
    }
    use_path_style              = true
    encrypt                     = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
  }

  required_providers {
    hyperv = {
      source  = "bafbi/hyperv"
      version = ">=1.5.4"
    }
  }
}
