---
region: ${aws_region}
metrics:
 - aws_namespace: AWS/Billing
   aws_metric_name: EstimatedCharges
   aws_dimensions: [ServiceName, Currency]
   aws_dimension_select:
     Currency: [USD]
   range_seconds: 28800
   set_timestamp: false
   period_seconds: 3600
