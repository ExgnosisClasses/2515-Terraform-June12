output "ssh_private_key" {
  value       = tls_private_key.ssh.private_key_pem
  description = "Private SSH key to connect to the VM"
  sensitive   = true
}



