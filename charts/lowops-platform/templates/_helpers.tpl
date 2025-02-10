{{/*
Expand the name of the chart.
*/}}
{{- define "lowops.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lowops.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "lowops.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lowops.labels" -}}
helm.sh/chart: {{ include "lowops.chart" . }}
{{ include "lowops.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lowops.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lowops.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "lowops.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "lowops.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the lowops platform configuration
*/}}
{{- define "lowops.platformConfig" -}}
{{- $config := .Values.lowops.config }}
{{- $yamlValues := "" }}
{{- range $role, $values := $config }}
{{- range $k, $v := $values }}
{{- if ne $v nil }}
{{- $yamlValues = printf "%s\n%s_%s_set: %s" $yamlValues $role $k (toString $v) }}
{{- end }}
{{- end }}
{{- end }}
{{- $yamlValues }}
{{- end }}
