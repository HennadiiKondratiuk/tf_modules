variable "vpc_id" {
  type    = string
}

variable "engine" {
  type = string
  default = "mysql"
}

variable "engine_version" {
  type = string
  default = "8.0.28"
}

variable "access_ip" {
  default     = "0.0.0.0/0"
  description = "access to db, default from anywhere"
  type        = string
}

variable "instance_class" {
  type = string
  default = "db.t2.micro"
}

variable "allocated_storage" {
  type = string
  default = "5"
}
variable "rds_instance_identifier" {}
variable "database_name" {}

variable "database_user" {
  sensitive   = true
}
variable "env" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "family" {
  type = string
  default = "mysql8.0"
}
variable "param_val" {
  type = string
  default = "utf8"
}