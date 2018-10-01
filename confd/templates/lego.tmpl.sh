#!/bin/sh

http_proxy=""
https_proxy=""

{{ if exists "/proxy/http_proxy" }}
http_proxy="{{ getv "/proxy/http_proxy" }}"
{{ end }}
{{ if exists "/proxy/https_proxy" }}
https_proxy="{{ getv "/proxy/https_proxy" }}"
{{ end }}

export http_proxy
export https_proxy

{{ if exists "/ovh/endpoint" }}
export OVH_ENDPOINT="{{ getv "/ovh/endpoint" }}"
{{ end }}
{{ if exists "/ovh/application_key" }}
export OVH_APPLICATION_KEY="{{ getv "/ovh/application_key" }}"
{{ end }}
{{ if exists "/ovh/application_secret" }}
export OVH_APPLICATION_SECRET="{{ getv "/ovh/application_secret" }}"
{{ end }}
{{ if exists "/ovh/consumer_key" }}
export OVH_CONSUMER_KEY="{{ getv "/ovh/consumer_key" }}"
{{ end }}

{{ range gets "/certs/*" }}
{{ $data := json .Value }}

action="run"
if [ -f /.lego/certificates/certificates/{{ $data.cname }}.crt ]; then
  action="renew --days {{ getv "/renew_threshold_in_days" }}"
fi

echo "We will make a ${action} action"

/bin/lego --dns "{{ $data.dns_provider }}" --domains "{{ $data.cname }}" \
  -a --email "{{ $data.email }}" --server "{{ $data.lego_server }}" \
  --path "/.lego/certificates" ${action}
{{ end }}
