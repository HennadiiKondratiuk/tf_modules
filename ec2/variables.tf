variable "cidr_block_sg" {
  default     = ["0.0.0.0/0"]
  type        = list
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "region" {
  type    = string
}
variable "vpc_id" {
  type    = string
}

variable "env" {
  type = string
}

variable "ports" {
    type = list
}
variable "key_name_private" {
  default = "hkond-private-key"
  type = string
}
variable "private_subnet_ids" {
}
variable "public_subnet_ids" {
}

variable "protocol_sg"{
    default = "tcp"
    type = string
}

variable "public_sub_ec2"{
    default = false
}

variable "public_ip"{
    default = false
}

variable "ec2_number"{
    default = 1
}