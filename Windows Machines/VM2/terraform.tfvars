# variables.tfvars

minimum_vm_memory  = 6144  #In MB
vm_memory          = 12288 #In MB
vm_processor_count = 4     #vCPU count
vm_name            = "VM Name"
hyperv_host        = "" #Hyper-V Hostnmae

smart_paging_file_path = "" #Path to your smart paging file directory
snapshot_file_location = "" #Path to your snapshots directory

vhd_root_path   = ""         #Root path where your VHDs are stored
parent_vhd_path = ""         #Path to parent (for differencing disks) or source VHD
disk_profile    = "standard" #Options: standard, premium