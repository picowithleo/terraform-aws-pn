variable "origin_domain_name" {
  type        = string
  description = "The domain name of the origin to serve content from"
}

variable "origin_id" {
  type        = string
  description = "A unique identifier for the origin"
}

variable "aliases" {
  type        = list(string)
  description = "A list of domain name aliases for the distribution"
  default     = []
}

variable "acm_certificate_arn" {
  type        = string
  description = "The ACM certificate ARN for HTTPS"
}
