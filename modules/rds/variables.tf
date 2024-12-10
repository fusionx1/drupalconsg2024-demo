variable "tags" {
  type        = map(string)
  description = "The tags for the VPC instance"
  default     = {}
}

variable "subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets"
}

variable "vpc" {
  type = any
}

variable "ecs_sg" {
  type        = string
  description = "ECS security group"
}