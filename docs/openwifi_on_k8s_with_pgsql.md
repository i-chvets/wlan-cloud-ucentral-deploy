# Deploy OpenWiFi on K8S cluster with Postgres

This guide contains instructions on how to deploy OpenWiFi controller in Kubernetes cluster with single external Postgres database.

## Prerequisites

- Deployed Kubernetes cluster accessible from client machine.
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


Enable port forwarding:

```
kubectl port-forward deployment/proxy 5912 5913 16001 16002 16003 16004 16005 16006 16009 &
kubectl port-forward deployment/owrrm 16789 &
kubectl port-forward deployment/owgwui 8080:80 &
kubectl port-forward deployment/owprovui 8088:80 &
```

Update hosts file (`/etc/hosts`) with the following:

```
127.0.0.1 10.64.140.43.nip.io
127.0.0.1 owgwui-owgwui.svc.cluster.local
127.0.0.1 owprovui-owprovui.svc.cluster.local
127.0.0.1 owsec-owsec.svc.cluster.local
127.0.0.1 owgw-owgw.svc.cluster.local
127.0.0.1 owfms-owfms.svc.cluster.local
127.0.0.1 owprov-owprov.svc.cluster.local
127.0.0.1 owanalytics-owanalytics.svc.cluster.local
```

To load certificates into browser visit:

```
https://owgwui-owgwui.svc.cluster.local:16001
https://owprovui-owprovui.svc.cluster.local:16001
https://owsec-owsec.svc.cluster.local:16001
https://owgw-owgw.svc.cluster.local:16002
https://owfms-owfms.svc.cluster.local:16004
https://owprov-owprov.svc.cluster.local:16005
https://owanalytics-owanalytics.svc.cluster.local:16009
```

Access controller UI by navigating to `http://10.64.140.43.nip.io:8080/` if using proxy access method or to `https://<fqdn>:8080/`. Use default login and password: `tip@ucentral.com` and `openwifi`.
