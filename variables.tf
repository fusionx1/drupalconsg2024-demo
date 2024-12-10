#########################################################
# Define any variables that you will use in your stack  #
# They should have a type, description, and optionally  #
# a default value                                       #
#########################################################

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "namespace" {
  type        = string
  description = "AWS Namespace"
  default     = ""
}

variable "region" {
  type        = string
  description = "which region to deploy into"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "profile" {
  type        = string
  description = ""
  default     = "drupalconsg"
}

variable "access_key" {
  type        = string
  description = ""
  default     = "default"
}

variable "secret_key" {
  type        = string
  description = ""
  default     = "default"
}