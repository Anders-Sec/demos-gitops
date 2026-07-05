{{/* Base name */}}
{{- define "webapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Fully qualified release name */}}
{{- define "webapp.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Common labels */}}
{{- define "webapp.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "webapp.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{/* Selector labels (instance-wide) */}}
{{- define "webapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "webapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* ServiceAccount name */}}
{{- define "webapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "webapp.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/* Name of the ESO-synced secret consumed by the backend */}}
{{- define "webapp.secretName" -}}
{{- default (printf "%s-secrets" (include "webapp.fullname" .)) .Values.externalSecrets.targetSecretName -}}
{{- end -}}

{{/* Resolve an image reference: registry/repository:tag (tag falls back to appVersion) */}}
{{- define "webapp.image" -}}
{{- $top := index . 0 -}}
{{- $img := index . 1 -}}
{{- $tag := $img.tag | default $top.Chart.AppVersion -}}
{{- printf "%s/%s:%s" $top.Values.image.registry $img.repository $tag -}}
{{- end -}}
