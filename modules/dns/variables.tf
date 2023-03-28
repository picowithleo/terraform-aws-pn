variable "name" {
  type        = string
  description = "The name of the Route53 record"
}

variable "record_type" {
  type        = string
  description = "The type of the Route53 record (A or CNAME)"
}

variable "zone_id" {
  type        = string
  description = "The Route53 zone ID for the domain"
}

# variable "target_domain" {
#   type        = string
#   description = "The target domain name for the alias record (A type)"
#   default     = ""
# }

# variable "target_zone_id" {
#   type        = string
#   description = "The target hosted zone ID for the alias record (A type)"
#   default     = ""
# }

# variable "target_record" {
#   type        = string
#   description = "The target record value for the CNAME record (CNAME type)"
#   default     = ""
# }

variable "record_values" {
  description = "A string list of records. The number of items depends on the type. For example, an A record would have exactly one value."
  type        = list(string)
  default     = []
}

variable "alias_target" {
  description = "Configuration block indicating the target for an alias record."
  type = object({
    name                   = string
    zone_id                = string
    evaluate_target_health = bool
  })
  default = null
}

variable "ttl" {
  type        = number
  description = "The TTL of the Route53 record."
  default     = 300
}
