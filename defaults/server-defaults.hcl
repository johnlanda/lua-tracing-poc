Kind = "service-defaults"
Name = "server"
MutualTLSMode = "strict"
EnvoyExtensions = [
  {
    Name = "builtin/lua"
    Arguments = {
      ProxyType = "connect-proxy"
      Listener = "inbound"
      Script = <<-EOF
function envoy_on_request(request_handle)
  request_handle:logInfo("Inbound: Logged from the lua filter")
end
      EOF
    }
  },
  {
    Name = "builtin/lua"
    Arguments = {
      ProxyType = "connect-proxy"
      Listener = "outbound"
      Script = <<-EOF
function envoy_on_response(response_handle)
  request_handle:logInfo("Outbound: Logged from the lua filter")
end
      EOF
    }
  }
]
