# Lua filter and tracing demo

## Testing
The setup script will create a kind cluster, a local registry, build the server and client docker images, tag them, 
push them to the local registry, then configure the kube context to interact with the new cluster.

### Script Requirements
* `brew`
* `docker`

### Setup steps

```shell
./setup.sh
```

Install tracing components
```shell
./install-obs.sh
```

Create the consul namespace and your consul license secret
```shell
kubectl create ns consul
# Given consul license in CONSUL_LICENSE env var
kubectl create secret generic consul-ent-license --from-literal="key=${CONSUL_LICENSE}" -n consul
```

Install consul to the cluster.
```shell
consul-k8s install -config-file=./values.yaml
```

Get the consul http token
```shell
export CONSUL_HTTP_TOKEN=$(kubectl get secrets/consul-bootstrap-acl-token -n consul --template='{{.data.token | base64decode }}')
```

Port-forward to get access for consul CLI
```shell
# in another shell
kubectl port-forward -n consul consul-server-0 8500:8501
```

Check the license
```shell
CONSUL_HTTP_SSL=true CONSUL_HTTP_SSL_VERIFY=false consul license get
```

Create the intention to allow client to call server
```shell
CONSUL_HTTP_SSL=true CONSUL_HTTP_SSL_VERIFY=false consul config write ./intentions/intention.hcl
```

Set proxy, mesh, and service defaults
```shell
CONSUL_HTTP_SSL=true CONSUL_HTTP_SSL_VERIFY=false consul config write ./defaults/mesh-defaults.hcl
CONSUL_HTTP_SSL=true CONSUL_HTTP_SSL_VERIFY=false consul config write ./defaults/proxy-defaults.hcl
CONSUL_HTTP_SSL=true CONSUL_HTTP_SSL_VERIFY=false consul config write ./defaults/server-defaults.hcl
CONSUL_HTTP_SSL=true CONSUL_HTTP_SSL_VERIFY=false consul config write ./defaults/client-defaults.hcl
```

Deploy the demo app
```shell
kubectl apply -f charts/
```

View the traces
```shell
kubectl port-forward -n observability <jaeger-pod> 16686:16686
```

Go to http://localhost:16686 in your browser to view the jaeger UI.

Cleanup
```shell
# TODO cleanup of obs services
kubectl delete -f /charts
kubectl -n consul delete /defaults
consul-k8s uninstall -auto-approve -wipe-data -context kind-dc1
```
