output "prom_dns_name" {
  value = "${aws_alb.prom_alb.dns_name}"
}

output "grafana_dns_name" {
  value = "${aws_alb.grafana_alb.dns_name}"
}
