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
  name = local.domain_name
}

# S3 Bucket Module
# module "uat_frontend_bucket" {
#   source = "./modules/s3_bucket"

#   bucket_name = "${local.uat_prefix}-${local.domain_name}"
# }
module "uat_frontend_bucket" {
  source = "./modules/s3_bucket"
  bucket_name_prefix = local.uat_prefix
  domain_name        = local.domain_name
}


# Certificate Module
module "uat_cert" {
  source = "./modules/certificate"
  providers = {
      aws = aws.us
    }
  domain_name = "${local.uat_prefix}.${local.domain_name}"
  zone_id     = data.aws_route53_zone.existing_zone.zone_id
}

# DNS Module
# module "uat_dns_validation_record" {
#   source = "./modules/dns"
#   certificate_arn = module.uat_cert.certificate_arn
#   zone_id         = data.aws_route53_zone.existing_zone.zone_id
#   domain_validation_options = module.uat_cert.domain_validation_options
# }
module "uat_dns_validation_record" {
  source = "./modules/dns"
  zone_id      = data.aws_route53_zone.existing_zone.zone_id
  name         = module.uat_cert.domain_validation_options[0].resource_record_name
  record_type  = module.uat_cert.domain_validation_options[0].resource_record_type
  record_values = [module.uat_cert.domain_validation_options[0].resource_record_value]
}

# module "uat_frontend_record" {
#   source = "./modules/dns"
#   record_type = "A"
#   domain_name = "${local.uat_prefix}.${local.domain_name}"
#   zone_id     = data.aws_route53_zone.existing_zone.zone_id
#   alias_target = {
#     name                   = module.uat_frontend_distribution.domain_name
#     zone_id                = module.uat_frontend_distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
# }
module "uat_frontend_record" {
  source = "./modules/dns"
  zone_id      = data.aws_route53_zone.existing_zone.zone_id
  name         = "${local.uat_prefix}.${local.domain_name}"
  record_type  = "A"
  alias_target = {
    name                   = module.uat_frontend_distribution.domain_name
    zone_id                = module.uat_frontend_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# CloudFront Module
module "uat_frontend_distribution" {
  source = "./modules/cloudfront"

  origin_domain_name = module.uat_frontend_bucket.bucket_regional_domain_name
  origin_id          = module.uat_frontend_bucket.bucket_id
  aliases            = ["${local.uat_prefix}.${local.domain_name}"]
  acm_certificate_arn = module.uat_cert.certificate_arn
}
# module "uat_frontend_distribution" {
#   source = "./modules/cloudfront"
#   origin_domain_name = module.uat_frontend_bucket.bucket_regional_domain_name
#   origin_id          = module.uat_frontend_bucket.bucket_id
#   domain_name        = "${local.uat_prefix}.${local.domain_name}"
#   certificate_arn    = module.uat_cert.certificate_arn
# }




# # Add backend modules here
# module "backend_s3_bucket" {
#   source = "./modules/s3_bucket"
#   bucket_name = "backend-${local.domain_name}"
# }

# module "backend_certificate" {
#   source = "./modules/certificate"
#   providers = {
#     aws = aws.us
#   }
#   domain_name = "backend.${local.domain_name}"
#   zone_id     = data.aws_route53_zone.existing_zone.zone_id
# }

# # Add other backend modules (DNS and CloudFront) if needed