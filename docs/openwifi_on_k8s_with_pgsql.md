# Deploy OpenWiFi on K8S cluster with Postgres

This guide contains instructions on how to deploy OpenWiFi controller in Kubernetes cluster with single external Postgres database.

## Prerequisites

- Deployed Kubernetes cluster accessible from client machine. If deploying on Microk8s on a VM ensure that `metallb` add on is enabled and setup to match VM IP address.
- Tools installed on client machine: `kubectl`, `helm`.

## Deployment of OpenWiFi

Create namespace for OpenWiFi deployment in K8S cluster, eg. `openwifi`:

```
kubectl create ns openwifi
```

Optionally set default context of `kubectl` to point to this new namespace:

```
kubectl config set-context --current --namespace=openwifi
```

Create required secrets `openwifi-certs` to hold certificates and  `tip-openwifi-initdb-scripts` to hold DB initialization scripts and initial users data:

```
kubectl -n openwifi create secret generic openwifi-certs --from-file=../docker-compose/certs/
kubectl -n openwifi create secret generic tip-openwifi-initdb-scripts --from-file=create_users.sh=./scripts/create_users.sh --from-file=users.csv=./scripts/users.csv -n openwifi
```

Deploy OpenWiFi in `openwifi` namespace using Helm charts with single external Postgres database:

```
helm dependency update
helm upgrade --namespace=openwifi --install -f environment-values/values.base.secure.k8s.yaml -f environment-values/values.openwifi-qa.single-external-db.yaml -f environment-values/values.default.credentials.yaml openwifi .
```

Deploy Ingress:

```
kubectl apply -f ingress.yaml
```

To load certificates into browser visit:

```
https://openwifi.waln.local:16001
https://openwifi.waln.local:16002
https://openwifi.waln.local:16004
https://openwifi.waln.local:16005
https://openwifi.waln.local:16009
```

Access controller UI by navigating to `http://openwifi.waln.local/`. Use default login and password: `tip@ucentral.com` and `openwifi`.
