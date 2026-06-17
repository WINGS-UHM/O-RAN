{{- define "fiveg.name" -}}
{{- default .Chart.Name .Values.releaseName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "fiveg.labels" -}}
app.kubernetes.io/name: {{ include "fiveg.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "fiveg.image" -}}
{{- printf "%s:%s" .repository .tag -}}
{{- end -}}
