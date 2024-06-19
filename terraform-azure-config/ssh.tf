resource "tls_private_key" "pizza_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "public_key_data" {
  value = tls_private_key.pizza_ssh.public_key_pem
}

output "private_key_data" {
  value     = tls_private_key.pizza_ssh.private_key_pem
  sensitive = true
}

resource "local_file" "public_key" {
  content  = tls_private_key.pizza_ssh.public_key_pem
  filename = "ssh/public_key.pem"
}

resource "local_file" "private_key" {
  content  = tls_private_key.pizza_ssh.private_key_pem
  filename = "ssh/private_key.pem"
}
