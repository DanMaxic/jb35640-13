output "es_dns_name" {
  value = "${module.es_cluster.dns_name}"
}

output "kibana_dns_name" {
  value = "${module.kibana.dns_name}"
}
