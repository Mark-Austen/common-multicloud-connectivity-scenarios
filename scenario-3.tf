data "megaport_location" "location_1" {
  name = "Equinix SG1"
}

resource "megaport_port" "port_1_sin" {
  product_name           = "Port 1 SIN"
  port_speed             = 10000
  location_id            = data.megaport_location.location_1.id
  contract_term_months   = 1
  marketplace_visibility = false
  diversity_zone         = "red"
}

resource "megaport_mcr" "mcr_1_sin" {
  product_name         = "MCR 1 SIN"
  port_speed           = 1000
  location_id          = data.megaport_location.location_1.id
  contract_term_months = 1
  diversity_zone       = "red"
}

resource "megaport_vxc" "port_1_sin_mcr_1_sin_vxc" {
  product_name         = "Port 1 SIN to MCR 1 SIN VXC"
  rate_limit           = 1000
  contract_term_months = 1

  a_end = {
    requested_product_uid = megaport_port.port_1_sin.product_uid
    ordered_vlan          = 101
  }

  b_end = {
    requested_product_uid = megaport_mcr.mcr_1_sin.product_uid
  }
}

data "megaport_location" "location_2" {
  name = "Equinix SG2"
}

data "megaport_partner" "aws_port_1_sin" {
  connect_type = "AWSHC"
  company_name = "AWS"
  product_name = "Asia Pacific (Singapore) (ap-southeast-1)"
  location_id  = data.megaport_location.location_2.id
}

resource "megaport_vxc" "aws_vxc_sin_1" {
  product_name         = "AWS VXC - Primary"
  rate_limit           = 50
  contract_term_months = 1

  a_end = {
    requested_product_uid = megaport_mcr.mcr_1_sin.product_uid
    ordered_vlan          = 301
  }

  b_end = {
    requested_product_uid = data.megaport_partner.aws_port_1_sin.product_uid
  }

  b_end_partner_config = {
    partner = "aws"
    aws_config = {
      name           = "AWS VXC - Primary"
      type           = "private"
      connect_type   = "AWSHC"
      owner_account  = "<aws account id>"
      diversity_zone = "red"
    }
  }
}

resource "megaport_vxc" "azure_vxc_sin_1" {
  product_name            = "Azure VXC - Primary"
  rate_limit              = 50
  contract_term_months    = 1

  a_end = {
    requested_product_uid = megaport_mcr.mcr_1_sin.product_uid
  }

  b_end = {}

  b_end_partner_config = {
    partner = "azure"
    azure_config = {
      port_choice = "primary"
      service_key = "<expressroute service key>"
        peers = [{
        type             = "private"
        vlan             = 401
        peer_asn         = 65001
        primary_subnet   = "192.168.100.0/30"
        secondary_subnet = "192.168.100.4/30"
      }]
    }
  }
}

resource "megaport_vxc" "gcp_vxc_sin_1" {
  product_name         = "Google Cloud VXC - Primary"
  rate_limit           = 50
  contract_term_months = 1

  a_end = {
    requested_product_uid = megaport_mcr.mcr_1_sin.product_uid
    ordered_vlan          = 501
  }

  b_end = {}

  b_end_partner_config = {
    partner = "google"
    google_config = {
      pairing_key = "<google partner interconnect pairing key>"
    }
  }
}
