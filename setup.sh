#!/bin/sh

brew upgrade && brew update

if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found, installing via brew"
    brew install kubectl
fi

if ! command -v kind &> /dev/null
then
    echo "kind could not be found, installing via brew"
    brew install kind
fi

if ! command -v helm &> /dev/null
then
    echo "helm could not be found, installing via brew"
    brew install helm
fi

# Create the new cluster and local registry
./kind-with-registry.sh

kubectl cluster-info --context kind-dc1

# build the client docker image
(cd ./demo-app/client && \
  docker build -t 'lua-tracing-poc-client' -t 'lua-tracing-poc-client:latest' . && \
  docker tag 'lua-tracing-poc-client:latest' 'localhost:5001/lua-tracing-poc-client:latest' && \
  docker push 'localhost:5001/lua-tracing-poc-client:latest')

# build the server docker image
(cd ./demo-app/server && \
  docker build -t 'lua-tracing-poc-server' -t 'lua-tracing-poc-server:latest' . && \
  docker tag 'lua-tracing-poc-server:latest' 'localhost:5001/lua-tracing-poc-server:latest' && \
  docker push 'localhost:5001/lua-tracing-poc-server:latest')

