{{/*
Expand the name of the chart.
*/}}
{{- define "kanister-actionset.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kanister-actionset.fullname" -}}
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
{{- define "kanister-actionset.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kanister-actionset.labels" -}}
helm.sh/chart: {{ include "kanister-actionset.chart" . }}
{{ include "kanister-actionset.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kanister-actionset.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kanister-actionset.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the secret to use
*/}}
{{- define "kanister-actionset.secretName" -}}
{{- if .Values.secret.create }}
{{- default (include "kanister-actionset.fullname" .) .Values.secret.name }}
{{- else }}
{{- default "default" .Values.secret.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the cronjob to use
*/}}
{{- define "kanister-actionset.cronJobName" -}}
{{- if .Values.cronJob.create }}
{{- default (include "kanister-actionset.fullname" .) .Values.cronJob.name }}
{{- else }}
{{- default "default" .Values.cronJob.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the actionset to use
*/}}
{{- define "kanister-actionset.actionSetName" -}}
{{- if .Values.actionSet.create }}
{{- default (include "kanister-actionset.fullname" .) .Values.actionSet.name }}
{{- else }}
{{- default "default" .Values.actionSet.name }}
{{- end }}
{{- end }}