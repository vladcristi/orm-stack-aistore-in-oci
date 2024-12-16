## Copyright (c) 2024, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.10.0"
    }
  }
  required_version = "= 1.2.9"
}

variable "compartment_ocid" {}
 
variable vcn_id {
  type = string
  default = ""
}

variable subnet_id {
  type = string
  default = ""
}

variable cidr_vcn {
  type = string
  default = ""
}

variable vcn_name {
  type = string
  default = ""
}

variable cidr_pub_subnet {
  type = string
  default = ""
}

variable vm_display_name {
  type = string
  default = "AIStore-Cluster-Instance"
}

variable ssh_public_key {
  type = string
  default = ""
}

variable ad {
  type = string
  default = ""
}

variable bucket_namespace {
  type = string
  default = ""
}

variable aws_access_key_id {
  type = string
  default = ""
}

variable aws_secret_access_key {
  type = string
  default = ""
}