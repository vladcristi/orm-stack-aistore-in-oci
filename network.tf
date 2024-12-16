resource "oci_core_vcn" "vcn" {
    compartment_id = var.compartment_ocid

    cidr_block = var.cidr_vcn
    display_name = var.vcn_name
}


resource "oci_core_internet_gateway" "igw" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn.id

    display_name = "IGW"
}

resource "oci_core_route_table" "route_table" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn.id

    display_name = "Public_RT"
    route_rules {
        network_entity_id = oci_core_internet_gateway.igw.id

        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
    }
}

resource "oci_core_subnet" "public_subnet" {

    cidr_block = var.cidr_pub_subnet
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn.id
    prohibit_public_ip_on_vnic = false
    route_table_id = oci_core_route_table.route_table.id
    security_list_ids = [oci_core_security_list.security_list.id]
}

resource "oci_core_security_list" "security_list" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn.id

    display_name = "Public_SL"

    egress_security_rules {
       
        destination = "0.0.0.0/0"
        protocol = "all"
    }

    ingress_security_rules {
        
        protocol = "6"
        source = "0.0.0.0/0"
        
        tcp_options {

            max = "22"
            min = "22"
            source_port_range {
                #Required
                max = 65535
                min = 1
            }
        }
    }

    ingress_security_rules {

        description = "ICMP traffic for: 3, 4 Destination Unreachable: Fragmentation Needed and Don't Fragment was Set"
        protocol = "1"
        source = "0.0.0.0/0"
        
        icmp_options {
            type = 3
            code =  4
        }
    }

    ingress_security_rules {

        description = "ICMP traffic for: 3 Destination Unreachable"
        protocol = "1"
        source = "10.0.0.0/16"
        
        icmp_options {
            type = 3
        }
    }
}
