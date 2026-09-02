{{/*
Expand the name of the chart.
*/}}
{{- define "kserve-llmisvc-crd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kserve-llmisvc-crd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kserve-llmisvc-crd.labels" -}}
helm.sh/chart: {{ include "kserve-llmisvc-crd.chart" . }}
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
{{ include "kserve-llmisvc-crd.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kserve-llmisvc-crd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kserve-llmisvc-crd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
