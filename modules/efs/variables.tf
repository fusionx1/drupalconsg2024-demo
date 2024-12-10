variable "tags" {
  type        = map(string)
  description = "The tags for the VPC instance"
  default     = {}
}

variable "ecs_sg" {
  type        = string
  description = "The security group for the ECS cluster"
}

variable "vpc_id" {
  type        = string
  description = "value"
}

variable "subnets" {
  type        = map(string)
  description = "The subnets of the VPC."
}