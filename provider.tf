# Define the provider source

terraform {
  required_providers {
    mso = {
      source = "CiscoDevNet/mso"
    }
  }
  backend "http" {
   address = "https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/terraform/state/$TF_STATE_NAME"
  }
}

# Provider Config

provider "mso" {
  insecure = true
  platform = "nd"
}