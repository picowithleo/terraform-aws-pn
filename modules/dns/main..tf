resource "aws_route53_record" "this" {
  name             = var.name
  type             = var.record_type
  zone_id          = var.zone_id
  records          = var.record_type == "A" ? null : [var.target_record]
  ttl              = var.record_type == "A" ? null : 60

  alias {
    name                   = var.record_type == "A" ? var.target_domain : null
    zone_id                = var.record_type == "A" ? var.target_zone_id : null
    evaluate_target_health = false
  }
}
