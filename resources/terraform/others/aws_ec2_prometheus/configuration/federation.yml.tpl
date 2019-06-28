  - job_name: 'federation-${environment}'
    scrape_interval: 15s

    honor_labels: true
    metrics_path: '/federate'

    params:
      'match[]':
        - '{job="aws_ec2"}'
        - '{job="aws_ecs"}'
        - '{job="aws_ecs_springboot"}'
        - '{__name__=~"job:.*"}'
    static_configs:
      - targets: ['${prometheus_target}']
        labels:
          environment: '${environment}'
