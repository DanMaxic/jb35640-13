  - job_name: 'Jenkins'
    metrics_path: /jenkins/prometheus
    scheme: https
    tls_config:
      insecure_skip_verify: true
    static_configs:
      - targets: ['${jenkins_domain_name}']
    metric_relabel_configs:
      - action: replace
        source_labels: [exported_job]
        target_label: jenkins_job
      - action: labeldrop
        regex: exported_job
