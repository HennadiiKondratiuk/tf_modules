output "aws_db_instance_identifier" {
  value = aws_db_instance.rds-instance.identifier
}

output "aws_db_instance_name" {
  value = aws_db_instance.rds-instance.db_name
}
