variable "environment_name" {
  type        = string
  description = "Name of the environment this resource is being deployed."
}

variable "name" {
  type        = string
  description = "Name of this DMS Replica Deployment."
}

variable "target_ssl_mode" {
  type        = string
  description = "The SSL mode to use for the target connection. Can be one of none | require | verify-ca | verify-full"
  default     = "none"
}

variable "source_ssl_mode" {
  type        = string
  description = "The SSL mode to use for the source connection. Can be one of none | require | verify-ca | verify-full"
  default     = "none"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the AWS resources."
}

variable "create_dns_entries" {
  type        = bool
  description = "If true, DNS enteries will be created for the DMS, and RDS endpoints."
  default     = true
}

variable "dns_zone" {
  type        = string
  description = "Name of the DNS zone to use when creating entries for DMS, and RDS endpoints."
}

variable "private_dns" {
  type        = bool
  description = "If using a private DNS zone, set this to true."
  default     = false
}

# DMS Variables
variable "dms_multi_az" {
  type        = bool
  description = "(Optional) Specifies if the replication instance is a multi-az deployment. You cannot set the dms_availability_zone parameter if the dms_multi_az parameter is set to true."
  default     = false
}

variable "dms_engine_version" {
  type        = string
  description = "The engine version number of the replication instance."
  default     = "3.3.1"
}

variable "dms_preferred_maintenance_window" {
  type        = string
  description = "The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC)."
  default     = "sun:10:30-sun:14:30"
}

variable "dms_allocated_storage" {
  type        = number
  description = "The amount of storage (in gigabytes) to be initially allocated for the replication instance."
  default     = 50
}

variable "dms_publicly_accessible" {
  type        = bool
  description = "Specifies the accessibility options for the DMS replication instance. A value of true represents an instance with a public IP address. A value of false represents an instance with a private IP address."
  default     = true
}

variable "dms_apply_immediately" {
  type        = bool
  description = "Indicates whether the changes should be applied immediately or during the next maintenance window. Only used when updating an existing resource."
  default     = true
}

variable "dms_auto_minor_version_upgrade" {
  type        = bool
  description = "Indicates that minor engine upgrades will be applied automatically to the replication instance during the maintenance window."
  default     = true
}

variable "dms_availability_zone" {
  type        = string
  description = "The EC2 Availability Zone that the replication instance will be created in."
  default     = "us-west-2a"
}

variable "dms_instance_type" {
  type        = string
  description = "The compute and memory capacity of the replication instance as specified by the replication instance type. Can be one of dms.t2.micro | dms.t2.small | dms.t2.medium | dms.t2.large | dms.c4.large | dms.c4.xlarge | dms.c4.2xlarge | dms.c4.4xlarge"
  default     = "dms.t2.micro"
}

variable "dms_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks allowed to connect to DMS Instance."
}

variable "dms_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to associate with the replication subnet group."
}


# RDS Variables

variable "rds_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to associate with the replication's RDS subnet group."
}

variable "rds_final_snapshot_identifier" {
  type        = string
  description = "The name of your final DB snapshot when this DB instance is deleted. Must be provided if skip_final_snapshot is set to false."
  default     = null
}

variable "rds_allocated_storage" {
  type        = number
  description = "The amount of storage (in gigabytes) to be initially allocated for the RDS replication instance."
  default     = 50
}

variable "rds_storage_type" {
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)."
  default     = "gp2"
}

variable "rds_instance_type" {
  type        = string
  description = "The instance type of the RDS instance."
  default     = "db.t2.small"
}

variable "rds_skip_final_snapshot" {
  type        = bool
  description = "If false, a final snapshot of the RDS Replication instace will not be created when instance is deleted."
  default     = false
}

variable "rds_backup_retention_period" {
  type        = number
  description = "The days to retain backups for. Must be between 1 and 35"
  default     = 10
}

variable "rds_backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with 'rds_maintenance_window'."
  default     = "00:00-04:00"
}

variable "rds_ca_cert_identifier" {
  type        = string
  description = "The identifier of the CA certificate for the DB instance."
  default     = "rds-ca-2019"
}

variable "rds_apply_immediately" {
  type        = bool
  description = "If true any database modifications are applied immediately, otherwise they will be applied dduring the next maintenance window."
  default     = true
}

variable "rds_deletion_protection" {
  type        = bool
  description = "If true the DB instance will have deletion protection enabled."
  default     = true
}

variable "rds_multi_az" {
  type        = bool
  description = "Specifies if the RDS instance is multi-AZ"
  default     = false
}

variable "rds_publicly_accessible" {
  type        = bool
  description = "Specifies the accessibility options for the RDS replication instance. A value of true represents an instance with a public IP address. A value of false represents an instance with a private IP address."
  default     = true
}

variable "rds_log_types" {
  type        = list
  description = "List of database log type to export to CloudWatch. Options: alert, audit, error, general, listener, slowquery, trace, postgresql, upgrade"
  default     = ["error"]
}

variable "rds_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks allowed to connect to RDS Replication Instance."
  default     = []
}

variable "rds_storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB instance is encrypted."
  default     = false
}

variable "rds_parameter_group_name" {
  type        = string
  description = "(Optional) Name of an RDS ParameterGroup to use with the RDS replica"
  default     = null
}

variable "rds_option_group_name" {
  type        = string
  description = "(Optional) Name of an RDS OptionGroup to use with the RDS replica"
  default     = null
}

variable "rds_additional_security_groups" {
  type        = list(string)
  description = "Optional list of additional security groups to associate with the RDS Replica."
  default     = []
}

variable "rds_allowed_security_groups" {
  type        = list(string)
  description = "Optional list of security groups allowed to connect to the RDS Replica."
  default     = []
}

variable "target_engine_version" {
  type        = string
  description = "The target RDS engine version to use for replication."
}

variable "availability_zone" {
  type        = string
  description = "The EC2 Availability Zone that the replication instance will be created in."
  default     = "us-west-2a"
}

variable "certificate_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) for the certificate."
}

variable "source_engine_name" {
  type        = string
  description = "(Required) The type of engine for the endpoint. Can be one of aurora | azuredb | db2 | docdb | dynamodb | mariadb | mongodb | mysql | oracle | postgres | redshift | s3 | sqlserver | sybase."
}

variable "target_engine_name" {
  type        = string
  description = "(Required) The type of engine for the endpoint. Can be one of aurora | azuredb | db2 | docdb | dynamodb | mariadb | mongodb | mysql | oracle | postgres | redshift | s3 | sqlserver | sybase."
}

variable "source_username" {
  type        = string
  description = "The user name to be used to login to the endpoint database."
}

variable "source_password" {
  type        = string
  description = "The password to be used to login to the endpoint database."
}

variable "target_username" {
  type        = string
  description = "The user name to be used to login to the endpoint database."
}

variable "target_password" {
  type        = string
  description = "The password to be used to login to the endpoint database."
}

variable "source_port" {
  type        = number
  description = "(Optional) The port used by the endpoint database."
}

variable "target_port" {
  type        = number
  description = "(Optional) The port used by the endpoint database."
}

variable "target_db_name" {
  type        = string
  description = "Target DB name for this DMS Instance."
}

variable "use_external_dns" {
  type        = bool
  description = "If true, this module will not create any Route53 DNS records."
  default     = false
}

variable "source_server" {
  type        = string
  description = "Source of replication."
}

variable "source_db_name" {
  type        = string
  description = "Source DB name for this DMS Instance."
}
