output "ssh_key_id" {
  description = "ssh key id"
  value       = tls_private_key.ssh_key.id
}
output "ssh_public_key" {
  description = "ssh key content"
  value       = tls_private_key.ssh_key.public_key_openssh
}