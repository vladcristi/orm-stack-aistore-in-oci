provider "oci" {}

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = true
  part {
    filename     = "cloudinit.sh"
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/userdata/cloudinit.sh", {aws_access_key_id = var.aws_access_key_id, aws_secret_access_key = var.aws_secret_access_key, bucket_namespace = var.bucket_namespace})
  }
}

resource "oci_core_instance" "this" {
	agent_config {
		is_management_disabled = "false"
		is_monitoring_disabled = "false"
		plugins_config {
			desired_state = "DISABLED"
			name = "Vulnerability Scanning"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Oracle Java Management Service"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "OS Management Service Agent"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "OS Management Hub Agent"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Management Agent"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Custom Logs Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute RDMA GPU Monitoring"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Run Command"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute HPC RDMA Auto-Configuration"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute HPC RDMA Authentication"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Cloud Guard Workload Protection"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Block Volume Management"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Bastion"
		}
	}
	availability_config {
		is_live_migration_preferred = "false"
		recovery_action = "RESTORE_INSTANCE"
	}
	availability_domain = var.ad
	compartment_id = var.compartment_ocid
	create_vnic_details {
		assign_ipv6ip = "false"
		assign_private_dns_record = "true"
		assign_public_ip = "true"
		subnet_id = var.subnet_id != "" ? var.subnet_id : oci_core_subnet.public_subnet.id
		
	}
	display_name = var.vm_display_name
	metadata = {
		ssh_authorized_keys = local.bundled_ssh_public_keys
		user_data           = data.cloudinit_config.config.rendered
	}
	shape = "VM.Standard.E5.Flex"

	source_details {
		boot_volume_size_in_gbs = "150"
		source_id = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaax6mi62d6xegbc3kokmj37ufh2mr2ppz6b6ruzrvdgjzv5hgba6va"
		source_type = "image"
		
	}

	shape_config {
	  	memory_in_gbs = 12 
		ocpus = 1
	}
	freeform_tags = {}

}
resource "null_resource" "this" {
	depends_on = [ oci_core_instance.this ]
	provisioner "file" {
		source      = "jupyter_notebooks/test.ipynb"
		destination = "/home/opc/test.ipynb"
 	}
	connection {
		type    	= "ssh"
		user     	= "opc"
		private_key = tls_private_key.stack_key.private_key_openssh
		host    	= oci_core_instance.this.public_ip
	}
	
}

resource "oci_objectstorage_bucket" "test_bucket" {
    compartment_id = var.compartment_ocid
    name = "mybucket"
    namespace = var.bucket_namespace
}