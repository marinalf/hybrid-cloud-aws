# All credentials and sensitive information are declared in a override.tf or terraform.tfvars file.

# NDO Credentials

variable "ndo" {
  type = map(any)
  default = {
    username = "username"
    password = "password"
    url      = "url"
    domain   = "local"
  }
}

# AWS credentials

variable "aws" {
  type = object({
    aws_account_id = string
  })
  default = {
    aws_account_id = "account"
  }
}

# Site names as seen on Nexus Dashboard

variable "aws_site_name" {
  type    = string
  default = "CNC-AWS"
}

variable "dc1_site_name" {
  type    = string
  default = "DC1"
}

## Template Level

# Tenant

variable "tenant" {
  type = map(any)
  default = {
    tenant_name  = "hybrid-cloud"
    display_name = "hybrid-cloud"
    description  = "This is a demo tenant created by Terraform"
  }
}

# Schema & Template

variable "schema_name" {
  type    = string
  default = "distributed-app-with-aws"
}

variable "template1" {
  type    = string
  default = "template-dc1-aws"
}

variable "template2" {
  type    = string
  default = "template-dc1"
}

variable "template3" {
  type    = string
  default = "template-aws"
}

# Stretched VRF in AWS and DC1

variable "vrf_name" {
  type    = string
  default = "vrf1"
}

## AWS Site Level - Networking

# User VPC in AWS

variable "aws_region_name" {
  type    = string
  default = "us-east-1"
}

variable "tgw_name" {
  type    = string
  default = "hub1" # This is the TGW/Hub Network name configured during initial CNC setup
}

variable "aws_cidr_ip" {
  type    = string
  default = "50.1.0.0/16"
}

variable "aws_tgw_subnets" {
  type = map(object({
    name = string
    ip   = string
    zone = string
  }))
  default = {
    tgw-a-subnet = {
      name  = "tgw-a-subnet"
      ip    = "50.1.100.0/24"
      zone  = "us-east-1a"
      usage = "gateway"
    },
    tgw-b-subnet = {
      name  = "tgw-b-subnet"
      ip    = "50.1.200.0/24"
      zone  = "us-east-1b"
      usage = "gateway"
    }
  }
}

variable "aws_user_subnets" {
  type = map(object({
    name = string
    ip   = string
    zone = string
  }))
  default = {
    web-subnet = {
      name  = "web-subnet"
      ip    = "50.1.1.0/24"
      zone  = "us-east-1a"
      usage = "user"
    },
    db-subnet = {
      name  = "db-subnet"
      ip    = "50.1.2.0/24"
      zone  = "us-east-1b"
      usage = "user"
    }
  }
}

## Stretched Template Level - Policies

variable "filter_dc1_aws" {
  type    = string
  default = "all-traffic"
}

variable "contract_dc1_aws" {
  type    = string
  default = "web-to-db"
}


## DC1 Variables

variable "bd_db" {
  type    = string
  default = "bd-db"
}

variable "bd_db_subnet" {
  type    = string
  default = "60.1.1.1/24"
}

variable "dc1_ap_name" {
  type    = string
  default = "myapp"
}

variable "db_epg_name" {
  type    = string
  default = "database"
}

variable "vmm_dc1" {
  type    = string
  default = "DC1-ACME"
}

## AWS Variables

variable "aws_ap_name" {
  type    = string
  default = "myapp"
}

variable "web_epg_name" {
  type    = string
  default = "web"
}

variable "epg_selector_key" {
  type    = string
  default = "Custom:epg"
}

variable "epg_selector_value" {
  type    = string
  default = "web"
}

variable "ext_epg" {
  type    = string
  default = "internet"
}

variable "ext_epg_selector" {
  type    = string
  default = "internet"
}

variable "ext_epg_selector_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "filter_name" {
  type    = string
  default = "all-traffic"
}

variable "internet_contract_name" {
  type    = string
  default = "internet-access"
}

variable "bd_name" {
  type    = string
  default = "web"
}

