variable "ssh-location" {
  default     = "0.0.0.0/0"
  description = "SSH variable for bastion host"
  type        = string
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "region" {
  default = "eu-central-1"
  type    = string
}
variable "vpc_id" {
  type    = string
}

variable "key_name_private" {
  default = "hkond-private-key"
  type = string
}
variable "private_subnet_ids" {
}
variable "public_subnet_ids" {
}
