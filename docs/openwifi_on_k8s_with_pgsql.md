# Deploy OpenWiFi on K8S cluster with Postgres

## Prerequisites

- Deployed Kubernetes cluster accessible from client machine.
- Tools installed on client machine: `kubectl`

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
helm upgrade --namespace=openwifi --install -f environment-values/values.base.secure.yaml -f environment-values/values.openwifi-qa.single-external-db.yaml -f environment-values/values.pgsql.yaml openwifi .
```

Create default users:

