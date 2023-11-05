##  Existing sites in Nexus Dashboard Orchestrator

data "mso_site" "dc1_site" {
  name = var.dc1_site_name
}

data "mso_site" "aws_site" {
  name = var.aws_site_name
}