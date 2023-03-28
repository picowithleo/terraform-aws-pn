# variable "bucket_name" {
#   type        = string
#   description = "The name of the S3 bucket"
# }

variable "bucket_name_prefix" {
  description = "The prefix for the S3 bucket name"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the S3 bucket"
  type        = string
}
