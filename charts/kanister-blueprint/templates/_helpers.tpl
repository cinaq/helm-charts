{{/*
Expand the name of the chart.
*/}}
{{- define "kanister-blueprint.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kanister-blueprint.fullname" -}}
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
{{- define "kanister-blueprint.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kanister-blueprint.labels" -}}
helm.sh/chart: {{ include "kanister-blueprint.chart" . }}
{{ include "kanister-blueprint.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kanister-blueprint.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kanister-blueprint.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kanister-blueprint.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kanister-blueprint.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the roleName to use
*/}}
{{- define "kanister-blueprint.roleName" -}}
{{- if .Values.role.create }}
{{- default (include "kanister-blueprint.fullname" .) .Values.role.name }}
{{- else }}
{{- default "default" .Values.role.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the roleBinding to use
*/}}
{{- define "kanister-blueprint.roleBindingName" -}}
{{- if .Values.role.create }}
{{- default (include "kanister-blueprint.fullname" .) .Values.roleBinding.name }}
{{- else }}
{{- default "default" .Values.roleBinding.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the blueprint to use
*/}}
{{- define "kanister-blueprint.blueprintName" -}}
{{- if .Values.blueprint.create }}
{{- default (include "kanister-blueprint.fullname" .) .Values.blueprint.name }}
{{- else }}
{{- default "default" .Values.blueprint.name }}
{{- end }}
{{- end }}
