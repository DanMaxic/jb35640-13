# Elasticsearch
- name: elasticsearch
  rules:
  - record: elasticsearch_filesystem_data_used_percent
    expr: 100 * (elasticsearch_filesystem_data_size_bytes - elasticsearch_filesystem_data_free_bytes)
      / elasticsearch_filesystem_data_size_bytes
  - record: elasticsearch_filesystem_data_free_percent
    expr: 100 - elasticsearch_filesystem_data_used_percent
  - alert: ElasticsearchTooFewNodesRunning
    expr: elasticsearch_cluster_health_number_of_nodes < 3
    for: 5m
    labels:
      severity: slack
    annotations:
      description: "There are only {{$value}} < 3 ElasticSearch nodes running"
      summary: "ElasticSearch running on less than 3 nodes"
  - alert: ElasticsearchHeapTooHigh
    expr: elasticsearch_jvm_memory_used_bytes{area="heap"} / elasticsearch_jvm_memory_max_bytes{area="heap"} > 0.85
    for: 10m
    labels:
      severity: slack
    annotations:
      description: "The heap usage is over 85% for 10m"
      summary: "ElasticSearch node {{$labels.node}} heap usage is high"