data "template_file" "cw_exporter_config-us-east-1" {
  template = "${file("${path.module}/configuration/cw_exporter_config-us-east-1.yml.tpl")}"
  count    = "${var.prometheus_node_count}"

  vars {
    aws_region = "${var.aws_region}"
  }
}

data "template_file" "cw_exporter_config-eu-central-1" {
  template = "${file("${path.module}/configuration/cw_exporter_config-eu-central-1.yml.tpl")}"
  count    = "${var.prometheus_node_count}"

  vars {
    aws_region = "${var.aws_region}"
  }
}

data "template_file" "alert_rules" {
  template = "${file("${path.module}/configuration/alert_rules.yml.tpl")}"
  count    = "${var.prometheus_node_count}"

  vars {
    aws_region = "${var.aws_region}"
    es_alerts  = "${var.es_url != "" ? file("${path.module}/configuration/es_alert_rules.yml.tpl"): ""}"
  }
}

data "template_file" "alertmgr_cfg" {
  template = "${file("${path.module}/configuration/simple.yml.tpl")}"
  count    = "${var.prometheus_node_count}"

  vars {
    slack_alerts_channel = "${var.slack_alerts_channel}"
    slack_webhook_url    = "${var.slack_webhook_url}"
    smtp_smarthost       = "${var.smtp_smarthost}"
    smtp_from            = "${var.smtp_from}"
    smtp_auth_username   = "${var.smtp_auth_username}"
    smtp_auth_password   = "${var.smtp_auth_password}"
    alerts_to_email      = "${var.alerts_to_email}"
  }
}

data "template_file" "prometheus_userdata" {
  template = "${file("${path.module}/configuration/prometheus-userdata.sh.tpl")}"
  count    = "${var.prometheus_node_count}"

  vars {
    device                    = "${var.device_name}"
    prometheus_s3_bucket_name = "${var.prometheus_s3_bucket_name}"
    # environment               = "${lookup(var.tags, "Environment")}"
    aws_region                = "${var.aws_region}"

    grafana_admin_password = "${var.grafana_admin_password}"
    grafana_db_endpoint    = "${aws_db_instance.grafana.endpoint}"

    es_url                   = "${var.es_url}"
    es_exporter_download_url = "${var.es_exporter_download_url}"
    prometheus_domain_name = "${var.prometheus_domain_name}"
    alertmanager_version = "${var.alertmanager_version}"
  }
}

data "template_file" "jenkins_yml" {
  template = "${file("${path.module}/configuration/jenkins_scraper.yml.tpl")}"
  count    = "${var.prometheus_node_count}"
  vars {
    jenkins_domain_name = "${var.jenkins_domain_name}"
  }
}

data "template_file" "prometheus_cfg" {
  template = "${file("${path.module}/configuration/prometheus.yml.tpl")}"
  count    = "${var.prometheus_node_count}"

  vars {
    aws_region     = "${var.aws_region}"
    es_scraper     = "${var.es_url != "" ? file("${path.module}/configuration/es_exporter_scraper.yml.tpl"): ""}"
    jenkins_scraper = "${var.jenkins_domain_name != "" ? "${data.template_file.jenkins_yml.rendered}": ""}"
    federation     = "${join("",data.template_file.federation_yml.*.rendered)}"
  }
}

data "template_file" "federation_yml" {
  template = "${file("${path.module}/configuration/federation.yml.tpl")}"
  count = "${length(var.federation_config)}"

  vars {
    environment = "${lookup(var.federation_config[count.index],"environment")}"
    prometheus_target = "${lookup(var.federation_config[count.index],"prometheus_target")}"
  }
}

resource "aws_s3_bucket_object" "prometheus-yml" {
  bucket     = "${var.prometheus_s3_bucket_name}"
  key        = "prometheus.yml"
  content    = "${data.template_file.prometheus_cfg.rendered}"
  etag       = "${md5(file("${path.module}/configuration/prometheus.yml.tpl"))}"
  depends_on = ["aws_s3_bucket.prometheus-bucket"]
}

# resource "aws_s3_bucket_object" "prom-node-install-script" {
#   bucket     = "${var.prometheus_s3_bucket_name}"
#   key        = "prometheus-install-node-exporter.sh"
#   source     = "configuration/prometheus-install-node-exporter.sh.tpl"
#   content    = "${data.template_file.cw_exporter_config-eu-central-1.rendered}"
#   etag       = "${md5(file("${path.module}/configuration/prometheus-install-node-exporter.sh.tpl"))}"
#   depends_on = ["aws_s3_bucket.prometheus-bucket"]
# }

resource "aws_s3_bucket_object" "prom-cw-cfg-eu-central-1" {
  bucket     = "${var.prometheus_s3_bucket_name}"
  key        = "cw_exporter_config-eu-central-1.yml"
  content    = "${data.template_file.cw_exporter_config-eu-central-1.rendered}"
  etag       = "${md5(file("${path.module}/configuration/cw_exporter_config-eu-central-1.yml.tpl"))}"
  depends_on = ["aws_s3_bucket.prometheus-bucket"]
}

resource "aws_s3_bucket_object" "prom-cw-cfg-us-east-1" {
  bucket     = "${var.prometheus_s3_bucket_name}"
  key        = "cw_exporter_config-us-east-1.yml"
  content    = "${data.template_file.cw_exporter_config-us-east-1.rendered}"
  etag       = "${md5(file("${path.module}/configuration/cw_exporter_config-us-east-1.yml.tpl"))}"
  depends_on = ["aws_s3_bucket.prometheus-bucket"]
}

resource "aws_s3_bucket_object" "alert-rules-cfg" {
  bucket     = "${var.prometheus_s3_bucket_name}"
  key        = "alert_rules.yml"
  content    = "${data.template_file.alert_rules.rendered}"
  etag       = "${md5(file("${path.module}/configuration/alert_rules.yml.tpl"))}"
  depends_on = ["aws_s3_bucket.prometheus-bucket"]
}

resource "aws_s3_bucket_object" "alert-mgr-cfg" {
  bucket     = "${var.prometheus_s3_bucket_name}"
  key        = "simple.yml"
  content    = "${data.template_file.alertmgr_cfg.rendered}"
  etag       = "${md5(file("${path.module}/configuration/simple.yml.tpl"))}"
  depends_on = ["aws_s3_bucket.prometheus-bucket"]
}

resource "aws_s3_bucket_object" "notifications-tmpl" {
  bucket     = "${var.prometheus_s3_bucket_name}"
  key        = "notifications.tmpl"
  source    = "${path.module}/configuration/notifications.tmpl"
  depends_on = ["aws_s3_bucket.prometheus-bucket"]
}

data "archive_file" "alert-rules-zip" {
  type = "zip"
  output_path = "${path.module}/configuration/rules.zip"
  source_dir = "${path.module}/configuration/rules/"
}

resource "aws_s3_bucket_object" "alert-rules-zip" {
  bucket     = "${var.prometheus_s3_bucket_name}"
  key        = "rules.zip"
  source    = "${path.module}/configuration/rules.zip"
  depends_on = ["aws_s3_bucket.prometheus-bucket"]
}
