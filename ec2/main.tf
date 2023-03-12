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

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name_private
  public_key = tls_private_key.key.public_key_openssh
}


resource "aws_security_group" "security-group" {
  name        = "hkond-${var.env}-sg"
  vpc_id      = "${var.vpc_id}"

  dynamic "ingress" {
    for_each = ${var.ports}
    content{
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "${var.protocol_sg}"
      cidr_blocks = ["${var.cidr_block_sg}"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amzlinux" {
  most_recent      = true
  owners           = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
#Create a new EC2 launch configuration
resource "aws_instance" "ec2" {
  count                       = var.ec2_number
  ami                         = data.aws_ami.amzlinux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_pair.key_name
  security_groups             = ["${aws_security_group.security-group.id}"]
  subnet_id                   = var.public_sub_ec2 ? "${var.public_subnet_ids}" : "${var.private_subnet_ids}"
  associate_public_ip_address = var.public_ip
  tags = {
    "Name" = var.public_sub_ec2 ? "Hkond-${var.env}-PUBLIC" : "Hkond-${var.env}-PRIVATE"
  }
 
}