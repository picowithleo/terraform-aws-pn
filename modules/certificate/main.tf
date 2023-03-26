resource "aws_acm_certificate" "this" {
  provider          = aws.us
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Terraform = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "this" {
  provider                = aws.us
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_records : record.fqdn]
}

locals {
  validation_records = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
}

resource "aws_route53_record" "validation_records" {
  for_each = local.validation_records

  allow_overwrite = true
  name             = each.value.name
  type             = each.value.type
  zone_id          = var.zone_id
  records          = [each.value.record]
  ttl              = 60
}
