---
region: eu-central-1
metrics:
# - aws_namespace: AWS/EBS
#   aws_metric_name: VolumeReadBytes
#   aws_dimensions: [VolumeId]
#   aws_statistics: [Average]
# - aws_namespace: AWS/EBS
#   aws_metric_name: VolumeWriteBytes
#   aws_dimensions: [VolumeId]
#   aws_statistics: [Average]
# - aws_namespace: AWS/EBS
#   aws_metric_name: VolumeReadOps
#   aws_dimensions: [VolumeId]
#   aws_statistics: [Average]
# - aws_namespace: AWS/EBS
#   aws_metric_name: VolumeWriteOps
#   aws_dimensions: [VolumeId]
#   aws_statistics: [Average]
# - aws_namespace: AWS/EBS
#   aws_metric_name: VolumeTotalReadTime
#   aws_dimensions: [VolumeId]
# - aws_namespace: AWS/EBS
#   aws_metric_name: VolumeTotalWriteTime
#   aws_dimensions: [VolumeId]
# - aws_namespace: AWS/EBS
#   aws_metric_name: VolumeIdleTime
#   aws_dimensions: [VolumeId]
# - aws_namespace: AWS/EBS
#   aws_metric_name: VolumeQueueLength
#   aws_dimensions: [VolumeId]
# - aws_namespace: AWS/EBS
#   aws_metric_name: VolumeThroughputPercentage
#   aws_dimensions: [VolumeId]
# - aws_namespace: AWS/EBS
#   aws_metric_name: VolumeConsumedReadWriteOps
#   aws_dimensions: [VolumeId]
# - aws_namespace: AWS/EBS
#   aws_metric_name: BurstBalance
#   aws_dimensions: [VolumeId]

 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: ActiveConnectionCount
   aws_dimensions: [LoadBalancer]
   aws_statistics: [Sum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: ClientTLSNegotiationErrorCount
   aws_dimensions: [LoadBalancer]
   aws_statistics: [Sum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: ConsumedLCUs
   aws_dimensions: [LoadBalancer]
   aws_statistics: [Maximum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: HTTPCode_ELB_4XX_Count
   aws_dimensions: [LoadBalancer]
   aws_statistics: [Sum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: HTTPCode_ELB_5XX_Count
   aws_dimensions: [LoadBalancer]
   aws_statistics: [Sum]
# - aws_namespace: AWS/ApplicationELB
#   aws_metric_name: NewConnectionCount
#   aws_dimensions: [LoadBalancer]
#   aws_statistics: [Sum]
# - aws_namespace: AWS/ApplicationELB
#   aws_metric_name: ProcessedBytes
#   aws_dimensions: [LoadBalancer]
#   aws_statistics: [Sum]
# - aws_namespace: AWS/ApplicationELB
#   aws_metric_name: RejectedConnectionCount
#   aws_dimensions: [LoadBalancer]
#   aws_statistics: [Sum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: RequestCount
   aws_dimensions: [TargetGroup, LoadBalancer]
   aws_statistics: [Sum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: HealthyHostCount
   aws_dimensions: [TargetGroup, LoadBalancer]
   aws_statistics: [Average]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: HTTPCode_Target_2XX_Count
   aws_dimensions: [TargetGroup, LoadBalancer]
   aws_statistics: [Sum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: HTTPCode_Target_3XX_Count
   aws_dimensions: [TargetGroup, LoadBalancer]
   aws_statistics: [Sum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: HTTPCode_Target_4XX_Count
   aws_dimensions: [TargetGroup, LoadBalancer]
   aws_statistics: [Sum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: HTTPCode_Target_5XX_Count
   aws_dimensions: [TargetGroup, LoadBalancer]
   aws_statistics: [Sum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: RequestCountPerTarget
   aws_dimensions: [TargetGroup]
   aws_statistics: [Sum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: TargetConnectionErrorCount
   aws_dimensions: [TargetGroup, LoadBalancer]
   aws_statistics: [Sum]
# - aws_namespace: AWS/ApplicationELB
#   aws_metric_name: TargetTLSNegotiationErrorCount
#   aws_dimensions: [TargetGroup, LoadBalancer]
#   aws_statistics: [Sum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: TargetResponseTime
   aws_dimensions: [TargetGroup, LoadBalancer]
   aws_statistics: [Average]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: UnHealthyHostCount
   aws_dimensions: [TargetGroup, LoadBalancer]
   aws_statistics: [Maximum]
 - aws_namespace: AWS/ApplicationELB
   aws_metric_name: UnHealthyHostCount
   aws_dimensions: [TargetGroup, LoadBalancer]
   aws_statistics: [Sum]

# - aws_namespace: AWS/EC2
#   aws_metric_name: CPUUtilization
#   aws_dimensions: [InstanceId]
# - aws_namespace: AWS/EC2
#   aws_metric_name: DiskReadOps
#   aws_dimensions: [InstanceId]
# - aws_namespace: AWS/EC2
#   aws_metric_name: DiskWriteOps
#   aws_dimensions: [InstanceId]
# - aws_namespace: AWS/EC2
#   aws_metric_name: DiskReadBytes
#   aws_dimensions: [InstanceId]
# - aws_namespace: AWS/EC2
#   aws_metric_name: DiskWriteBytes
#   aws_dimensions: [InstanceId]
# - aws_namespace: AWS/EC2
#   aws_metric_name: NetworkIn
#   aws_dimensions: [InstanceId]
# - aws_namespace: AWS/EC2
#   aws_metric_name: NetworkOut
#   aws_dimensions: [InstanceId]
# - aws_namespace: AWS/EC2
#   aws_metric_name: NetworkPacketsIn
#   aws_dimensions: [InstanceId]
# - aws_namespace: AWS/EC2
#   aws_metric_name: NetworkPacketsOut
#   aws_dimensions: [InstanceId]
# - aws_namespace: AWS/EC2
#   aws_metric_name: StatusCheckFailed
#   aws_dimensions: [InstanceId]
# - aws_namespace: AWS/EC2
#   aws_metric_name: StatusCheckFailed_Instance
#   aws_dimensions: [InstanceId]
# - aws_namespace: AWS/EC2
#   aws_metric_name: StatusCheckFailed_System
#   aws_dimensions: [InstanceId]

 - aws_namespace: AWS/ECS
   aws_metric_name: CPUReservation
   aws_dimensions: [ClusterName]
   aws_statistics: [Average]
 - aws_namespace: AWS/ECS
   aws_metric_name: CPUUtilization
   aws_dimensions: [ClusterName, ServiceName]
   aws_statistics: [Average]
 - aws_namespace: AWS/ECS
   aws_metric_name: MemoryReservation
   aws_dimensions: [ClusterName]
   aws_statistics: [Average]
 - aws_namespace: AWS/ECS
   aws_metric_name: MemoryUtilization
   aws_dimensions: [ClusterName, ServiceName]
   aws_statistics: [Average]

 - aws_namespace: AWS/RDS
   aws_metric_name: CPUUtilization
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: DatabaseConnections
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: DiskQueueDepth
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: FreeableMemory
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: FreeStorageSpace
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: NetworkReceiveThroughput
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: NetworkTransmitThroughput
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: ReadIOPS
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: ReadLatency
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: ReadThroughput
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: SwapUsage
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: WriteIOPS
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: WriteLatency
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]
 - aws_namespace: AWS/RDS
   aws_metric_name: WriteThroughput
   aws_dimensions: [DBInstanceIdentifier]
   aws_statistics: [Average]

 - aws_namespace: AWS/SES
   aws_metric_name: Send
 - aws_namespace: AWS/SES
   aws_metric_name: Reject
 - aws_namespace: AWS/SES
   aws_metric_name: Bounce
 - aws_namespace: AWS/SES
   aws_metric_name: Complaint
 - aws_namespace: AWS/SES
   aws_metric_name: Delivery
 - aws_namespace: AWS/SES
   aws_metric_name: Open
 - aws_namespace: AWS/SES
   aws_metric_name: Click
 - aws_namespace: AWS/SES
   aws_metric_name: Rendering Failure
 - aws_namespace: AWS/SES
   aws_metric_name: Reputation.BounceRate
 - aws_namespace: AWS/SES
   aws_metric_name: Reputation.ComplaintRate

 - aws_namespace: AWS/SNS
   aws_metric_name: NumberOfMessagesPublished
   aws_dimensions: [Application]
   aws_statistics: [Sum]
 - aws_namespace: AWS/SNS
   aws_metric_name: NumberOfNotificationsDelivered
   aws_dimensions: [Application]
   aws_statistics: [Sum]
 - aws_namespace: AWS/SNS
   aws_metric_name: NumberOfNotificationsFailed
   aws_dimensions: [Application]
   aws_statistics: [Sum]
 - aws_namespace: AWS/SNS
   aws_metric_name: NumberOfNotificationsFilteredOut
   aws_dimensions: [Application]
   aws_statistics: [Sum]
 - aws_namespace: AWS/SNS
   aws_metric_name: NumberOfNotificationsFilteredOut-NoMessageAttributes
   aws_dimensions: [Application]
   aws_statistics: [Sum]
 - aws_namespace: AWS/SNS
   aws_metric_name: NumberOfNotificationsFilteredOut-InvalidAttributes
   aws_dimensions: [Application]
   aws_statistics: [Sum]
 - aws_namespace: AWS/SNS
   aws_metric_name: PublishSize
   aws_dimensions: [Application]
   aws_statistics: [Average]
 - aws_namespace: AWS/SNS
   aws_metric_name: SMSMonthToDateSpentUSD
   aws_dimensions: [Application]
   aws_statistics: [Maximum]
 - aws_namespace: AWS/SNS
   aws_metric_name: SMSSuccessRate
   aws_dimensions: [Application]
   aws_statistics: [Sum]

 - aws_namespace: AWS/SQS
   aws_metric_name: ApproximateAgeOfOldestMessage
   aws_dimensions: [QueueName]
   aws_statistics: [Average]
 - aws_namespace: AWS/SQS
   aws_metric_name: ApproximateNumberOfMessagesDelayed
   aws_dimensions: [QueueName]
   aws_statistics: [Average]
 - aws_namespace: AWS/SQS
   aws_metric_name: ApproximateNumberOfMessagesNotVisible
   aws_dimensions: [QueueName]
   aws_statistics: [Average]
 - aws_namespace: AWS/SQS
   aws_metric_name: ApproximateNumberOfMessagesVisible
   aws_dimensions: [QueueName]
   aws_statistics: [Average]
 - aws_namespace: AWS/SQS
   aws_metric_name: NumberOfEmptyReceives
   aws_dimensions: [QueueName]
   aws_statistics: [Average]
 - aws_namespace: AWS/SQS
   aws_metric_name: NumberOfMessagesDeleted
   aws_dimensions: [QueueName]
   aws_statistics: [Average]
 - aws_namespace: AWS/SQS
   aws_metric_name: NumberOfMessagesReceived
   aws_dimensions: [QueueName]
   aws_statistics: [Average]
 - aws_namespace: AWS/SQS
   aws_metric_name: NumberOfMessagesSent
   aws_dimensions: [QueueName]
   aws_statistics: [Average]
 - aws_namespace: AWS/SQS
   aws_metric_name: SentMessageSize
   aws_dimensions: [QueueName]
   aws_statistics: [Average]

 - aws_namespace: AWS/S3
   aws_metric_name: AllRequests
   aws_dimensions: [BucketName]
   aws_statistics: [Sum]
 - aws_namespace: AWS/S3
   aws_metric_name: GetRequests
   aws_dimensions: [BucketName]
   aws_statistics: [Sum]
 - aws_namespace: AWS/S3
   aws_metric_name: PutRequests
   aws_dimensions: [BucketName]
   aws_statistics: [Sum]
 - aws_namespace: AWS/S3
   aws_metric_name: DeleteRequests
   aws_dimensions: [BucketName]
   aws_statistics: [Sum]
 - aws_namespace: AWS/S3
   aws_metric_name: HeadRequests
   aws_dimensions: [BucketName]
   aws_statistics: [Sum]
 - aws_namespace: AWS/S3
   aws_metric_name: PostRequests
   aws_dimensions: [BucketName]
   aws_statistics: [Sum]
 - aws_namespace: AWS/S3
   aws_metric_name: SelectRequests
   aws_dimensions: [BucketName]
   aws_statistics: [Sum]
 - aws_namespace: AWS/S3
   aws_metric_name: ListRequests
   aws_dimensions: [BucketName]
   aws_statistics: [Sum]
 - aws_namespace: AWS/S3
   aws_metric_name: BytesDownloaded
   aws_dimensions: [BucketName]
   aws_statistics: [Average]
 - aws_namespace: AWS/S3
   aws_metric_name: BytesUploaded
   aws_dimensions: [BucketName]
   aws_statistics: [Average]
 - aws_namespace: AWS/S3
   aws_metric_name: 4xxErrors
   aws_dimensions: [BucketName]
   aws_statistics: [Average]
 - aws_namespace: AWS/S3
   aws_metric_name: 5xxErrors
   aws_dimensions: [BucketName]
   aws_statistics: [Average]
 - aws_namespace: AWS/S3
   aws_metric_name: FirstByteLatency
   aws_dimensions: [BucketName]
   aws_statistics: [Average]
 - aws_namespace: AWS/S3
   aws_metric_name: TotalRequestLatency
   aws_dimensions: [BucketName]
   aws_statistics: [Average]
 - aws_namespace: AWS/S3
   aws_metric_name: BucketSizeBytes
   aws_dimensions: [BucketName, StorageType]
   aws_statistics: [Average]
   set_timestamp: false
   range_seconds: 86400
 - aws_namespace: AWS/S3
   aws_metric_name: NumberOfObjects
   aws_dimensions: [BucketName, StorageType]
   aws_statistics: [Average]
   set_timestamp: false
   range_seconds: 86400
