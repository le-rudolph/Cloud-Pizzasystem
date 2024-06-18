resource "tls_private_key" "pizza_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "public_key_data" {
  value = tls_private_key.pizza_ssh.public_key_openssh
}

output "private_key_data" {
  value     = tls_private_key.pizza_ssh.private_key_pem
  sensitive = true
}
