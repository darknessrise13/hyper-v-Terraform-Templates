provider "hyperv" {
  ssh                  = true
  ssh_host             = var.hyperv_host
  ssh_port             = 22
  ssh_user             = "administrator" #service account for administering the Hyper-V node
  ssh_private_key_path = "~/.ssh/hyperv_key" #Location of the SSH key from the machine running Terraform.
}

resource "hyperv_vhd" "os_disk" {
  path = local.vhd_path
  #vhd_type    = "Dynamic"
  source = var.parent_vhd_path #This copies the parent disk to be the new primary VHD
}

data "hyperv_network_switch" "VM_Adapter" {
  name                                    = "" #Exact name of the vSwitch
  allow_management_os                     = false
  enable_embedded_teaming                 = false
  enable_iov                              = false
  enable_packet_direct                    = false
  minimum_bandwidth_mode                  = "None"
  switch_type                             = "External"
  net_adapter_names                       = ["", ] #Exact name of the network adapter attached to the vSwitch.
  default_flow_minimum_bandwidth_absolute = 0
  default_flow_minimum_bandwidth_weight   = 0
  default_queue_vmmq_enabled              = true
  default_queue_vmmq_queue_pairs          = 16
  default_queue_vrss_enabled              = true
}

resource "hyperv_machine_instance" "VM" {
  name                         = var.vm_name
  generation                   = 2
  automatic_start_action       = "StartIfRunning"
  automatic_stop_action        = "Save"
  checkpoint_type              = "Production"
  static_memory                = true
  guest_controlled_cache_types = false
  high_memory_mapped_io_space  = 8589934592 # 8GB in bytes
  lock_on_disconnect           = "Off"
  low_memory_mapped_io_space   = 1073741824 # 1GB in bytes
  memory_maximum_bytes         = var.vm_memory * 1024 * 1024
  memory_minimum_bytes         = var.vm_memory * 1024 * 1024
  memory_startup_bytes         = var.vm_memory * 1024 * 1024
  notes                        = "VM provisioned by Terraform"
  processor_count              = var.vm_processor_count
  smart_paging_file_path       = var.smart_paging_file_path
  snapshot_file_location       = var.snapshot_file_location
  state                        = "Running"
  depends_on                   = [hyperv_vhd.os_disk]
  wait_for_ips_poll_period     = 5
  wait_for_ips_timeout         = 300
  wait_for_state_poll_period   = 2
  wait_for_state_timeout       = 120

  vm_firmware {
    enable_secure_boot              = "On"
    secure_boot_template            = "MicrosoftWindows"
    preferred_network_boot_protocol = "IPv4"
    console_mode                    = "None"
    pause_after_boot_failure        = "Off"
    boot_order {
      boot_type           = "HardDiskDrive"
      controller_number   = "0"
      controller_location = "0"
    }
  }

  network_adaptors {
    name                = "Eth0"
    switch_name         = data.hyperv_network_switch.VM_Adapter.name
    management_os       = false
    device_naming       = "On"
    allow_teaming       = "Off"
    iov_weight          = 0
    is_legacy           = false
    dynamic_mac_address = true
    vlan_access         = true
    vlan_id             = 10
    wait_for_ips        = true
  }

  vm_processor {
    compatibility_for_migration_enabled               = false
    compatibility_for_older_operating_systems_enabled = false
    hw_thread_count_per_core                          = 0
    maximum                                           = 100
    reserve                                           = 0
    relative_weight                                   = 100
    maximum_count_per_numa_node                       = 0
    maximum_count_per_numa_socket                     = 0
    enable_host_resource_protection                   = true
    expose_virtualization_extensions                  = false
  }

  integration_services = {
    "Guest Service Interface" = true
    "Heartbeat"               = true
    "Key-Value Pair Exchange" = true
    "Shutdown"                = true
    "Time Synchronization"    = true
    "VSS"                     = true
  }

  hard_disk_drives {
    path                = hyperv_vhd.os_disk.path
    controller_type     = "Scsi"
    controller_number   = 0
    controller_location = 0
    minimum_iops        = local.qos_profiles[var.disk_profile].minimum_iops
    maximum_iops        = local.qos_profiles[var.disk_profile].maximum_iops
  }

  # hard_disk_drives {
  #   path                = hyperv_vhd.data_disk.path
  #   controller_type     = "Scsi"
  #   controller_number   = 0
  #   controller_location = 1
  # minimum_iops = local.qos_profiles[var.disk_profile].minimum_iops
  # maximum_iops = local.qos_profiles[var.disk_profile].maximum_iops
  # }

}

resource "time_sleep" "wait_for_boot" {
  create_duration = "600s"
  depends_on      = [hyperv_machine_instance.VM]
}

resource "null_resource" "domain_join_native_ssh" {
  depends_on = [time_sleep.wait_for_boot]


  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    command = "for i in {1..10}; do echo \"Attempt $i to connect via PowerShell Direct...\"; ssh -o StrictHostKeyChecking=no -i ~/.ssh/hyperv_key administrator@${var.hyperv_host} \"\\$lPass = '${replace(var.vm_local_password, "$", "\\$")}' | ConvertTo-SecureString -AsPlainText -Force; \\$lCred = New-Object System.Management.Automation.PSCredential('${hyperv_machine_instance.VM.name}\\\\${var.vm_local_admin}', \\$lPass); \\$dPass = '${replace(var.domain_user_password, "$", "\\$")}' | ConvertTo-SecureString -AsPlainText -Force; \\$dCred = New-Object System.Management.Automation.PSCredential('${replace(var.domain_user, "\\", "\\\\")}', \\$dPass); Invoke-Command -VMName ${hyperv_machine_instance.VM.name} -Credential \\$lCred -ScriptBlock { Add-Computer -DomainName '${var.domain_name}' -OUPath 'OU=Workstations,DC=domain,DC=com' -NewName '${hyperv_machine_instance.VM.name}' -Credential \\$using:dCred -Force -Restart }; Start-Sleep -Seconds 30; done"
  }
}


