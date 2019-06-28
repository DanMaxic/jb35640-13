# global config
global:
  scrape_interval:     60s
  evaluation_interval: 30s
  scrape_timeout: 60s

# Alertmanager configuration
alerting:
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
       - "localhost:9093"

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  - "/opt/prometheus/alert_rules.yml"
  - "/opt/prometheus/alert_rules/*.yml"
scrape_configs:
  # The job name is added as a label 'job=<job_name>' to any timeseries scraped from this config.

  - job_name: 'prometheus'
    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'aws_cloudwatch_us-east-1'
    static_configs:
      - targets: ['localhost:9107']
  - job_name: 'aws_cloudwatch_eu-central-1'
    static_configs:
      - targets: ['localhost:9106']

  - job_name: 'aws_ec2'
    ec2_sd_configs:
      - region: ${aws_region}
        port: 9100
    relabel_configs:
      - source_labels: [__meta_ec2_tag_Name]
        target_label: name
      - source_labels: [__meta_ec2_tag_Owner]
        target_label: owner
      - source_labels: [__meta_ec2_tag_environment]
        target_label: environment
      - source_labels: [__meta_ec2_vpc_id]
        target_label: vpc_id
      - source_labels: [__meta_ec2_instance_type]
        target_label: instance_type
      - source_labels: [__meta_ec2_availability_zone]
        target_label: az
      - source_labels: [__meta_ec2_tag_Team]
        target_label: team
      - source_labels: [__meta_ec2_tag_aws_autoscaling_groupName]
        target_label: asg
      - source_labels: [__meta_ec2_instance_state]
        target_label: state

  - job_name: 'aws_ecs'
    file_sd_configs:
    - files:
      - /opt/prometheus/ecs_file_sd.yml
      refresh_interval: 5m
    relabel_configs:
      - source_labels: [__meta_ec2_instance_id]
        target_label: instance

  - job_name: 'aws_ecs_springboot'
    file_sd_configs:
    - files:
      - /opt/prometheus/ecs_springboot.yml
      refresh_interval: 5m
    relabel_configs:
      - source_labels: [__meta_ec2_instance_id]
        target_label: instance

${es_scraper}
${jenkins_scraper}
${federation}
