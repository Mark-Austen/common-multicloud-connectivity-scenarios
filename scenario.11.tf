data "megaport_location" "location_1" {
  name = "Equinix SG1"
}

data "megaport_location" "location_2" {
  name = "Equinix SG2"
}

data "megaport_location" "location_3" {
  name = "Global Switch Singapore - Tai Seng"
}

resource "megaport_mve" "mve_location_1" {
  location_id          = data.megaport_location.location_1.id
  product_name         = "MVE 1 SIN"
  contract_term_months = 1

  vendor_config = {
    vendor         = "cisco"
    image_id       = 83
    product_size   = "SMALL"
    ssh_public_key = "ssh-rsa <public key>"
  }

  vnics = [
    {
      description = "vnic0"
    }
  ]
}

resource "megaport_mve" "mve_location_2" {
  location_id          = data.megaport_location.location_2.id
  product_name         = "MVE 2 SIN"
  contract_term_months = 1

  vendor_config = {
    vendor         = "cisco"
    image_id       = 83
    product_size   = "SMALL"
    ssh_public_key = "ssh-rsa <public key>"
  }

  vnics = [
    {
      description = "vnic0"
    }
  ]
}

data "megaport_partner" "internet_zone_red" {
  connect_type  = "TRANSIT"
  company_name  = "Networks"
  product_name  = "Megaport Internet"
  location_id   = data.megaport_location.location_2.id
}

resource "megaport_vxc" "transit_vxc_sin_1" {
  product_name         = "MVE 1 SIN - Internet VXC"
  rate_limit           = 100
  contract_term_months = 1
  
  a_end = {
    requested_product_uid = megaport_mve.mve_location_1.product_uid
  }
  
  b_end = {
    requested_product_uid = data.megaport_partner.internet_zone_red.product_uid
  }
  
  b_end_partner_config = {
    partner = "transit"
  }
}

data "megaport_partner" "internet_zone_blue" {
  connect_type  = "TRANSIT"
  company_name  = "Networks"
  product_name  = "Megaport Internet"
  location_id   = data.megaport_location.location_3.id
}

resource "megaport_vxc" "transit_vxc_sin_2" {
  product_name         = "MVE 2 SIN - Internet VXC"
  rate_limit           = 100
  contract_term_months = 1
  
  a_end = {
    requested_product_uid = megaport_mve.mve_location_2.product_uid
  }
  
  b_end = {
    requested_product_uid = data.megaport_partner.internet_zone_blue.product_uid
  }
  
  b_end_partner_config = {
    partner = "transit"
  }
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
    requested_product_uid = megaport_mve.mve_location_1.product_uid
    inner_vlan            = 301
    vnic_index            = 0
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

data "megaport_partner" "aws_port_2_sin" {
  connect_type = "AWSHC"
  company_name = "AWS"
  product_name = "Asia Pacific (Singapore) (ap-southeast-1)"
  location_id  = data.megaport_location.location_3.id
}

resource "megaport_vxc" "aws_vxc_sin_2" {
  product_name         = "AWS VXC - Secondary"
  rate_limit           = 50
  contract_term_months = 1

  a_end = {
    requested_product_uid = megaport_mve.mve_location_2.product_uid
    inner_vlan            = 302
    vnic_index            = 0
  }

  b_end = {
    requested_product_uid = data.megaport_partner.aws_port_2_sin.product_uid
  }

  b_end_partner_config = {
    partner = "aws"
    aws_config = {
      name           = "AWS VXC - Secondary"
      type           = "private"
      connect_type   = "AWSHC"
      owner_account  = "<aws accoount id>"
      diversity_zone = "blue"
    }
  }
}

resource "megaport_vxc" "azure_vxc_sin_1" {
  product_name            = "Azure VXC - Primary"
  rate_limit              = 50
  contract_term_months    = 1

  a_end = {
    requested_product_uid = megaport_mve.mve_location_1.product_uid
    inner_vlan            = 401
    vnic_index            = 0
  }

  b_end = {}

  b_end_partner_config = {
    partner = "azure"
    azure_config = {
      port_choice = "primary"
      service_key = "<azure expressroute service key>"
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

resource "megaport_vxc" "azure_vxc_sin_2" {
  product_name            = "Azure VXC - Secondary"
  rate_limit              = 50
  contract_term_months    = 1

  a_end = {
    requested_product_uid = megaport_mve.mve_location_2.product_uid
    inner_vlan            = 402
    vnic_index            = 0
  }

  b_end = {}

  b_end_partner_config = {
    partner = "azure"
    azure_config = {
      port_choice = "secondary"
      service_key = "<azure expressroute service key>"
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

data "megaport_partner" "google_port_1_sin" {
  connect_type = "GOOGLE"
  company_name = "Google inc.."
  product_name = "Singapore (sin-zone1-2260)"
  location_id  = data.megaport_location.location_1.id
}

resource "megaport_vxc" "gcp_vxc_sin_1" {
  product_name         = "Google Cloud VXC - Primary"
  rate_limit           = 50
  contract_term_months = 1

  a_end = {
    requested_product_uid = megaport_mve.mve_location_1.product_uid
    inner_vlan            = 501
    vnic_index            = 0
  }

  b_end = {}

  b_end_partner_config = {
    partner = "google"
    google_config = {
      pairing_key = "<google cloud partner interconnect pairing key"
    }
  }
}

data "megaport_partner" "google_port_2_sin" {
  connect_type = "GOOGLE"
  company_name = "Google inc.."
  product_name = "Singapore (sin-zone2-388)"
  location_id  = data.megaport_location.location_3.id
}

resource "megaport_vxc" "gcp_vxc_sin_2" {
  product_name         = "Google Cloud VXC - Secondary"
  rate_limit           = 50
  contract_term_months = 1

  a_end = {
    requested_product_uid = megaport_mve.mve_location_2.product_uid
    inner_vlan            = 502
    vnic_index            = 0
  }

  b_end = {}

  b_end_partner_config = {
    partner = "google"
    google_config = {
      pairing_key = "<google cloud partner interconnect pairing key"
    }
  }
}

resource "megaport_vxc" "oracle_vxc_1_sin" {
  product_name         = "Oracle Cloud VXC - Primary"
  rate_limit           = 1000
  contract_term_months = 1

  a_end = {
    requested_product_uid = megaport_mve.mve_location_1.product_uid
    inner_vlan            = 601
    vnic_index            = 0
  }

  b_end = {}

  b_end_partner_config = {
    partner = "oracle"
    oracle_config = {
      virtual_circuit_id = "<oracle cloud fastconnect virtual circuit id>"
      diversity_zone     = "red"
    }
  }
}

resource "megaport_vxc" "oracle_vxc_2_sin" {
  product_name         = "Oracle Cloud VXC - Secondary"
  rate_limit           = 1000
  contract_term_months = 1

  a_end = {
    requested_product_uid = megaport_mve.mve_location_2.product_uid
    inner_vlan            = 602
    vnic_index            = 0
  }

  b_end = {}

  b_end_partner_config = {
    partner = "oracle"
    oracle_config = {
      virtual_circuit_id = "<oracle cloud fastconnect virtual circuit id>"
      diversity_zone     = "blue"
    }
  }
}
