#!/bin/sh

mkdir -p /.lego/certificates/certreq_hashsum 2>/dev/null || true

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
reqhashsum=$(echo "{{ base64Encode .Value }}" | sha256sum | cut -f1 -d' ')

if [ -f "/.lego/certificates/certreq_hashsum/{{ $data.cname }}.hash" ]; then
  if [ "$(cat /.lego/certificates/certreq_hashsum/{{ $data.cname }}.hash)" == "${reqhashsum}" ]; then
    action="renew --days {{ getv "/renew_threshold_in_days" }}"
  fi
fi

echo "We will make a ${action} action"

/bin/lego --dns "{{ $data.dns_provider }}" --domains "{{ $data.cname }}"{{ if $data.sans }}{{ range $i, $san := $data.sans }} --domains "{{ $san }}"{{ end }}{{ end }} \
  -a --email "{{ $data.email }}" --server "{{ $data.lego_server }}" \
  --path "/.lego/certificates" ${action}

if [ "$?" -eq "0" ]; then
  echo "${reqhashsum}" > /.lego/certificates/certreq_hashsum/{{ $data.cname }}.hash
fi

{{ end }}
