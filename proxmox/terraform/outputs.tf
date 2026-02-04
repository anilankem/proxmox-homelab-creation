output "vm_id" {
  description = "ID of the created VM"
  value       = proxmox_vm_qemu.vm_from_template.id
}

