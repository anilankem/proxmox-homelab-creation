resource "proxmox_vm_qemu" "vm_from_template" {
  name        = var.vm_name
  target_node = var.node_name

  # Clone from an existing template
  clone = var.template_name

  cores   = var.vm_cores
  sockets = 1
  memory  = var.vm_memory_mb

  tags = length(var.vm_tags) > 0 ? join(";", var.vm_tags) : null

  disk {
    size    = "${var.disk_size_gb}G"
    type    = "scsi"
    storage = var.disk_storage
  }

  # Reasonable defaults
  onboot = true
  scsihw = "virtio-scsi-pci"

  # Prevent accidental re-creation if Proxmox changes certain attributes
  lifecycle {
    ignore_changes = [
      network_interface,
    ]
  }
}

