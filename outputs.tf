output "dms_public_ips" {
  description = "A list of the public IP addresses of the replication instance."
  value       = aws_dms_replication_instance.this.replication_instance_public_ips
}

output "dms_private_ips" {
  description = "A list of the private IP addresses of the replication instance."
  value       = aws_dms_replication_instance.this.replication_instance_private_ips
}

output "dms_instance_arn" {
  description = "The Amazon Resource Name (ARN) of the DMS replication instance."
  value       = aws_dms_replication_instance.this.replication_instance_arn
}

output "rds_address" {
  description = "RDS Endpoint address."
  value       = var.create_dns_entries == true && var.target_ssl_mode == "none" ? aws_route53_record.rds[0].fqdn : aws_db_instance.rds.address
}

output "source_endpoint_arn" {
  description = "The Amazon Resource Name (ARN) for the source endpoint."
  value       = aws_dms_endpoint.source.endpoint_arn
}

output "target_endpoint_arn" {
  description = "The Amazon Resource Name (ARN) for the target endpoint."
  value       = aws_dms_endpoint.source.endpoint_arn
}


