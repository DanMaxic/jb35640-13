global:
  smtp_smarthost: '${smtp_smarthost}'
  smtp_from: '${smtp_from}'
  smtp_auth_username: '${smtp_auth_username}'
  smtp_auth_password: '${smtp_auth_password}'

templates:
- '/opt/prometheus/alertmanager/templates/*.tmpl'

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 2h
  receiver: general-alerts
  routes:
  - match_re:
      service: ^(foo1|foo2|baz)$
    receiver: general-alerts
    routes:
    - match:
        severity: critical
      receiver: general-alerts
  - match:
      severity: slack
    receiver: general-alerts

inhibit_rules:
- source_match:
    severity: 'critical'
  target_match:
    severity: 'warning'
  equal: ['alertname', 'cluster', 'service']

receivers:
- name: general-alerts
  slack_configs:
  - api_url: ${slack_webhook_url}
    channel: '${slack_alerts_channel}'
    send_resolved: true
    text: '{{ template "custom_slack_message" . }}'
  email_configs:
  - to: '${alerts_to_email}'
    send_resolved: true
