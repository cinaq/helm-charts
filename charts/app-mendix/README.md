# app-mendix

![Version: 3.0.4](https://img.shields.io/badge/Version-3.0.4-informational?style=flat-square)

Mendix Application Chart.

This Helm chart simplifies the deployment and management of Mendix applications on Kubernetes clusters. It provides a standardized packaging format and streamlines deployments across development, staging, and production environments. Key features include configuration of resource requirements, integration with secrets management, and improved application resilience through startup, readiness and liveness probes.


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
| affinity | object | `{}` | Pod affinity settings |
| annotations | object | `{}` | Pod annotations |
| autoscale.enabled | bool | `false` | Enable horizontal pod autoscaling |
| autoscale.maxSlaveReplicas | int | `3` | Maximum number of slave replicas |
| autoscale.minSlaveReplicas | int | `1` | Minimum number of slave replicas |
| autoscale.targetCPUUtilizationPercentage | int | `70` | Target CPU utilization percentage for scaling |
| env | list | `[]` | List of environment variables |
| image.pullPolicy | string | `"Always"` | Image pull policy |
| image.repository | string | `"cinaq/hackme"` | Docker image repository |
| image.tag | string | `"latest"` | Docker image tag |
| imagePullSecrets[0].name | string | `"dockerconfigjson"` | Name of the image pull secret |
| ingress.addHosts | bool | `false` | Add additional hosts to ingress |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.domain | string | `"app.example.com"` | Default domain for ingress |
| ingress.enabled | bool | `true` | Enable ingress |
| ingress.hosts | list | `[]` | List of additional ingress hosts |
| ingress.ingressClassName | string | `"nginx"` | Ingress class name |
| ingress.tls.enabled | bool | `false` | Enable TLS for ingress |
| ingress.tls.secretName | string | `"secret-tls"` | TLS secret name |
| licenseId | string | `nil` | Mendix license ID |
| licenseKey | string | `nil` | Mendix license key |
| lifecycle.prestop.command | string | `"/opt/eap/bin/stop.sh"` | Command to run before stopping container |
| lifecycle.prestop.enabled | bool | `false` | Enable prestop lifecycle hook |
| metrics.enabled | bool | `true` | Enable metrics collection |
| metrics.runtimeLoginMetricsEnabled | bool | `true` | Enable runtime login metrics |
| metrics.trendsForwarderUrl | string | `""` | URL for forwarding metrics trends (e.g. Loki endpoint) |
| networkPolicy.enabled | bool | `true` | Enable network policy |
| networkPolicy.ingress.allowed | bool | `true` | Allow ingress traffic |
| nodeSelector | object | `{}` | Node selector for pod assignment |
| persistence.enabled | bool | `false` | Enable persistence for application data |
| persistence.extraVolumeMounts | list | `[]` | Additional volume mounts |
| persistence.extraVolumes | list | `[]` | Additional volumes |
| persistence.nfsVolume.enabled | bool | `false` | Enable NFS volume |
| persistence.nfsVolume.name | string | `"mendix-nfs"` | Name of the NFS volume |
| persistence.nfsVolume.path | string | `"/mnt/mendixdata"` | Path on the NFS server |
| persistence.nfsVolume.server | string | `"nfs.example.com"` | NFS server address |
| persistence.nfsVolume.storage | string | `"10Gi"` | Storage size for NFS volume |
| persistence.nfsVolume.subPath | string | `"/app"` | Subpath within the volume |
| livenessProbe.failureThreshold | int | `18` | Maximum number of failures before container is restarted |
| livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the probe |
| readinessProbe.failureThreshold | int | `30` | Maximum number of failures before pod is marked as not ready |
| readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the probe |
| startupProbe.failureThreshold | int | `1080` | Maximum number of failures before giving up (allows up to 3 hours for startup) |
| startupProbe.periodSeconds | int | `10` | How often (in seconds) to perform the probe |
| replicaCount | int | `1` | Number of replicas |
| resources | object | `{}` | CPU/Memory resource requests/limits |
| route.annotations | object | `{}` | OpenShift route annotations |
| route.enabled | bool | `false` | Enable OpenShift route |
| route.host | string | `"app.example.com"` | OpenShift route host |
| route.tls.enabled | bool | `false` | Enable TLS for OpenShift route |
| secretName | string | `""` | Name of the secret containing environment variables |
| service.externalPort | int | `80` | External port for the service |
| service.internalPort | int | `8080` | Internal port for the service |
| service.type | string | `"ClusterIP"` | Kubernetes service type |
| tolerations | list | `[]` | Node tolerations |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Xiwen Cheng | <x@cinaq.com> |  |
| Viktor Berlov | <viktor@cinaq.com> |  |