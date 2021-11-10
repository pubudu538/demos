datacenter = "dc1"
acl {
  enabled        = true
  default_policy = "deny"
  down_policy    = "extend-cache"
  enable_token_persistence = true
}
connect {
  enabled = true
}
ports {
  "grpc" = 8502
  "https" = 8501
}
verify_incoming = false
verify_outgoing = false
verify_server_hostname = false
client_addr = "0.0.0.0"
enable_script_checks = false