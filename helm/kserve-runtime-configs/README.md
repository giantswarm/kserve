# kserve-runtime-configs

![Version: [[ .Version ]]](https://img.shields.io/badge/Version-[[ .Version ]]-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.20.0](https://img.shields.io/badge/AppVersion-v0.20.0-informational?style=flat-square)

KServe Runtime Configurations - ClusterServingRuntimes and LLM Inference Configs

**Homepage:** <https://kserve.github.io/website/>

## Installing the Chart

To install the chart, run the following:

```console
$ helm install kserve-runtime-configs oci://ghcr.io/kserve/charts/kserve-runtime-configs --set kserve.llmisvcConfigs.enabled=true --version [[ .Version ]]
```

## LLMInferenceServiceConfig presets

`kserve.llmisvcConfigs.enabled: true` ships KServe's well-known `LLMInferenceServiceConfig`
presets (`files/llmisvcconfigs/resources.yaml`, upstream's file verbatim) into the release
namespace -- the llmisvc controller looks a config up in the `LLMInferenceService`'s namespace and
then in its own. Every `LLMInferenceService` fails at config lookup without them.

At render time every `ghcr.io/llm-d/` image the presets pin is rewritten to
`kserve.llmisvcConfigs.imageRegistry`. The default, `gsoci.azurecr.io/giantswarm/`, is the mirror
set [giantswarm/llm-d](https://github.com/giantswarm/llm-d) keeps digest-identical to upstream at
the same tags (`llm-d-cuda`, `llm-d-router-endpoint-picker`, `llm-d-router-disagg-sidecar`,
`llm-d-uds-tokenizer`, the two latency predictors); set it to `ghcr.io/llm-d/` to render
upstream's images. The tags are the presets', never a value.

The [agent-platform](https://github.com/giantswarm/agent-platform) chart consumes this chart as its
`kserve-runtime-configs` component with `kserve.llmisvcConfigs.enabled: true` and
`kserve.servingruntime.enabled: false`, passing no registry value.

### Per-preset image override

`kserve.llmisvcConfigs.images.<preset>.<container>` replaces the image of one container of one
preset, after the registry rewrite; every other preset renders as upstream ships it. `<preset>` is
the preset's `metadata.name`, `<container>` the container's name inside it: `main` is the runtime
container of every preset (vLLM in the worker presets, the endpoint picker in
`kserve-config-llm-scheduler`), `llm-d-routing-sidecar` the routing sidecar the two decode presets
run as an init container, `tokenizer`, `training-server` and `prediction-server` the scheduler's
helpers. A data-parallel preset runs `main` twice, as leader and as worker; both get the override.
The render fails for a preset or container the file does not have.

The case it exists for: GPU nodes that need another build of the same runtime -- arm64
unified-memory Blackwell nodes need an arm64 vLLM build in place of `llm-d-cuda` -- name it once per
preset instead of overriding `spec.template` in every preset that runs on them:

```yaml
kserve:
  llmisvcConfigs:
    enabled: true
    images:
      kserve-config-llm-template:
        main: gsoci.azurecr.io/giantswarm/vllm-b12x:2026-09-18
      kserve-config-llm-worker-data-parallel:
        main: gsoci.azurecr.io/giantswarm/vllm-b12x:2026-09-18
```

**Precedence.** Three layers, each over the previous one: the registry rewrite (`imageRegistry`)
changes where every `ghcr.io/llm-d/` image is pulled from; the per-preset image (`images`) changes
which image a named container of a named preset runs; the `LLMInferenceService`'s own spec, which
KServe merges over the well-known configs the service refers to, wins over both -- a preset's own
`spec.template` (what model-manager copies into the service verbatim) stays the per-preset
exception, the override is for an installation's hardware.

**What a `main` override must provide.** The preset keeps its command: the worker presets run
`/bin/bash -c '<script>' -- <args>`, where the script probes `vllm --version`, picks the flags that
version supports (`--disable-access-log-for-endpoints`, `--shutdown-timeout`, `--kv-transfer-config`)
with `grep`, `awk` and `sort -V`, and ends in `eval "exec vllm serve /mnt/models --served-model-name …
--port … $@"`; the data-parallel presets add `--api-server-count` and the `--data-parallel-*` flags.
An override image therefore needs `/bin/bash`, GNU coreutils and awk, a `vllm` on `PATH` whose
`serve` accepts those flags, the model under `/mnt/models`, `HF_HUB_CACHE=/models`, and `/health`
on the preset's serving port, and it runs under the preset's non-root security context. An
`llm-d-routing-sidecar` override must ship `/app/pd-sidecar` with the flags of the
`llm-d-router-disagg-sidecar` release the preset pins.

### Tracing preset

The llmisvc controller has no OpenTelemetry code of its own; the data plane exports. For every
`LLMInferenceService` whose spec carries `tracing` -- `tracing: {}` is enough -- the controller
appends `kserve-config-llm-tracing` to the configs it merges and turns the merged `spec.tracing`
into `--otlp-traces-endpoint`, `--collect-detailed-traces all` and the `OTEL_*` env of the vLLM
`main` container (decode and prefill), and into `--tracing=true` plus the same env on the endpoint
picker. A service without `tracing` exports nothing, whatever this preset says. Nobody lists the
preset in `baseRefs`.

Upstream's preset sends to `http://otel-collector:4317`, a Service that exists in no Giant Swarm
cluster. `kserve.llmisvcConfigs.tracing` sets its `exporterEndpoint`, `sampler` and `samplerArg`;
`podLabels` become the preset's `spec.labels`, which the controller copies onto the workload pod
template, so the pods that export -- and only those -- carry, for instance, the tenant label an OTLP
gateway routes a headerless export by. The exporters speak OTLP over gRPC and send no headers; the
spec has no protocol or header field. An `LLMInferenceService`'s own `spec.tracing` keys win over the
preset's. With no key set the preset renders as upstream ships it.

```yaml
kserve:
  llmisvcConfigs:
    enabled: true
    tracing:
      exporterEndpoint: http://otlp-gateway.kube-system.svc:4317
      podLabels:
        observability.giantswarm.io/tenant: giantswarm
```

## Classic ServingRuntimes

The Giant Swarm serving path is llm-d only: models are `LLMInferenceService`s composed from the
presets above. The classic `ClusterServingRuntime`s upstream ships (`files/runtimes`: tensorflow,
mlserver, sklearn, xgboost, huggingface, triton, pmml, predictive, paddle, lightgbm, autogluon,
torchserve, vllm) stay in the chart but carry no image: every `kserve.servingruntime.<runtime>.image`
is empty, so the chart references nothing outside `gsoci.azurecr.io`. `kserve.servingruntime.enabled`
defaults to `false`; with it on, a runtime renders only when its `image` is set (the huggingface
multinode runtime follows `huggingfaceserver.image`), and rendering fails when no runtime has one.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| KServe Team |  | <https://github.com/kserve/kserve> |

## Source Code

* <https://github.com/kserve/kserve>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kserve.version | string | `"v0.20.0"` |  |
| kserve.llmisvcConfigs.enabled | bool | `false` | Ship KServe's well-known `LLMInferenceServiceConfig` presets (`files/llmisvcconfigs`). |
| kserve.llmisvcConfigs.imageRegistry | string | `"gsoci.azurecr.io/giantswarm/"` | Registry prefix the presets' `ghcr.io/llm-d/` images are rewritten to at render time. The default is the digest-identical mirror set giantswarm/llm-d keeps on gsoci at the same tags; set `ghcr.io/llm-d/` to render upstream's images. |
| kserve.llmisvcConfigs.images | object | `{}` | Per-preset image overrides, applied after the registry rewrite: `<preset name>: {<container name>: <image reference>}`. `main` is the runtime container of every preset, `llm-d-routing-sidecar` the routing sidecar of the decode presets; every other preset renders unchanged. See the README for the precedence and what an override image must provide. |
| kserve.llmisvcConfigs.tracing.exporterEndpoint | string | `""` | OTLP/gRPC endpoint the vLLM and endpoint-picker exporters send spans to (`spec.tracing.exporterEndpoint`); upstream's is `http://otel-collector:4317`. vLLM and the endpoint picker export over gRPC only. |
| kserve.llmisvcConfigs.tracing.sampler | string | `""` | OpenTelemetry sampler (`spec.tracing.sampler`, `OTEL_TRACES_SAMPLER`); upstream's is `parentbased_traceidratio`. |
| kserve.llmisvcConfigs.tracing.samplerArg | string | `""` | Sampler argument (`spec.tracing.samplerArg`, `OTEL_TRACES_SAMPLER_ARG`), a ratio between 0 and 1 for the ratio samplers; upstream's is `"0.05"`. |
| kserve.llmisvcConfigs.tracing.podLabels | object | `{}` | Labels the preset adds to the pods of an `LLMInferenceService` with tracing on (`spec.labels`, which the controller copies onto the workload pod template), e.g. the label an OTLP gateway routes a headerless export by. Not the prefill or endpoint-picker pods. |
| kserve.servingruntime.enabled | bool | `false` | Render the classic `ClusterServingRuntime`s (`files/runtimes`). Not part of the Giant Swarm serving path, which is llm-d only: the chart ships no third-party runtime image, so a runtime renders only when its `image` is set, and the switch fails when none is. |
| kserve.servingruntime.modelNamePlaceholder | string | `"{{.Name}}"` |  |
| kserve.servingruntime.tensorflow.disabled | bool | `false` |  |
| kserve.servingruntime.tensorflow.image | string | `""` |  |
| kserve.servingruntime.tensorflow.tag | string | `"2.6.2"` |  |
| kserve.servingruntime.tensorflow.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.tensorflow.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.tensorflow.securityContext.runAsUser | int | `1000` |  |
| kserve.servingruntime.tensorflow.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.tensorflow.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.tensorflow.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.tensorflow.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.mlserver.disabled | bool | `false` |  |
| kserve.servingruntime.mlserver.image | string | `""` |  |
| kserve.servingruntime.mlserver.tag | string | `"1.5.0"` |  |
| kserve.servingruntime.mlserver.modelClassPlaceholder | string | `"{{.Labels.modelClass}}"` |  |
| kserve.servingruntime.mlserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.mlserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.mlserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.mlserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.mlserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.mlserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.sklearnserver.disabled | bool | `false` |  |
| kserve.servingruntime.sklearnserver.image | string | `""` |  |
| kserve.servingruntime.sklearnserver.tag | string | `""` |  |
| kserve.servingruntime.sklearnserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.sklearnserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.sklearnserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.sklearnserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.sklearnserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.sklearnserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.xgbserver.disabled | bool | `false` |  |
| kserve.servingruntime.xgbserver.image | string | `""` |  |
| kserve.servingruntime.xgbserver.tag | string | `""` |  |
| kserve.servingruntime.xgbserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.xgbserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.xgbserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.xgbserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.xgbserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.xgbserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.huggingfaceserver.disabled | bool | `false` |  |
| kserve.servingruntime.huggingfaceserver.image | string | `""` |  |
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
| kserve.servingruntime.tritonserver.image | string | `""` |  |
| kserve.servingruntime.tritonserver.tag | string | `"23.05-py3"` |  |
| kserve.servingruntime.tritonserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.tritonserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.tritonserver.securityContext.runAsUser | int | `1000` |  |
| kserve.servingruntime.tritonserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.tritonserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.tritonserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.tritonserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.pmmlserver.disabled | bool | `false` |  |
| kserve.servingruntime.pmmlserver.image | string | `""` |  |
| kserve.servingruntime.pmmlserver.tag | string | `""` |  |
| kserve.servingruntime.pmmlserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.pmmlserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.pmmlserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.pmmlserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.pmmlserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.pmmlserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.predictiveserver.disabled | bool | `false` |  |
| kserve.servingruntime.predictiveserver.image | string | `""` |  |
| kserve.servingruntime.predictiveserver.tag | string | `""` |  |
| kserve.servingruntime.predictiveserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.predictiveserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.predictiveserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.predictiveserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.predictiveserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.predictiveserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.paddleserver.disabled | bool | `false` |  |
| kserve.servingruntime.paddleserver.image | string | `""` |  |
| kserve.servingruntime.paddleserver.tag | string | `""` |  |
| kserve.servingruntime.paddleserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.paddleserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.paddleserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.paddleserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.paddleserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.paddleserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.lgbserver.disabled | bool | `false` |  |
| kserve.servingruntime.lgbserver.image | string | `""` |  |
| kserve.servingruntime.lgbserver.tag | string | `""` |  |
| kserve.servingruntime.lgbserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.lgbserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.lgbserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.lgbserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.lgbserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.lgbserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.autogluonserver.disabled | bool | `false` |  |
| kserve.servingruntime.autogluonserver.image | string | `""` |  |
| kserve.servingruntime.autogluonserver.tag | string | `""` |  |
| kserve.servingruntime.autogluonserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.autogluonserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.autogluonserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.autogluonserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.autogluonserver.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.autogluonserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.torchserve.disabled | bool | `false` |  |
| kserve.servingruntime.torchserve.image | string | `""` |  |
| kserve.servingruntime.torchserve.tag | string | `"0.9.0"` |  |
| kserve.servingruntime.torchserve.serviceEnvelopePlaceholder | string | `"{{.Labels.serviceEnvelope}}"` |  |
| kserve.servingruntime.torchserve.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.torchserve.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.torchserve.securityContext.runAsUser | int | `1000` |  |
| kserve.servingruntime.torchserve.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.torchserve.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.torchserve.securityContext.runAsNonRoot | bool | `true` |  |
| kserve.servingruntime.torchserve.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.vllmserver.disabled | bool | `false` |  |
| kserve.servingruntime.vllmserver.image | string | `""` |  |
| kserve.servingruntime.vllmserver.tag | string | `"latest"` |  |
| kserve.servingruntime.vllmserver.lmcacheUseExperimental | string | `"True"` |  |
| kserve.servingruntime.vllmserver.imagePullSecrets | list | `[]` |  |
| kserve.servingruntime.vllmserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| kserve.servingruntime.vllmserver.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kserve.servingruntime.vllmserver.securityContext.privileged | bool | `false` |  |
| kserve.servingruntime.vllmserver.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kserve.servingruntime.vllmserver.devShm.enabled | bool | `false` |  |
| kserve.servingruntime.vllmserver.devShm.sizeLimit | string | `""` |  |
| kserve.servingruntime.vllmserver.hostIPC.enabled | bool | `false` |  |
| kserve.servingruntime.art.image | string | `"gsoci.azurecr.io/giantswarm/art-explainer"` |  |
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
