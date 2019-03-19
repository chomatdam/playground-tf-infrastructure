listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "0.0.0.0:8201"
  tls_disable      = "true"
}

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

seal "awskms" {
  region = "us-east-1"
  kms_key_id = "d7c1ffd9-8cce-45e7-be4a-bb38dd205966"
}

ui=true

api_addr =  "$API_ADDR"    // TODO: should be  http://$EC2_IP:8200

cluster_addr = "$CLUSTER_ADDR"  //