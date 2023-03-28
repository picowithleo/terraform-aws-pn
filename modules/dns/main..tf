# draft1
# resource "aws_route53_record" "this" {
#   name             = var.name
#   type             = var.record_type
#   zone_id          = var.zone_id
#   records          = var.record_type == "A" ? null : [var.target_record]
#   ttl              = var.record_type == "A" ? null : 60

#   alias {
#     name                   = var.record_type == "A" ? var.target_domain : null
#     zone_id                = var.record_type == "A" ? var.target_zone_id : null
#     evaluate_target_health = false
#   }
# }

# draft2
# resource "aws_route53_record" "this" {
#   zone_id = var.zone_id
#   name    = var.name
#   type    = var.record_type
#   ttl     = "300"

#   dynamic "records" {
#     for_each = var.record_values
#     content {
#       value = records.value
#     }
#   }

#   dynamic "alias" {
#     for_each = var.alias_target != null ? [1] : []
#     content {
#       name                   = var.alias_target.name
#       zone_id                = var.alias_target.zone_id
#       evaluate_target_health = var.alias_target.evaluate_target_health
#     }
#   }
# }

# draft3
# resource "aws_route53_record" "this" {
#   zone_id = var.zone_id
#   name    = var.name
#   type    = var.record_type

#   dynamic "alias" {
#     for_each = var.alias_target != null ? [var.alias_target] : []
#     content {
#       name                   = alias.value.name
#       zone_id                = alias.value.zone_id
#       evaluate_target_health = alias.value.evaluate_target_health
#     }
#   }

#   records = var.record_values
#   ttl     = var.ttl
# }

#draft4
# resource "aws_route53_record" "this" {
#   zone_id = var.zone_id
#   name    = var.name
#   type    = var.record_type

#   dynamic "alias" {
#     for_each = var.alias_target != null ? [1] : []
#     content {
#       name                   = var.alias_target.name
#       zone_id                = var.alias_target.zone_id
#       evaluate_target_health = var.alias_target.evaluate_target_health
#     }
#   }

#   dynamic "resource" {
#     for_each = var.alias_target == null ? [1] : []
#     content {
#       records = var.record_values
#       ttl     = var.ttl
#     }
#   }
# }


resource "aws_route53_record" "this" {
  zone_id = var.zone_id
  name    = var.name
  type    = var.record_type

  dynamic "alias" {
    for_each = var.alias_target != null ? [var.alias_target] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  records = var.alias_target == null ? var.record_values : null
  ttl     = var.alias_target == null ? var.ttl : null
}
