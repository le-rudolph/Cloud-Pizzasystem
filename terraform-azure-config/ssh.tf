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
  content  = public_key_data
  filename = "ssh/public_key.pem"
}

resource "local_file" "private_key" {
  content  = private_key_data
  filename = "ssh/private_key.pem"
}
