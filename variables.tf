# All credentials and sensitive information are declared in a override.tf or terraform.tfvars file.

# NDO credentials, if not using GitLab

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

variable "aws_account_id" {
  type    = string
  default = "account"
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

variable "tenant_name" {
  type = string
  default = "hybrid-cloud"
}

# Schema & Template

variable "schema_name" {
  type    = string
  default = "distributed-app-with-aws-us-east-1"
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

## Stretched Template - DC1 & AWS

variable "vrf_name" {
  type    = string
  default = "VRF1"
}

variable "filter_dc1_aws" {
  type    = string
  default = "web-to-db"
}

variable "contract_dc1_aws" {
  type    = string
  default = "web-to-db"
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

## DC1 Variables

variable "bd_db" {
  type    = string
  default = "BD-DB-1"
}

variable "bd_db_subnet" {
  type    = string
  default = "60.1.1.1/24"
}

variable "dc1_ap_name" {
  type    = string
  default = "myapp-1"
}

variable "db_epg_name" {
  type    = string
  default = "Database"
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
  default = "WEB"
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
  default = "INTERNET"
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

