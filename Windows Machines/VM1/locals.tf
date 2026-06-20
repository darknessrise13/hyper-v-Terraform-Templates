locals {

  # This map acts as your "Centralized Policy Store"
  qos_profiles = {
    "standard" = {
      minimum_iops = 300
      maximum_iops = 3000
    }
    "premium" = {
      minimum_iops = 1000
      maximum_iops = 10000
    }
  }

  vhd_path       = "${local.vhd_root_path}${var.vm_name}.vhdx"
  data_vhd_path  = "${local.vhd_root_path}${var.vm_name}_data.vhdx"
  fileserver_unc = "\\\\host.domain.name\\path\\to\\share"

  # Dynamically select the switch name
  # These hostnames are case sensitive.
  vm_adapter_switch_name = lookup(
    {
      "host.domain.name" = "vSwitch Name"
      "host.domain.name" = "vSwitch Name"
    },
    var.hyperv_host,
    null
  )

  # Dynamically select the physical NIC
  vm_adapter_nics = lookup(
    {
      "host.domain.name" = "NIC attached to vSwitch Name"
      "host.domain.name" = "NIC attached to vSwitch Name"
    },
    var.hyperv_host,
    []
  )

  vm_data_path = lookup(
    {
      "host.domain.name" = "E:\\Hyper-V" #Root path to Hyper-V files.
      "host.domain.name" = "G:\\HyperV"  #Root path to Hyper-V files.
    },
    var.hyperv_host,
    "C:\\Default-HyperV"
  )

  # Computed paths
  smart_paging_file_path = "${local.vm_data_path}\\Smart Paging\\"
  snapshot_file_location = "${local.vm_data_path}\\Snapshots\\"
  vhd_root_path          = "${local.vm_data_path}\\Virtual Hard Disks\\"
  parent_vhd_path        = "${local.fileserver_unc}\\path\\to\\vhd"

}