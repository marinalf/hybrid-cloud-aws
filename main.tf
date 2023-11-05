locals {
  stretched_template_name = var.template1
  dc1_template_name       = "${lower(var.template2)}-only"
  aws_template_name       = "${lower(var.template3)}-only"
  templates_redeploy      = false
}

# Define Tenant

resource "mso_tenant" "tenant" {
  name         = var.tenant.tenant_name
  display_name = var.tenant.display_name
  description  = var.tenant.description
  site_associations {
    site_id = data.mso_site.dc1_site.id
  }
  site_associations {
    site_id                = data.mso_site.aws_site.id
    vendor                 = "aws"
    aws_account_id         = var.aws.aws_account_id
    is_aws_account_trusted = true
  }
}

# Define schema and template

resource "mso_schema" "schema1" {
  name = var.schema_name
  template {
    name         = var.template1
    display_name = var.template1
    tenant_id    = mso_tenant.tenant.id
  }
  template {
    name         = local.dc1_template_name
    display_name = local.dc1_template_name
    tenant_id    = mso_tenant.tenant.id
  }
  template {
    name         = local.aws_template_name
    display_name = local.aws_template_name
    tenant_id    = mso_tenant.tenant.id
  }
}

# Associate schema and template with cloud site

resource "mso_schema_site" "dc1_template1" {
  schema_id           = mso_schema.schema1.id
  template_name       = local.stretched_template_name
  site_id             = data.mso_site.dc1_site.id
  undeploy_on_destroy = true
}

resource "mso_schema_site" "dc1_template2" {
  schema_id           = mso_schema.schema1.id
  template_name       = local.dc1_template_name
  site_id             = data.mso_site.dc1_site.id
  undeploy_on_destroy = true
}

resource "mso_schema_site" "aws_template1" {
  schema_id           = mso_schema.schema1.id
  template_name       = local.stretched_template_name
  site_id             = data.mso_site.aws_site.id
  undeploy_on_destroy = true
}

resource "mso_schema_site" "aws_template3" {
  schema_id           = mso_schema.schema1.id
  template_name       = local.aws_template_name
  site_id             = data.mso_site.aws_site.id
  undeploy_on_destroy = true
}

### Stretched Template Level - Networking ###

# Create VRF to be stretched between AWS & DC1

resource "mso_schema_template_vrf" "vrf1" {
  schema_id              = mso_schema.schema1.id
  template               = local.stretched_template_name
  name                   = var.vrf_name
  display_name           = var.vrf_name
  ip_data_plane_learning = "enabled"
}

### Site Level for AWS only

## Define Region, CIDR and Subnets in AWS

resource "mso_schema_site_vrf_region" "aws_region" {
  schema_id          = mso_schema.schema1.id
  template_name      = local.stretched_template_name
  site_id            = data.mso_site.aws_site.id
  vrf_name           = mso_schema_template_vrf.vrf1.name
  region_name        = var.aws_region_name
  vpn_gateway        = false
  hub_network_enable = true # This enables attachment to Infra TGW
  hub_network = {
    name        = var.tgw_name
    tenant_name = "infra"
  }
  cidr {
    cidr_ip = var.aws_cidr_ip
    primary = true

    dynamic "subnet" {
      for_each = var.aws_tgw_subnets
      content {
        ip    = subnet.value.ip
        name  = subnet.value.name
        zone  = subnet.value.zone
        usage = "gateway"
      }
    }
    dynamic "subnet" {
      for_each = var.aws_user_subnets
      content {
        ip    = subnet.value.ip
        name  = subnet.value.name
        zone  = subnet.value.zone
        usage = "user"
      }
    }
  }
}

### Stretched Template Level - Policies ###

# Create Filter and Contract between DC1 and AWS 

resource "mso_schema_template_filter_entry" "dc1_aws" {
  schema_id          = mso_schema.schema1.id
  template_name      = local.stretched_template_name
  name               = var.filter_dc1_aws
  display_name       = var.filter_dc1_aws
  entry_name         = "Any"
  entry_display_name = "Any"
}

resource "mso_schema_template_contract" "dc1_aws" {
  schema_id     = mso_schema.schema1.id
  template_name = local.stretched_template_name
  contract_name = var.contract_dc1_aws
  display_name  = var.contract_dc1_aws
  scope         = "context"
  directives    = ["none"]
  filter_relationship {
    filter_name = mso_schema_template_filter_entry.dc1_aws.name
  }
}

### DC1 Template Level - Networking & Policies ###

resource "mso_schema_template_bd" "bd_db" {
  schema_id              = mso_schema.schema1.id
  template_name          = local.dc1_template_name
  name                   = var.bd_db
  display_name           = var.bd_db
  vrf_name               = mso_schema_template_vrf.vrf1.name
  vrf_template_name      = mso_schema_template_vrf.vrf1.template
  layer2_stretch         = true
  unicast_routing        = true
  intersite_bum_traffic  = true
  layer2_unknown_unicast = "proxy"
}

resource "mso_schema_template_bd_subnet" "bd_db_subnet" {
  schema_id          = mso_schema.schema1.id
  template_name      = local.dc1_template_name
  bd_name            = mso_schema_template_bd.bd_db.name
  ip                 = var.bd_db_subnet
  scope              = "public"
  no_default_gateway = false
  shared             = false
}

# Create Application Profile

resource "mso_schema_template_anp" "dc1_ap" {
  schema_id    = mso_schema.schema1.id
  template     = local.dc1_template_name
  name         = var.dc1_ap_name
  display_name = var.dc1_ap_name
}

# Create Database EPG

resource "mso_schema_template_anp_epg" "db_epg" {
  schema_id         = mso_schema.schema1.id
  template_name     = local.dc1_template_name
  anp_name          = mso_schema_template_anp.dc1_ap.name
  name              = var.db_epg_name
  display_name      = var.db_epg_name
  bd_name           = mso_schema_template_bd.bd_db.name
  vrf_name          = mso_schema_template_vrf.vrf1.name
  vrf_template_name = mso_schema_template_vrf.vrf1.template
}

resource "mso_schema_site_anp_epg_domain" "db_epg_vmm" {
  schema_id            = mso_schema.schema1.id
  template_name        = local.dc1_template_name
  site_id              = data.mso_site.dc1_site.id
  anp_name             = mso_schema_template_anp.dc1_ap.name
  epg_name             = mso_schema_template_anp_epg.db_epg.name
  domain_dn            = "uni/vmmp-VMware/dom-${var.vmm_dc1}"
  deploy_immediacy     = "immediate"
  resolution_immediacy = "immediate"
}

resource "mso_schema_template_anp_epg_contract" "web_to_db" {
  schema_id              = mso_schema.schema1.id
  template_name          = local.dc1_template_name
  anp_name               = mso_schema_template_anp.dc1_ap.name
  epg_name               = mso_schema_template_anp_epg.db_epg.name
  contract_name          = mso_schema_template_contract.dc1_aws.contract_name
  contract_template_name = mso_schema_template_contract.dc1_aws.template_name
  relationship_type      = "provider"
}

### AWS Template Level - Networking & Policies ###

# Create Application Profile

resource "mso_schema_template_anp" "aws_ap" {
  schema_id    = mso_schema.schema1.id
  template     = local.aws_template_name
  name         = var.aws_ap_name
  display_name = var.aws_ap_name
}

# Create Web EPG

resource "mso_schema_template_anp_epg" "web_epg" {
  schema_id         = mso_schema.schema1.id
  template_name     = local.aws_template_name
  anp_name          = mso_schema_template_anp.aws_ap.name
  name              = var.web_epg_name
  display_name      = var.web_epg_name
  vrf_name          = mso_schema_template_vrf.vrf1.name
  vrf_template_name = mso_schema_template_vrf.vrf1.template
}

resource "mso_schema_site_anp_epg_selector" "epgSel1" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.aws_site.id
  template_name = local.aws_template_name
  anp_name      = mso_schema_template_anp.aws_ap.name
  epg_name      = mso_schema_template_anp_epg.web_epg.name
  name          = "epgSel1"
  expressions {
    key      = var.epg_selector_key
    operator = "equals"
    value    = var.epg_selector_value
  }
}

# Create External EPG to represent Internet

resource "mso_schema_template_external_epg" "external_epg" {
  schema_id         = mso_schema.schema1.id
  template_name     = local.aws_template_name
  external_epg_name = var.ext_epg
  external_epg_type = "cloud"
  display_name      = var.ext_epg
  vrf_name          = mso_schema_template_vrf.vrf1.name
  vrf_template_name = mso_schema_template_vrf.vrf1.template
  anp_name          = mso_schema_template_anp.aws_ap.name
  selector_name     = var.ext_epg_selector
  selector_ip       = var.ext_epg_selector_ip
}

## Create Filter and Contract to allow Internet access to Web EPG

resource "mso_schema_template_filter_entry" "filter_entry_ext_epg" {
  schema_id          = mso_schema.schema1.id
  template_name      = local.aws_template_name
  name               = var.filter_name
  display_name       = var.filter_name
  entry_name         = "Any"
  entry_display_name = "Any"
}

resource "mso_schema_template_contract" "contract_ext_epg" {
  schema_id     = mso_schema.schema1.id
  template_name = local.aws_template_name
  contract_name = var.internet_contract_name
  display_name  = var.internet_contract_name
  scope         = "context"
  directives    = ["none"]
  filter_relationship {
    filter_name = mso_schema_template_filter_entry.filter_entry_ext_epg.name
  }
}

# Add Contract as Provider to Web EPG

resource "mso_schema_template_anp_epg_contract" "epg_provider" {
  schema_id         = mso_schema.schema1.id
  template_name     = local.aws_template_name
  anp_name          = mso_schema_template_anp.aws_ap.name
  epg_name          = mso_schema_template_anp_epg.cloud_epg.name
  contract_name     = mso_schema_template_contract.contract_ext_epg.contract_name
  relationship_type = "provider"
}

# Add Contract as Consumer to External EPG (Internet)

resource "mso_schema_template_external_epg_contract" "ext_epg_consumer" {
  schema_id         = mso_schema.schema1.id
  template_name     = local.aws_template_name
  external_epg_name = mso_schema_template_external_epg.external_epg.external_epg_name
  contract_name     = mso_schema_template_contract.contract_ext_epg.contract_name
  relationship_type = "consumer"
}