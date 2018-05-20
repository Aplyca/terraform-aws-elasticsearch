variable "name" {
  description = "Name prefix for all EFS resources."
  default     = "App"
}

variable "azs" {
  description = "A list of availability zones to associate with."
  type        = "list"
  default     = []
}

variable "access_sg_ids" {
  description = "A list of security groups Ids to grant access."
  type        = "list"
  default     = []
}

variable "vpc_id" {
  description = "VPC Id where the EFS resources will be deployed."
}

variable "newbits" {
  description = "newbits in the cidrsubnet function."
  default = 26
}

variable "netnum" {
  description = "netnum in the cidrsubnet function."
  default = 0
}

variable "access_cidrs" {
  description = "A list of Subnets CIDR Blocks to grant access"
  type        = "list"
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

variable "es_version" {
  description = "Version"
  default     = "6.2"
}

variable "storage" {
  description = "Storage size"
  default     = 10
}

variable "type" {
  description = "Instance type"
  default     = "t2.small.elasticsearch"
}

variable "instances" {
  description = "Instance count"
  default     = 1
}

variable "enable_logs" {
  description = "Enalbe CloudWatch Logs"
  default     = false
}
