# kserve-runtime-configs

![Version: [[ .Version ]]](https://img.shields.io/badge/Version-[[ .Version ]]-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.17.0](https://img.shields.io/badge/AppVersion-v0.17.0-informational?style=flat-square)

KServe Runtime Configurations - ClusterServingRuntimes and LLM Inference Configs

**Homepage:** <https://kserve.github.io/website/>

## Installing the Chart

To install the chart, run the following:

```console
$ helm install kserve-runtime-configs oci://ghcr.io/kserve/charts/kserve-runtime-configs --set kserve.servingruntime.enabled=true --set kserve.llmisvcConfigs.enabled=true --version [[ .Version ]]
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| KServe Team |  | <https://github.com/kserve/kserve> |

## Source Code

* <https://github.com/kserve/kserve>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kserve.version | string | `"v0.17.0"` |  |
| kserve.llmisvcConfigs.enabled | bool | `false` |  |
| kserve.servingruntime.enabled | bool | `false` |  |
| kserve.servingruntime.modelNamePlaceholder | string | `"{{.Name}}"` |  |
| kserve.servingruntime.tensorflow.disabled | bool | `false` |  |
| kserve.servingruntime.tensorflow.image | string | `"tensorflow/serving"` |  |
| kserve.servingruntime.tensorflow.tag | string | `"2.6.2"` |  |
| kserve.servingruntime.tensorflow.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.tensorflow.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.tensorflow.securityContext.runAsUser | int | `1000` |  |
| kserve.servingruntime.tensorflow.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.tensorflow.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.tensorflow.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.tensorflow.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.mlserver.disabled | bool | `false` |  |
| kserve.servingruntime.mlserver.image | string | `"docker.io/seldonio/mlserver"` |  |
| kserve.servingruntime.mlserver.tag | string | `"1.5.0"` |  |
| kserve.servingruntime.mlserver.modelClassPlaceholder | string | `"{{.Labels.modelClass}}"` |  |
| kserve.servingruntime.mlserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.mlserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.mlserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.mlserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.mlserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.mlserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.sklearnserver.disabled | bool | `false` |  |
| kserve.servingruntime.sklearnserver.image | string | `"kserve/sklearnserver"` |  |
| kserve.servingruntime.sklearnserver.tag | string | `""` |  |
| kserve.servingruntime.sklearnserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.sklearnserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.sklearnserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.sklearnserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.sklearnserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.sklearnserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.xgbserver.disabled | bool | `false` |  |
| kserve.servingruntime.xgbserver.image | string | `"kserve/xgbserver"` |  |
| kserve.servingruntime.xgbserver.tag | string | `""` |  |
| kserve.servingruntime.xgbserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.xgbserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.xgbserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.xgbserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.xgbserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.xgbserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.huggingfaceserver.disabled | bool | `false` |  |
| kserve.servingruntime.huggingfaceserver.image | string | `"kserve/huggingfaceserver"` |  |
| kserve.servingruntime.huggingfaceserver.tag | string | `""` |  |
| kserve.servingruntime.huggingfaceserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.huggingfaceserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.huggingfaceserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.huggingfaceserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.huggingfaceserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.huggingfaceserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.huggingfaceserver.lmcacheUseExperimental | string | `"True"` |  |
| kserve.servingruntime.huggingfaceserver.devShm.enabled | bool | `false` |  |
| kserve.servingruntime.huggingfaceserver.devShm.sizeLimit | string | `""` |  |
| kserve.servingruntime.huggingfaceserver.hostIPC.enabled | bool | `false` |  |
| kserve.servingruntime.huggingfaceserver_multinode.disabled | bool | `false` |  |
| kserve.servingruntime.huggingfaceserver_multinode.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.huggingfaceserver_multinode.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.huggingfaceserver_multinode.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.huggingfaceserver_multinode.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.huggingfaceserver_multinode.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.huggingfaceserver_multinode.shm.enabled | bool | `true` |  |
| kserve.servingruntime.huggingfaceserver_multinode.shm.sizeLimit | string | `"3Gi"` |  |
| kserve.servingruntime.tritonserver.disabled | bool | `false` |  |
| kserve.servingruntime.tritonserver.image | string | `"nvcr.io/nvidia/tritonserver"` |  |
| kserve.servingruntime.tritonserver.tag | string | `"23.05-py3"` |  |
| kserve.servingruntime.tritonserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.tritonserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.tritonserver.securityContext.runAsUser | int | `1000` |  |
| kserve.servingruntime.tritonserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.tritonserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.tritonserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.tritonserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.pmmlserver.disabled | bool | `false` |  |
| kserve.servingruntime.pmmlserver.image | string | `"kserve/pmmlserver"` |  |
| kserve.servingruntime.pmmlserver.tag | string | `""` |  |
| kserve.servingruntime.pmmlserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.pmmlserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.pmmlserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.pmmlserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.pmmlserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.pmmlserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.predictiveserver.disabled | bool | `false` |  |
| kserve.servingruntime.predictiveserver.image | string | `"kserve/predictiveserver"` |  |
| kserve.servingruntime.predictiveserver.tag | string | `""` |  |
| kserve.servingruntime.predictiveserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.predictiveserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.predictiveserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.predictiveserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.predictiveserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.predictiveserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.paddleserver.disabled | bool | `false` |  |
| kserve.servingruntime.paddleserver.image | string | `"kserve/paddleserver"` |  |
| kserve.servingruntime.paddleserver.tag | string | `""` |  |
| kserve.servingruntime.paddleserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.paddleserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.paddleserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.paddleserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.paddleserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.paddleserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.lgbserver.disabled | bool | `false` |  |
| kserve.servingruntime.lgbserver.image | string | `"kserve/lgbserver"` |  |
| kserve.servingruntime.lgbserver.tag | string | `""` |  |
| kserve.servingruntime.lgbserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.lgbserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.lgbserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.lgbserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.lgbserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.lgbserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.torchserve.disabled | bool | `false` |  |
| kserve.servingruntime.torchserve.image | string | `"pytorch/torchserve-kfs"` |  |
| kserve.servingruntime.torchserve.tag | string | `"0.9.0"` |  |
| kserve.servingruntime.torchserve.serviceEnvelopePlaceholder | string | `"{{.Labels.serviceEnvelope}}"` |  |
| kserve.servingruntime.torchserve.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.torchserve.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.torchserve.securityContext.runAsUser | int | `1000` |  |
| kserve.servingruntime.torchserve.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.torchserve.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.torchserve.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.torchserve.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.art.image | string | `"kserve/art-explainer"` |  |
| kserve.servingruntime.art.defaultVersion | string | `""` |  |
| kserve.servingruntime.art.imagePullSecrets | list | `[]` |  |
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
