variable "hyperv_host" {
  description = "The name of the Hyper-V host to use"
  type        = string
}

variable "parent_vhd_path" {
  description = "The path to the parent VHD file"
  type        = string
}

variable "snapshot_file_location" {
  description = "Location to store snapshots"
  type        = string
}

variable "smart_paging_file_path" {
  description = "Location to store smart paging files"
  type        = string
}

variable "minimum_vm_memory" {
  description = "Minimum memory allocation for VMs in MB"
  type        = number
}

variable "vm_memory" {
  description = "Memory allocation for VMs in MB"
  type        = number
}

variable "vm_processor_count" {
  description = "Number of virtual processors"
  type        = number
}

variable "vm_name" {
  type        = string
  description = "The name of the virtual machine"
}

variable "vhd_root_path" {
  type        = string
  description = "The root path where the VHD will be stored"
  default     = "C:\\Hyper-V\\Virtual Hard Disks\\"
}

variable "domain_name" {
  type        = string
  description = "Domain name to join the VMs"
  sensitive   = true
}

variable "domain_user" {
  type        = string
  description = "Domain user to join the VMs"
  sensitive   = true
}

variable "domain_user_password" {
  type        = string
  description = "Domain user password to join the VMs"
  sensitive   = true
}

variable "vm_local_admin" {
  type      = string
  default   = "administrator"
  sensitive = true
}

variable "vm_local_password" {
  type      = string
  sensitive = true
}

variable "disk_profile" {
  type        = string
  description = "The storage QoS profile to apply to the virtual disk. Options: standard, premium."
  default     = "standard"

  # Optional: Enforce valid profile selections at plan-time
  validation {
    condition     = contains(["standard", "premium"], var.disk_profile)
    error_message = "The disk_profile must be either 'standard' or 'premium'."
  }
}