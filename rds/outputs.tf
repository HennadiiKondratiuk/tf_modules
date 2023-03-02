output "aws_db_instance_identifier" {
  value = aws_db_instance.rds-instance.identifier
}

output "aws_db_instance_name" {
  value = aws_db_instance.rds-instance.db_name
}

#output "aws_db_connect_string" {
#  description = "MySQL database connection string"
#  value       = "Server=${aws_db_instance.rds-instance.address}; Database=ExampleDB; Uid=${var.db_username}; Pwd=${var.db_password}"
#  sensitive   = true
#s}