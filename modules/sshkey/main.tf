#-----------------------------------------------------
# Creating private key
#-----------------------------------------------------
resource "tls_private_key" "ssh_key" {
  algorithm = var.algorithm
}

#-----------------------------------------------------
# Storing private key to local file
#-----------------------------------------------------
resource "local_file" "ssh_key_file" {
  filename = var.file_name
  content  = tls_private_key.ssh_key.private_key_pem
}