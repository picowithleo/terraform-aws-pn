provider "aws" {
  region = "ap-southeast-2"
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}

locals {
  domain_name = "picoukkonen.world"
  uat_prefix  = "uat-v2"
  prod_prefix = "prod"
}

data "aws_route53_zone" "existing_zone" {
  name = "picoukkonen.world"
}

# S3 Bucket Module
module "uat_frontend_bucket" {
  source = "./modules/s3_bucket"

  bucket_name = "${local.uat_prefix}-${local.domain_name}"
}

# Certificate Module
module "uat_cert" {
  source   = "./modules/certificate"
  provider = aws.us

  domain_name = "${local.uat_prefix}.${local.domain_name}"
}

# DNS Module
module "uat_dns_validation_record" {
  source = "./modules/dns"
  
  domain_validation_options = module.uat_cert.domain_validation_options
  zone_id = data.aws_route53_zone.existing_zone.zone_id
}

module "uat_frontend_record" {
  source = "./modules/dns"
  
  record_type   = "A"
  name          = "uat-v2.${local.domain_name}"
  zone_id       = data.aws_route53_zone.existing_zone.zone_id
  target_domain = module.uat_frontend_distribution.domain_name
  target_zone_id = module.uat_frontend_distribution.hosted_zone_id
}

# CloudFront Module
module "uat_frontend_distribution" {
  source = "./modules/cloudfront"

  origin_domain_name = module.uat_frontend_bucket.bucket_regional_domain_name
  origin_id          = module.uat_frontend_bucket.bucket_id
  aliases            = ["${local.uat_prefix}.${local.domain_name}"]
  acm_certificate_arn = module.uat_cert.certificate_arn
}
