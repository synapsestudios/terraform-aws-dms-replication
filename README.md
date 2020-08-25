# AWS DMS Replication

This module provides DMS replication from and external source (on premise) to RDS. It is early stages and only tested with `sqlserver-web`


## About
This module provisions an AWS DMS Replication instance
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.6 |
| aws | ~> 2.53 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.53 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| certificate\_arn | The Amazon Resource Name (ARN) for the certificate. | `string` | n/a | yes |
| dms\_cidr\_blocks | List of CIDR blocks allowed to connect to DMS Instance. | `list(string)` | n/a | yes |
| dms\_subnet\_ids | List of subnet IDs to associate with the replication subnet group. | `list(string)` | n/a | yes |
| dns\_zone | Name of the DNS zone to use when creating entries for DMS, and RDS endpoints. | `string` | n/a | yes |
| environment\_name | Name of the environment this resource is being deployed. | `string` | n/a | yes |
| name | Name of this DMS Replica Deployment. | `string` | n/a | yes |
| rds\_subnet\_ids | List of subnet IDs to associate with the replication's RDS subnet group. | `list(string)` | n/a | yes |
| source\_db\_name | Source DB name for this DMS Instance. | `string` | n/a | yes |
| source\_engine\_name | (Required) The type of engine for the endpoint. Can be one of aurora \| azuredb \| db2 \| docdb \| dynamodb \| mariadb \| mongodb \| mysql \| oracle \| postgres \| redshift \| s3 \| sqlserver \| sybase. | `string` | n/a | yes |
| source\_password | The password to be used to login to the endpoint database. | `string` | n/a | yes |
| source\_port | (Optional) The port used by the endpoint database. | `number` | n/a | yes |
| source\_server | Source of replication. | `string` | n/a | yes |
| source\_username | The user name to be used to login to the endpoint database. | `string` | n/a | yes |
| tags | A mapping of tags to assign to the AWS resources. | `map(string)` | n/a | yes |
| target\_db\_name | Target DB name for this DMS Instance. | `string` | n/a | yes |
| target\_engine\_name | (Required) The type of engine for the endpoint. Can be one of aurora \| azuredb \| db2 \| docdb \| dynamodb \| mariadb \| mongodb \| mysql \| oracle \| postgres \| redshift \| s3 \| sqlserver \| sybase. | `string` | n/a | yes |
| target\_engine\_version | The target RDS engine version to use for replication. | `string` | n/a | yes |
| target\_password | The password to be used to login to the endpoint database. | `string` | n/a | yes |
| target\_port | (Optional) The port used by the endpoint database. | `number` | n/a | yes |
| target\_username | The user name to be used to login to the endpoint database. | `string` | n/a | yes |
| availability\_zone | The EC2 Availability Zone that the replication instance will be created in. | `string` | `"us-west-2a"` | no |
| create\_dns\_entries | If true, DNS enteries will be created for the DMS, and RDS endpoints. | `bool` | `true` | no |
| dms\_allocated\_storage | The amount of storage (in gigabytes) to be initially allocated for the replication instance. | `number` | `50` | no |
| dms\_apply\_immediately | Indicates whether the changes should be applied immediately or during the next maintenance window. Only used when updating an existing resource. | `bool` | `true` | no |
| dms\_auto\_minor\_version\_upgrade | Indicates that minor engine upgrades will be applied automatically to the replication instance during the maintenance window. | `bool` | `true` | no |
| dms\_availability\_zone | The EC2 Availability Zone that the replication instance will be created in. | `string` | `"us-west-2a"` | no |
| dms\_engine\_version | The engine version number of the replication instance. | `string` | `"3.3.1"` | no |
| dms\_instance\_type | The compute and memory capacity of the replication instance as specified by the replication instance type. Can be one of dms.t2.micro \| dms.t2.small \| dms.t2.medium \| dms.t2.large \| dms.c4.large \| dms.c4.xlarge \| dms.c4.2xlarge \| dms.c4.4xlarge | `string` | `"dms.t2.micro"` | no |
| dms\_multi\_az | (Optional) Specifies if the replication instance is a multi-az deployment. You cannot set the dms\_availability\_zone parameter if the dms\_multi\_az parameter is set to true. | `bool` | `false` | no |
| dms\_preferred\_maintenance\_window | The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC). | `string` | `"sun:10:30-sun:14:30"` | no |
| dms\_publicly\_accessible | Specifies the accessibility options for the DMS replication instance. A value of true represents an instance with a public IP address. A value of false represents an instance with a private IP address. | `bool` | `true` | no |
| private\_dns | If using a private DNS zone, set this to true. | `bool` | `false` | no |
| rds\_additional\_security\_groups | Optional list of additional security groups to associate with the RDS Replica. | `list(string)` | `[]` | no |
| rds\_allocated\_storage | The amount of storage (in gigabytes) to be initially allocated for the RDS replication instance. | `number` | `50` | no |
| rds\_allowed\_security\_groups | Optional list of security groups allowed to connect to the RDS Replica. | `list(string)` | `[]` | no |
| rds\_apply\_immediately | If true any database modifications are applied immediately, otherwise they will be applied dduring the next maintenance window. | `bool` | `true` | no |
| rds\_backup\_retention\_period | The days to retain backups for. Must be between 1 and 35 | `number` | `10` | no |
| rds\_backup\_window | The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with 'rds\_maintenance\_window'. | `string` | `"00:00-04:00"` | no |
| rds\_ca\_cert\_identifier | The identifier of the CA certificate for the DB instance. | `string` | `"rds-ca-2019"` | no |
| rds\_cidr\_blocks | List of CIDR blocks allowed to connect to RDS Replication Instance. | `list(string)` | `[]` | no |
| rds\_deletion\_protection | If true the DB instance will have deletion protection enabled. | `bool` | `true` | no |
| rds\_final\_snapshot\_identifier | The name of your final DB snapshot when this DB instance is deleted. Must be provided if skip\_final\_snapshot is set to false. | `string` | `null` | no |
| rds\_instance\_type | The instance type of the RDS instance. | `string` | `"db.t2.small"` | no |
| rds\_log\_types | List of database log type to export to CloudWatch. Options: alert, audit, error, general, listener, slowquery, trace, postgresql, upgrade | `list` | <pre>[<br>  "error"<br>]</pre> | no |
| rds\_multi\_az | Specifies if the RDS instance is multi-AZ | `bool` | `false` | no |
| rds\_option\_group\_name | (Optional) Name of an RDS OptionGroup to use with the RDS replica | `string` | `null` | no |
| rds\_parameter\_group\_name | (Optional) Name of an RDS ParameterGroup to use with the RDS replica | `string` | `null` | no |
| rds\_publicly\_accessible | Specifies the accessibility options for the RDS replication instance. A value of true represents an instance with a public IP address. A value of false represents an instance with a private IP address. | `bool` | `true` | no |
| rds\_skip\_final\_snapshot | If false, a final snapshot of the RDS Replication instace will not be created when instance is deleted. | `bool` | `false` | no |
| rds\_storage\_encrypted | Specifies whether the DB instance is encrypted. | `bool` | `false` | no |
| rds\_storage\_type | One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). | `string` | `"gp2"` | no |
| source\_ssl\_mode | The SSL mode to use for the source connection. Can be one of none \| require \| verify-ca \| verify-full | `string` | `"none"` | no |
| target\_ssl\_mode | The SSL mode to use for the target connection. Can be one of none \| require \| verify-ca \| verify-full | `string` | `"none"` | no |
| use\_external\_dns | If true, this module will not create any Route53 DNS records. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| dms\_instance\_arn | The Amazon Resource Name (ARN) of the DMS replication instance. |
| dms\_private\_ips | A list of the private IP addresses of the replication instance. |
| dms\_public\_ips | A list of the public IP addresses of the replication instance. |
| rds\_address | RDS Endpoint address. |
| source\_endpoint\_arn | The Amazon Resource Name (ARN) for the source endpoint. |
| target\_endpoint\_arn | The Amazon Resource Name (ARN) for the target endpoint. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->