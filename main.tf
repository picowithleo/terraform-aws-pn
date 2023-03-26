# 设置了AWS提供程序和本地变量。
provider "aws" {
  region = "ap-southeast-2"
}

# 添加一个新的provider别名
provider "aws" {
  alias  = "us"
  region = "us-east-1"
}
                                            
locals {
  domain_name = "picoukkonen.world"
  uat_prefix  = "uat-v2"
  prod_prefix = "prod"
}
# 创建S3存储桶，并设置其为公共静态网站。
resource "aws_s3_bucket" "uat_frontend_bucket" {
  bucket = "${local.uat_prefix}-${local.domain_name}"
  # acl    = "public-read"
  # website {
  #   index_document = "index.html"
  #   error_document = "error.html"
  # }
}

resource "aws_s3_bucket_acl" "uat_frontend_bucket_acl" {
  bucket = aws_s3_bucket.uat_frontend_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "uat_frontend_bucket_website" {
  bucket = aws_s3_bucket.uat_frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}



# resource "aws_s3_bucket" "prod_frontend_bucket" {
#   bucket = "${local.prod_prefix}-${local.domain_name}"
#   acl    = "public-read"

#   website {
#     index_document = "index.html"
#     error_document = "error.html"
#   }
# }

# 为S3存储桶添加策略，允许公共读取。
resource "aws_s3_bucket_policy" "uat_bucket_policy" {
  bucket = aws_s3_bucket.uat_frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.uat_frontend_bucket.arn}/*"
        Principal = "*"
      }
    ]
  })
}
# 创建ACM证书以支持HTTPS。
resource "aws_acm_certificate" "uat_cert" {
  provider          = aws.us
  domain_name       = "${local.uat_prefix}.${local.domain_name}"
  validation_method = "DNS"

  tags = {
    Terraform = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}
# # 创建Route53托管区域。(若无使用现有托管区域)
# resource "aws_route53_zone" "dns_zone" {
#   name = local.domain_name
# }
# 创建验证证书所需的DNS记录。
resource "aws_route53_record" "uat_dns_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.uat_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name             = each.value.name
  type             = each.value.type
  # zone_id          = aws_route53_zone.dns_zone.zone_id
  zone_id          = data.aws_route53_zone.existing_zone.zone_id

  records          = [each.value.record]
  ttl              = 60
}
# 验证ACM证书。
resource "aws_acm_certificate_validation" "uat_cert_validation" {
  provider                = aws.us
  certificate_arn         = aws_acm_certificate.uat_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.uat_dns_validation_record : record.fqdn]
}

# 为提高安全性，您可以考虑为CloudFront分发启用AWS WAF（Web应用防火墙）。这将帮助您阻止常见的网络攻击，例如SQL注入和跨站脚本（XSS）攻击。
# resource "aws_wafv2_web_acl" "uat_waf_acl" {
#   name        = "uat-web-acl"
#   description = "Web ACL for UAT environment"
#   # scope       = "CLOUDFRONT"
#   scope       = "REGIONAL"

#   # ...其他配置，例如规则和默认操作...
#   #   IP黑名单规则
#   default_action {
#     allow {}
#   }

#   rule {
#     name     = "block-ip-blacklist"
#     priority = 0
#     action {
#       block {}
#     }

#     statement {
#       ip_set_reference_statement {
#         arn = aws_wafv2_ip_set.ip_blacklist.arn
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "blocked_ips"
#       sampled_requests_enabled   = true
#     }
#   }

#   # 防止SQL注入的规则
#   rule {
#     name     = "prevent-sql-injection"
#     priority = 1
#     action {
#       block {}
#     }

#     statement {
#       or_statement {
#         statement {
#           sqli_match_statement {
#             field_to_match {
#               all_query_arguments {}
#             }
#           text_transformation {
#             priority = 0
#             type = "URL_DECODE"
#             }
#           text_transformation {
#             priority = 1
#             type     = "LOWERCASE"
#             }
#           }
#         }
#         statement {
#           sqli_match_statement {
#             field_to_match {
#               body {}
#             }
#             text_transformation {
#               priority = 0
#               type     = "URL_DECODE"
#             }
#             text_transformation {
#               priority = 1
#               type     = "LOWERCASE"
#             }
#           }
#         }
#       }   
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "sql_injection"
#       sampled_requests_enabled   = true
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name = "web_acl"
#     sampled_requests_enabled = true
#   }

#   tags = {
#     Terraform = "true"
#   }
# }

# resource "aws_wafv2_ip_set" "ip_blacklist" {
#   name = "ip_blacklist"
#   description = "IP blacklist for blocking IPs"
#   # scope = "CLOUDFRONT"
#   scope       = "REGIONAL"
#   ip_address_version = "IPV4"

#   addresses = [
#     "1.2.3.4/32",
#     "5.6.7.8/32"
#   ]

#   tags = {
#     Terraform = "true"
#   }
# }

# 创建CloudFront分发并配置。
resource "aws_cloudfront_distribution" "uat_frontend_distribution" {
  origin {
    domain_name = aws_s3_bucket.uat_frontend_bucket.bucket_regional_domain_name
    # origin_id   = "${local.uat_prefix}-${local.domain_name}"
    origin_id = aws_s3_bucket.uat_frontend_bucket.id


    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["${local.uat_prefix}.${local.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    # target_origin_id = "${local.uat_prefix}-${local.domain_name}"
    target_origin_id = aws_s3_bucket.uat_frontend_bucket.id


    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.uat_cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  tags = {
   
    Terraform = "true"
  }


  # lifecycle {
  #   config_mode = "DISABLED"
  # }

  # web_acl_id = aws_wafv2_web_acl.uat_waf_acl.id
}

# 使用已有托管区域记录
data "aws_route53_zone" "existing_zone" {
  name = "picoukkonen.world"
}

# 创建Route53记录，将自定义域名映射到CloudFront分发。
resource "aws_route53_record" "uat_frontend_record" {
  name    = "${local.uat_prefix}.${local.domain_name}"
  type    = "A"
  # zone_id = aws_route53_zone.dns_zone.zone_id
  zone_id = data.aws_route53_zone.existing_zone.zone_id


  alias {
    name                   = aws_cloudfront_distribution.uat_frontend_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.uat_frontend_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
# 使用aws_s3_bucket_public_access_block资源来限制对S3存储桶的公共访问。这可以提供更精细的访问控制，例如限制公共读取和写入访问，而仅允许特定的AWS账户访问。
# resource "aws_s3_bucket_public_access_block" "uat_frontend_bucket_access_block" {
#   bucket = aws_s3_bucket.uat_frontend_bucket.id

#   block_public_acls   = true
#   block_public_policy = true
#   ignore_public_acls  = true
#   restrict_public_buckets = true
# }

output "uat_frontend_url" {
  value = aws_cloudfront_distribution.uat_frontend_distribution.domain_name
}

