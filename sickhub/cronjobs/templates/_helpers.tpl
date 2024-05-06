{{/*
Expand the name of the chart.
*/}}
{{- define "cronjobs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cronjobs.fullname" -}}
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
{{- define "cronjobs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cronjobs.labels" -}}
helm.sh/chart: {{ include "cronjobs.chart" . }}
{{ include "cronjobs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cronjobs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cronjobs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cronjobs.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cronjobs.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the role to use
*/}}
{{- define "cronjobs.roleName" -}}
{{- if .Values.role.create }}
{{- default (include "cronjobs.fullname" .) .Values.role.name }}
{{- else }}
{{- default "default" .Values.role.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the rolebinding to use - defaults to the role name
*/}}
{{- define "cronjobs.roleBindingName" -}}
{{- if .Values.role.create }}
{{- default (include "cronjobs.fullname" .) .Values.role.name }}
{{- else }}
{{- default "default" .Values.role.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the cluster role to use
*/}}
{{- define "cronjobs.clusterroleName" -}}
{{- if .Values.clusterrole.create }}
{{- default (include "cronjobs.fullname" .) .Values.clusterrole.name }}
{{- else }}
{{- default "default" .Values.clusterrole.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the cluster rolebinding to use - defaults to the cluster role name
*/}}
{{- define "cronjobs.clusterroleBindingName" -}}
{{- if .Values.clusterrole.create }}
{{- default (include "cronjobs.fullname" .) .Values.clusterrole.name }}
{{- else }}
{{- default "default" .Values.clusterrole.name }}
{{- end }}
{{- end }}

{{/*
Namespace to be released into
*/}}
{{- define "cronjobs.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride }}
{{- end }}
