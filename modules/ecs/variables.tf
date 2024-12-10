variable "tags" {
  type        = map(string)
  description = "The tags for the VPC instance"
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "vpc_subnets" {
  type        = list(string)
  description = "value"
}

variable "lb_sg" {
  type        = string
  description = "The security group"
}

variable "lb_tg_arn" {
  type        = string
  description = "The ARN of the target group."
}

variable "efs_fs_id" {
  type        = string
  description = "The ID of the EFS File system."
}

variable "efs_access_point" {
  type        = string
  description = "The ID of the EFS File system."
}