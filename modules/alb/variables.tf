variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "subnets" {
  type        = map(string)
  description = "The public subnets"
}