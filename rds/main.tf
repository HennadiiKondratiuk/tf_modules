data "aws_availability_zones" "available" {}

resource "aws_db_subnet_group" "rds-default" {
  name        = "${var.rds_instance_identifier}-${var.env}-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids  = "${var.private_subnet_ids}"
}

resource "aws_security_group" "rds" {
  name        = "hkond-terraform_rds_sg-${var.env}"
  description = "Terraform example RDS MySQL server"
  vpc_id      = "${var.vpc_id}"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["${var.access_ip}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-example-rds-security-group"
  }
}

// Generate Password for RDS
resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "!#$&"
}

// Store Password in SSM Parameter Store
resource "aws_ssm_parameter" "rds_password" {
  name        = "/hkond-${var.env}/rds-mysql"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
}

resource "aws_db_instance" "rds-instance" {
  identifier                = "${var.rds_instance_identifier}"
  allocated_storage         = "${var.allocated_storage}"
  engine                    = "${var.engine}"
  engine_version            = "${var.engine_version}"
  instance_class            = "${var.instance_class}"
  db_name                   = "${var.database_name}"
  username                  = "${var.database_user}"
  password                  = aws_ssm_parameter.rds_password.value
  db_subnet_group_name      = "${aws_db_subnet_group.rds-default.id}"
  vpc_security_group_ids    = ["${aws_security_group.rds.id}"]
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}

resource "aws_db_parameter_group" "rds-parameter-group" {
  name        = "${var.rds_instance_identifier}-param-group"
  family      = "mysql8.0"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}