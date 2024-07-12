# app-mendix

![Version: 3.0.3](https://img.shields.io/badge/Version-3.0.3-informational?style=flat-square)

Mendix Application Chart.

This Helm chart simplifies the deployment and management of Mendix applications on Kubernetes clusters. It provides a standardized packaging format and streamlines deployments across development, staging, and production environments. Key features include configuration of resource requirements, integration with secrets management, and health checks for improved application resilience.


Add `cinaq` repository

```
helm repo add cinaq https://cinaq.github.io/helm-charts/
helm repo update
```

Install `app-mendix` helm chart

```
helm install my-app cinaq/app-mendix
```

Upgrade `app-mendix` helm chart with vaules update (Ex. Scale up application)

```
helm upgrade my-app cinaq/app-mendix --set replicaCount=2
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| annotations | object | `{}` |  |
| autoscale.enabled | bool | `false` |  |
| autoscale.maxSlaveReplicas | int | `3` |  |
| autoscale.minSlaveReplicas | int | `1` |  |
| autoscale.targetCPUUtilizationPercentage | int | `70` |  |
| env | list | `[]` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"cinaq/hackme"` |  |
| image.tag | string | `"latest"` |  |
| imagePullSecrets[0].name | string | `"dockerconfigjson"` |  |
| ingress.addHosts | bool | `false` |  |
| ingress.annotations | object | `{}` |  |
| ingress.domain | string | `"app.example.com"` |  |
| ingress.enabled | bool | `true` |  |
| ingress.hosts | list | `[]` |  |
| ingress.ingressClassName | string | `"nginx"` |  |
| ingress.tls.enabled | bool | `false` |  |
| ingress.tls.secretName | string | `"secret-tls"` |  |
| licenseId | string | `nil` |  |
| licenseKey | string | `nil` |  |
| lifecycle.prestop.command | string | `"/opt/eap/bin/stop.sh"` |  |
| lifecycle.prestop.enabled | bool | `false` |  |
| livenessProbe.enabled | bool | `true` |  |
| livenessProbe.exec.command | string | `nil` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/"` |  |
| livenessProbe.httpGet.port | int | `8080` |  |
| livenessProbe.initialDelaySeconds | int | `200` |  |
| livenessProbe.periodSeconds | int | `20` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.tcpSocket.port | string | `nil` |  |
| livenessProbe.timeoutSeconds | int | `1` |  |
| livenessProbe.type | string | `"httpGet"` |  |
| metrics.enabled | bool | `true` |  |
| metrics.runtimeLoginMetricsEnabled | bool | `true` |  |
| metrics.trendsForwarderUrl | string | `""` |  |
| networkPolicy.enabled | bool | `true` |  |
| networkPolicy.ingress.allowed | bool | `true` |  |
| nodeSelector | object | `{}` |  |
| persistence.enabled | bool | `false` |  |
| persistence.extraVolumeMounts | list | `[]` |  |
| persistence.extraVolumes | list | `[]` |  |
| persistence.nfsVolume.enabled | bool | `false` |  |
| persistence.nfsVolume.name | string | `"mendix-nfs"` |  |
| persistence.nfsVolume.path | string | `"/mnt/mendixdata"` |  |
| persistence.nfsVolume.server | string | `"nfs.example.com"` |  |
| persistence.nfsVolume.storage | string | `"10Gi"` |  |
| persistence.nfsVolume.subPath | string | `"/app"` |  |
| readinessProbe.enabled | bool | `true` |  |
| readinessProbe.exec.command | string | `nil` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.httpGet.path | string | `"/"` |  |
| readinessProbe.httpGet.port | int | `8080` |  |
| readinessProbe.initialDelaySeconds | int | `120` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.tcpSocket.port | string | `nil` |  |
| readinessProbe.timeoutSeconds | int | `1` |  |
| readinessProbe.type | string | `"httpGet"` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| route.annotations | object | `{}` |  |
| route.enabled | bool | `false` |  |
| route.host | string | `"app.example.com"` |  |
| route.tls.enabled | bool | `false` |  |
| secretName | string | `""` |  |
| service.externalPort | int | `80` |  |
| service.internalPort | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| tolerations | list | `[]` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Xiwen Cheng | <x@cinaq.com> |  |
| Viktor Berlov | <viktor@cinaq.com> |  |