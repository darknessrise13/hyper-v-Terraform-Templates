locals {

  # QOS Profiles that can be defined per VHD.
  qos_profiles = {
    "standard" = {
      minimum_iops = 100
      maximum_iops = 500
    }
    "premium" = {
      minimum_iops = 1000
      maximum_iops = 5000
    }
  }

  vhd_path      = "${var.vhd_root_path}${var.vm_name}.vhdx"
  data_vhd_path = "${var.vhd_root_path}${var.vm_name}_data.vhdx"

}