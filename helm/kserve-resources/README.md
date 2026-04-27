# kserve-resources

Helm chart for deploying kserve resources

![Version: [[ .Version ]]](https://img.shields.io/badge/Version-[[ .Version ]]-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.17.0](https://img.shields.io/badge/AppVersion-v0.17.0-informational?style=flat-square)

## Installing the Chart

To install the chart, run the following:

```console
$ helm install kserve-resources oci://ghcr.io/kserve/charts/kserve-resources --version [[ .Version ]]
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kserve.version | string | `"v0.17.0"` |  |
| kserve.createSharedResources | bool | `true` |  |
| kserve.inferenceServiceConfig.enabled | string | `""` |  |
| kserve.certManager.enabled | string | `""` |  |
| kserve.storagecontainer.enabled | string | `""` |  |
| kserve.agent.image | string | `"kserve/agent"` |  |
| kserve.agent.tag | string | `""` |  |
| kserve.router.image | string | `"kserve/router"` |  |
| kserve.router.tag | string | `""` |  |
| kserve.router.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.router.imagePullSecrets | list | `[]` |  |
| kserve.service.serviceClusterIPNone | bool | `false` |  |
| kserve.storage.image | string | `"kserve/storage-initializer"` |  |
| kserve.storage.tag | string | `""` |  |
| kserve.storage.resources.requests.memory | string | `"100Mi"` |  |
| kserve.storage.resources.requests.cpu | string | `"100m"` |  |
| kserve.storage.resources.limits.memory | string | `"1Gi"` |  |
| kserve.storage.resources.limits.cpu | string | `"1"` |  |
| kserve.storage.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.storage.containerSecurityContext.privileged | bool | `false` |  |
| kserve.storage.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| kserve.storage.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.storage.enableModelcar | bool | `true` |  |
| kserve.storage.uidModelcar | int | `1010` |  |
| kserve.storage.cpuModelcar | string | `"10m"` |  |
| kserve.storage.memoryModelcar | string | `"15Mi"` |  |
| kserve.storage.caBundleConfigMapName | string | `""` |  |
| kserve.storage.caBundleVolumeMountPath | string | `"/etc/ssl/custom-certs"` |  |
| kserve.storage.storageSpecSecretName | string | `"storage-config"` |  |
| kserve.storage.storageSecretNameAnnotation | string | `"serving.kserve.io/secretName"` |  |
| kserve.storage.s3.accessKeyIdName | string | `"AWS_ACCESS_KEY_ID"` |  |
| kserve.storage.s3.secretAccessKeyName | string | `"AWS_SECRET_ACCESS_KEY"` |  |
| kserve.storage.s3.endpoint | string | `""` |  |
| kserve.storage.s3.useHttps | string | `""` |  |
| kserve.storage.s3.region | string | `""` |  |
| kserve.storage.s3.verifySSL | string | `""` |  |
| kserve.storage.s3.useVirtualBucket | string | `""` |  |
| kserve.storage.s3.useAnonymousCredential | string | `""` |  |
| kserve.storage.s3.CABundleConfigMap | string | `""` |  |
| kserve.storage.s3.CABundle | string | `""` |  |
| kserve.metricsaggregator.enableMetricAggregation | string | `"false"` |  |
| kserve.metricsaggregator.enablePrometheusScraping | string | `"false"` |  |
| kserve.servingruntime.art.image | string | `"kserve/art-explainer"` |  |
| kserve.servingruntime.art.defaultVersion | string | `""` |  |
| kserve.localmodel.enabled | bool | `false` |  |
| kserve.localmodel.controller.image | string | `"kserve/kserve-localmodel-controller"` |  |
| kserve.localmodel.controller.tag | string | `""` |  |
| kserve.localmodel.jobNamespace | string | `"kserve-localmodel-jobs"` |  |
| kserve.localmodel.jobTTLSecondsAfterFinished | int | `3600` |  |
| kserve.localmodel.defaultJobImage | string | `"kserve/storage-initializer"` |  |
| kserve.localmodel.defaultJobTag | string | `""` |  |
| kserve.localmodel.securityContext.fsGroup | int | `1000` |  |
| kserve.localmodel.disableVolumeManagement | bool | `false` |  |
| kserve.localmodel.agent.nodeSelector | object | `{}` |  |
| kserve.localmodel.agent.affinity | object | `{}` |  |
| kserve.localmodel.agent.tolerations | list | `[]` |  |
| kserve.localmodel.agent.hostPath | string | `"/mnt/models"` |  |
| kserve.localmodel.agent.image | string | `"kserve/kserve-localmodelnode-agent"` |  |
| kserve.localmodel.agent.tag | string | `""` |  |
| kserve.localmodel.agent.reconcilationFrequencyInSecs | int | `60` |  |
| kserve.localmodel.agent.securityContext.runAsUser | int | `1000` |  |
| kserve.localmodel.agent.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.security.autoMountServiceAccountToken | bool | `true` |  |
| kserve.inferenceservice.resources.limits.cpu | string | `"1"` |  |
| kserve.inferenceservice.resources.limits.memory | string | `"2Gi"` |  |
| kserve.inferenceservice.resources.requests.cpu | string | `"1"` |  |
| kserve.inferenceservice.resources.requests.memory | string | `"2Gi"` |  |
| kserve.opentelemetryCollector.scrapeInterval | string | `"5s"` |  |
| kserve.opentelemetryCollector.metricReceiverEndpoint | string | `"keda-otel-scaler.keda.svc:4317"` |  |
| kserve.opentelemetryCollector.metricScalerEndpoint | string | `"keda-otel-scaler.keda.svc:4318"` |  |
| kserve.opentelemetryCollector.resource.cpuLimit | string | `"1"` |  |
| kserve.opentelemetryCollector.resource.memoryLimit | string | `"2Gi"` |  |
| kserve.opentelemetryCollector.resource.cpuRequest | string | `"200m"` |  |
| kserve.opentelemetryCollector.resource.memoryRequest | string | `"512Mi"` |  |
| kserve.autoscaler.scaleUpStabilizationWindowSeconds | string | `"0"` |  |
| kserve.autoscaler.scaleDownStabilizationWindowSeconds | string | `"300"` |  |
| kserve.controller.deploymentMode | string | `"Knative"` |  |
| kserve.controller.rbacProxyImage | string | `"quay.io/brancz/kube-rbac-proxy:v0.18.0"` |  |
| kserve.controller.rbacProxy.resources.limits.cpu | string | `"100m"` |  |
| kserve.controller.rbacProxy.resources.limits.memory | string | `"300Mi"` |  |
| kserve.controller.rbacProxy.resources.requests.cpu | string | `"100m"` |  |
| kserve.controller.rbacProxy.resources.requests.memory | string | `"300Mi"` |  |
| kserve.controller.rbacProxy.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.controller.rbacProxy.securityContext.privileged | bool | `false` |  |
| kserve.controller.rbacProxy.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.controller.rbacProxy.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| kserve.controller.rbacProxy.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.controller.labels | object | `{}` |  |
| kserve.controller.podLabels | object | `{}` |  |
| kserve.controller.annotations | object | `{}` |  |
| kserve.controller.podAnnotations | object | `{}` |  |
| kserve.controller.serviceAnnotations | object | `{}` |  |
| kserve.controller.webhookServiceAnnotations | object | `{}` |  |
| kserve.controller.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.controller.securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| kserve.controller.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.controller.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.controller.containerSecurityContext.privileged | bool | `false` |  |
| kserve.controller.containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| kserve.controller.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| kserve.controller.metricsBindAddress | string | `"127.0.0.1"` |  |
| kserve.controller.metricsBindPort | string | `"8080"` |  |
| kserve.controller.gateway.domain | string | `"example.com"` |  |
| kserve.controller.gateway.additionalIngressDomains | list | `[]` |  |
| kserve.controller.gateway.domainTemplate | string | `"{{ .Name }}-{{ .Namespace }}.{{ .IngressDomain }}"` |  |
| kserve.controller.gateway.pathTemplate | string | `""` |  |
| kserve.controller.gateway.urlScheme | string | `"http"` |  |
| kserve.controller.gateway.disableIstioVirtualHost | bool | `false` |  |
| kserve.controller.gateway.disableIngressCreation | bool | `false` |  |
| kserve.controller.gateway.localGateway.gateway | string | `"knative-serving/knative-local-gateway"` |  |
| kserve.controller.gateway.localGateway.gatewayService | string | `"knative-local-gateway.istio-system.svc.cluster.local"` |  |
| kserve.controller.gateway.localGateway.knativeGatewayService | string | `""` |  |
| kserve.controller.gateway.ingressGateway.enableGatewayApi | bool | `false` |  |
| kserve.controller.gateway.ingressGateway.kserveGateway | string | `"kserve/kserve-ingress-gateway"` |  |
| kserve.controller.gateway.ingressGateway.createGateway | bool | `false` |  |
| kserve.controller.gateway.ingressGateway.gateway | string | `"knative-serving/knative-ingress-gateway"` |  |
| kserve.controller.gateway.ingressGateway.className | string | `"istio"` |  |
| kserve.controller.nodeSelector | object | `{}` |  |
| kserve.controller.tolerations | list | `[]` |  |
| kserve.controller.topologySpreadConstraints | list | `[]` |  |
| kserve.controller.affinity | object | `{}` |  |
| kserve.controller.image | string | `"kserve/kserve-controller"` |  |
| kserve.controller.tag | string | `""` |  |
| kserve.controller.imagePullSecrets | list | `[]` |  |
| kserve.controller.resources.limits.cpu | string | `"100m"` |  |
| kserve.controller.resources.limits.memory | string | `"300Mi"` |  |
| kserve.controller.resources.requests.cpu | string | `"100m"` |  |
| kserve.controller.resources.requests.memory | string | `"300Mi"` |  |
| kserve.controller.knativeAddressableResolver.enabled | bool | `false` |  |
