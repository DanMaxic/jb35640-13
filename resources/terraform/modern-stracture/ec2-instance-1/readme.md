****nex-svc-crm-external-ui****

**manualy imported resources into tfstate:**
- nex-svc-crms-internal-ui (aws_cloudwatch_log_group)

**init command**
```$xslt
terraform init \
    -backend-config=deployment-profiles/PROD/beckend \
    -var-file=deployment-profiles/PROD/envconfig.tfvars \
    -backend=true \
    -input=false \
    src/terraform/

```
**refresh command**
```$xslt
terraform refresh \
    -var-file=deployment-profiles/PROD/envconfig.tfvars \
    -target=aws_alb_target_group.service_alb_target_group \
    -input=false \
    src/terraform/

```
**import command:**

```
terraform import \
    -var-file=deployment-profiles/PROD/envconfig.tfvars \
    -config=src/terraform/ \
    aws_cloudwatch_log_group.service_log_group nex-svc-crms-internal-ui
```

**Apply command:**

```
terraform apply \
    -refresh=true \
    -auto-approve \
    -var-file=deployment-profiles/PROD/envconfig.tfvars \
    src/terraform/ 
```


