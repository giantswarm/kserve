{{/*
Expand the name of the chart.
*/}}
{{- define "kserve-runtime-configs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "kserve-runtime-configs.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label. A label value is at
most 63 characters and begins and ends alphanumeric: the cut of a long version
(a branch build's <version>-dev.<branch>.<date>.<time>.<sha>, or the
<version>+<digest> helm-controller installs) can land on any run of ".", "_"
(from "+") and "-", so the whole run is trimmed.
*/}}
{{- define "kserve-runtime-configs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimAll "-._" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kserve-runtime-configs.labels" -}}
helm.sh/chart: {{ include "kserve-runtime-configs.chart" . }}
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
{{ include "kserve-runtime-configs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kserve-runtime-configs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kserve-runtime-configs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Image of every container of a parsed LLMInferenceServiceConfig preset, keyed by container name.

Usage: {{- $images := dict }}{{- include "kserve-runtime-configs.presetContainerImages" (list $preset $images) }}

Walks the whole object, so it finds containers and initContainers wherever a preset keeps them
(spec.template, spec.worker, spec.prefill.template, spec.prefill.worker,
spec.router.scheduler.template). A name used more than once -- the leader and the worker of a
data-parallel preset both run `main` -- collects every image it runs.
*/}}
{{- define "kserve-runtime-configs.presetContainerImages" -}}
{{- $node := index . 0 -}}
{{- $images := index . 1 -}}
{{- if kindIs "map" $node -}}
  {{- range $key, $value := $node -}}
    {{- if and (has $key (list "containers" "initContainers")) (kindIs "slice" $value) -}}
      {{- range $container := $value -}}
        {{- if and (kindIs "map" $container) (hasKey $container "name") (hasKey $container "image") -}}
          {{- $_ := set $images $container.name (append (get $images $container.name | default list) $container.image) -}}
        {{- end -}}
      {{- end -}}
    {{- else -}}
      {{- include "kserve-runtime-configs.presetContainerImages" (list $value $images) -}}
    {{- end -}}
  {{- end -}}
{{- else if kindIs "slice" $node -}}
  {{- range $item := $node -}}
    {{- include "kserve-runtime-configs.presetContainerImages" (list $item $images) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
One preset document with `kserve.llmisvcConfigs.images.<preset>` applied.

Usage: {{ include "kserve-runtime-configs.overridePresetImages" (list $document $preset $overrides) }}

$document is the preset as rendered so far (its registry already rewritten), $preset its name,
$overrides the container name -> image reference map from the values. The document stays
upstream's text: only the `image:` lines of the named containers change, every occurrence -- both
`main` containers of a data-parallel preset run the same build. The render fails for a container
the preset does not have, for a value that is not an image reference, and when the line-wise
rewrite could touch another container (two containers on one image, or the two `main`s of a preset
on different ones); the result is parsed again to prove every container ended up as intended.
*/}}
{{- define "kserve-runtime-configs.overridePresetImages" -}}
{{- $document := index . 0 -}}
{{- $preset := index . 1 -}}
{{- $overrides := index . 2 -}}
{{- $before := dict -}}
{{- include "kserve-runtime-configs.presetContainerImages" (list (fromYaml $document) $before) -}}
{{- range $container, $image := $overrides -}}
  {{- $key := printf "kserve.llmisvcConfigs.images.%s.%s" $preset $container -}}
  {{- if not (hasKey $before $container) -}}
    {{- fail (printf "%s: preset %s has no container %q (it has: %s)" $key $preset $container (keys $before | sortAlpha | join ", ")) -}}
  {{- end -}}
  {{- if not (regexMatch `^[^\s"'#]+$` (toString $image)) -}}
    {{- fail (printf "%s: %q is not an image reference" $key (toString $image)) -}}
  {{- end -}}
  {{- $current := index $before $container | uniq -}}
  {{- if ne (len $current) 1 -}}
    {{- fail (printf "%s: the preset's %q containers run different images (%s); the chart replaces images line by line" $key $container (join ", " $current)) -}}
  {{- end -}}
  {{- $from := first $current -}}
  {{- range $other, $otherImages := $before -}}
    {{- if and (ne $other $container) (has $from $otherImages) -}}
      {{- fail (printf "%s: containers %q and %q share the image %s; the chart replaces images line by line" $key $container $other $from) -}}
    {{- end -}}
  {{- end -}}
  {{- $document = replace (printf "image: %s\n" $from) (printf "image: %s\n" $image) $document -}}
{{- end -}}
{{- $after := dict -}}
{{- include "kserve-runtime-configs.presetContainerImages" (list (fromYaml $document) $after) -}}
{{- range $container, $images := $before -}}
  {{- $want := ternary (list (get $overrides $container | toString)) ($images | uniq) (hasKey $overrides $container) | sortAlpha -}}
  {{- $got := index $after $container | uniq | sortAlpha -}}
  {{- if ne (toJson $got) (toJson $want) -}}
    {{- fail (printf "kserve.llmisvcConfigs.images.%s: container %q renders %s, expected %s" $preset $container (join ", " $got) (join ", " $want)) -}}
  {{- end -}}
{{- end -}}
{{- $document -}}
{{- end -}}
