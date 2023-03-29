## Modules Tree
```terraform
.
├── main.tf
├── variables.tf
├── outputs.tf
└── modules
    ├── s3_bucket
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── certificate
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── versions.tf
    ├── dns
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── cloudfront
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```
## Requirements

No requirements.

## Providers

|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.76.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_uat_cert"></a> [uat\_cert](#module\_uat\_cert) | ./modules/certificate | n/a |
| <a name="module_uat_dns_validation_record"></a> [uat\_dns\_validation\_record](#module\_uat\_dns\_validation\_record) | ./modules/dns | n/a |
| <a name="module_uat_frontend_bucket"></a> [uat\_frontend\_bucket](#module\_uat\_frontend\_bucket) | ./modules/s3_bucket | n/a |
| <a name="module_uat_frontend_distribution"></a> [uat\_frontend\_distribution](#module\_uat\_frontend\_distribution) | ./modules/cloudfront | n/a |
| <a name="module_uat_frontend_record"></a> [uat\_frontend\_record](#module\_uat\_frontend\_record) | ./modules/dns | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_route53_zone.existing_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

No inputs.

| Name | Description |
|------|-------------|
| <a name="output_uat_frontend_url"></a> [uat\_frontend\_url](#output\_uat\_frontend\_url) | n/a |
