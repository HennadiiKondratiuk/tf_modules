//Data from network module
data "terraform_remote_state" "network"{
  backend = "s3"
  config = {
    bucket = "hkond-terraform-state-backend"
    key = "network/terraform.tfstate"
    region = "${var.region}"
  }
}
// Generate the SSH keypair that we’ll use to configure the EC2 instance.
// After that, write the private key to a local file and upload the public key to AWS
resource "tls_private_key" "key" {
  algorithm = "RSA"
}
resource "local_file" "private_key" {
  filename          = var.key_name_private
  sensitive_content = tls_private_key.key.private_key_pem
  file_permission   = "0400"
}
#resource "local_file" "public_key" {
#  filename          = var.key_name
#  sensitive_content = tls_private_key.key.public_key_openssh
#  file_permission   = "0400"
#}
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name_private
  public_key = tls_private_key.key.public_key_openssh
}

# Create Security Group for the Bastion Host 
# terraform aws create security group
resource "aws_security_group" "ssh-security-group" {
  name        = "SSH Security Group"
  description = "Enable SSH access on Port 22"
  vpc_id      = "${var.vpc_id}"
  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh-location}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Hkond SSH Security Group"
  }
}
# Create Security Group for the Web Server
# terraform aws create security group
resource "aws_security_group" "webserver-security-group" {
  name        = "Web Server Security Group"
  description = "Enable HTTP access on Port 80 and SSH access on Port 22 via SSH SG"
  vpc_id      = "${var.vpc_id}"
  ingress {
    description     = "SSH Access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ssh-security-group.id}"]
  }
  ingress {
    description     = "WEB Access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Hkond Web Server Security Group"
  }
}

#Create a new EC2 launch configuration
resource "aws_instance" "ec2_public" {
  ami                         = "ami-0eb7496c2e0403237"
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_pair.key_name
  security_groups             = ["${aws_security_group.ssh-security-group.id}"]
  subnet_id                   = "${var.public_subnet_ids}"
  associate_public_ip_address = true
  tags = {
    "Name" = "Hkond-EC2-PUBLIC"
  }
 
  # Copies the ssh key file to home dir
  #provisioner "file" {
  #  source      = "./${var.key_name}"
  #  destination = "/home/ec2-user/${var.key_name}.pem"
  #  connection {
  #    type        = "ssh"
  #    user        = "ec2-user"
  #    private_key = file("${var.key_name_private}")#local_file.private_key.filename 
  #    host        = self.public_ip
  #  }
  #}
  //chmod key 400 on EC2 instance
  #provisioner "remote-exec" {
  #  inline = ["chmod 400 ~/${var.key_name}.pem"]
  #  connection {
  #    type        = "ssh"
  #    user        = "ec2-user"
  #   private_key = file("${var.key_name_private}")#local_file.private_key.filename#file("${var.key_name}.pem")
  #   host        = self.public_ip
  # }
  #
}
#Create a new EC2 launch configuration
resource "aws_instance" "ec2_private" {
  ami                         = "ami-0eb7496c2e0403237"
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_pair.key_name
  security_groups             = ["${aws_security_group.webserver-security-group.id}"]
  subnet_id                   = "${var.private_subnet_ids}"
  associate_public_ip_address = false
  tags = {
    "Name" = "Hkond-EC2-Private"
  }
}