listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "0.0.0.0:8201"
  tls_disable      = "true"
//  tls_cert_file = "" // certificate
//  tls_key_file = "" // private key
}

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}

seal "awskms" {
  region = "${aws_region}"
  kms_key_id = "${kms_key_id}"
}

ui = true

api_addr =  "https://EC2_VAULT_IP_ADDRESS:8200"
cluster_addr = "https://EC2_VAULT_IP_ADDRESS:8201"