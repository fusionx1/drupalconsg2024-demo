variable "public_subnet_numbers" {
  type        = map(number)
  description = "Map of the AZ to a number that should be used for public subnets."
  default = {
    "ap-southeast-1a" : 0
    "ap-southeast-1b" : 2
    "ap-southeast-1c" : 4
  }
}

variable "tags" {
  type        = map(string)
  description = "The tags for the VPC instance"
  default     = {}
}
