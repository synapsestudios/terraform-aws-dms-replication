locals {
  rds_final_snapshot_identifier = var.rds_final_snapshot_identifier == null ? "${var.name}-replica-final" : var.rds_final_snapshot_identifier
}

#####################
# Data to get DMS VPC
#####################
data "aws_subnet" "dms" {
  id = var.dms_subnet_ids[0]
}

#####################
# Data to get RDS VPC
#####################
data "aws_subnet" "rds" {
  id = var.rds_subnet_ids[0]
}

#############################
# RDS Route53 Public DNS Zone
#############################
data "aws_route53_zone" "rds" {
  count = var.private_dns == false ? 1 : 0

  name         = var.dns_zone
  private_zone = false
}
#############################
# RDS Route53 Private DNS Zone
#############################
resource "aws_route53_zone" "rds" {
  count = var.private_dns == true ? 1 : 0

  name = var.dns_zone
  vpc {
    vpc_id = data.aws_subnet.rds.vpc_id
  }
}

#############################
# DMS Route53 Public DNS Zone
#############################
data "aws_route53_zone" "dms" {
  count = var.private_dns == false ? 1 : 0

  name         = var.dns_zone
  private_zone = false
}
##############################
# DMS Route53 Private DNS Zone
##############################
resource "aws_route53_zone" "dms" {
  count = var.private_dns == true ? 1 : 0

  name = var.dns_zone
  vpc {
    vpc_id = data.aws_subnet.dms.vpc_id
  }
}

###############################
# DMS Required Roles & Policies
###############################
data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms_endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "dms_endpoint-AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms_endpoint.name
}

resource "aws_iam_role" "dms_cloudwatch_logs_role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-cloudwatch-logs-role"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "dms_cloudwatch_logs_role-AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms_cloudwatch_logs_role.name
}

resource "aws_iam_role" "dms_vpc" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "dms_vpc-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms_vpc.name
}

##########################
# DMS Replication Instance
##########################
resource "aws_dms_replication_instance" "this" {
  depends_on                   = [aws_iam_role.dms_vpc]
  allocated_storage            = var.dms_allocated_storage
  apply_immediately            = var.dms_apply_immediately
  auto_minor_version_upgrade   = var.dms_auto_minor_version_upgrade
  availability_zone            = var.dms_availability_zone
  engine_version               = var.dms_engine_version
  multi_az                     = var.dms_multi_az
  preferred_maintenance_window = var.dms_preferred_maintenance_window
  publicly_accessible          = var.dms_publicly_accessible
  replication_instance_class   = var.dms_instance_type
  replication_instance_id      = "${var.name}-${var.environment_name}-dms"
  replication_subnet_group_id  = aws_dms_replication_subnet_group.this.id
  vpc_security_group_ids       = [aws_security_group.dms.id]
  tags                         = var.tags
}

###################################
# Route53 A Record for DMS Endpoint
###################################
resource "aws_route53_record" "dms_public" {
  count = var.create_dns_entries == true && var.dms_publicly_accessible == true ? 1 : 0

  zone_id = data.aws_route53_zone.dms[0].id
  name    = "${var.name}-dms"
  type    = "A"
  ttl     = "300"
  records = aws_dms_replication_instance.this.replication_instance_public_ips
}

resource "aws_route53_record" "dms_private" {
  count = var.create_dns_entries == true && var.dms_publicly_accessible == false ? 1 : 0

  zone_id = data.aws_route53_zone.dms[0].id
  name    = "${var.name}-dms"
  type    = "A"
  ttl     = "300"
  records = aws_dms_replication_instance.this.replication_instance_private_ips
}

##############################
# DMS Replication Subnet Group
##############################
resource "aws_dms_replication_subnet_group" "this" {
  depends_on                           = [aws_iam_role.dms_vpc]
  replication_subnet_group_description = "${var.name}-${var.environment_name}-dms"
  replication_subnet_group_id          = "${var.name}-${var.environment_name}-dms"
  subnet_ids                           = var.dms_subnet_ids
  tags                                 = var.tags
}

###############################
# Security Groups - DMS Traffic
###############################
resource "aws_security_group" "dms" {
  name        = "${var.name}-${var.environment_name}-dms-access"
  description = "${var.name}-${var.environment_name} DMS Replication traffic rules"
  vpc_id      = data.aws_subnet.dms.vpc_id
  tags        = merge(var.tags, { Name = "Dms${title(var.name)}" })
}

##################################################################
# Security Group Rules - Allows access to DMS Replication Instance
##################################################################
resource "aws_security_group_rule" "dms_ingress" {
  type              = "ingress"
  from_port         = var.source_port
  to_port           = var.source_port
  protocol          = "6"
  description       = "Allow incoming connections to the ${var.name}-${var.environment_name} DMS Replication Instance"
  cidr_blocks       = var.dms_cidr_blocks
  security_group_id = aws_security_group.dms.id
}

resource "aws_security_group_rule" "dms_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow outgoing connections from the ${var.name}-${var.environment_name} DMS Replication Instance"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dms.id
}

###############################
# Security Groups - RDS Traffic
###############################
resource "aws_security_group" "rds" {
  name        = "${var.name}-${var.environment_name}-rds-replication-access"
  description = "${var.name}-${var.environment_name} RDS Replication traffic rules"
  vpc_id      = data.aws_subnet.rds.vpc_id
  tags        = merge(var.tags, { Name = "Rds${title(var.name)}" })
}

##################################################################
# Security Group Rules - Allows access to RDS Replication Instance
##################################################################
resource "aws_security_group_rule" "rds_ingress" {
  type                     = "ingress"
  from_port                = var.target_port
  to_port                  = var.target_port
  protocol                 = "6"
  description              = "Allow incoming connections to RDS from ${var.name}-${var.environment_name} DMS Replication Instance"
  source_security_group_id = aws_security_group.dms.id
  security_group_id        = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds_additional_ingress" {
  count                    = length(var.rds_allowed_security_groups)
  type                     = "ingress"
  from_port                = var.target_port
  to_port                  = var.target_port
  protocol                 = "6"
  description              = "Allow incoming connections to RDS."
  source_security_group_id = var.rds_allowed_security_groups[count.index]
  security_group_id        = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds_ingress_cidr_blocks" {
  count = length(var.rds_cidr_blocks) >= 1 ? 1 : 0

  type              = "ingress"
  from_port         = var.target_port
  to_port           = var.target_port
  protocol          = "6"
  description       = "Allow incoming connections to ${var.name}-${var.environment_name} RDS Replica."
  cidr_blocks       = var.rds_cidr_blocks
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  description              = "Allow outgoing connections from RDS to ${var.name}-${var.environment_name} DMS Replication Instance"
  source_security_group_id = aws_security_group.dms.id
  security_group_id        = aws_security_group.rds.id
}


####################
# RDS - Subnet Group
####################
resource "aws_db_subnet_group" "rds" {
  name        = "${var.name}-${var.environment_name}-replica"
  description = "${var.name} ${var.environment_name} Replication Subnet Group"
  subnet_ids  = var.rds_subnet_ids
  tags        = var.tags
}

##########################
# RDS Replication Instance
##########################
resource "aws_db_instance" "rds" {
  allocated_storage               = var.rds_allocated_storage
  apply_immediately               = var.rds_apply_immediately
  backup_retention_period         = var.rds_backup_retention_period
  backup_window                   = var.rds_backup_window
  ca_cert_identifier              = var.rds_ca_cert_identifier
  db_subnet_group_name            = aws_db_subnet_group.rds.name
  deletion_protection             = var.rds_deletion_protection
  enabled_cloudwatch_logs_exports = var.rds_log_types
  engine                          = var.target_engine_name
  engine_version                  = var.target_engine_version
  final_snapshot_identifier       = local.rds_final_snapshot_identifier
  identifier                      = "${var.name}-${var.environment_name}-replica"
  instance_class                  = var.rds_instance_type
  multi_az                        = var.rds_multi_az
  option_group_name               = var.rds_option_group_name
  parameter_group_name            = var.rds_parameter_group_name
  password                        = var.target_password
  port                            = var.target_port
  publicly_accessible             = var.rds_publicly_accessible
  skip_final_snapshot             = var.rds_skip_final_snapshot
  storage_encrypted               = var.rds_storage_encrypted
  storage_type                    = var.rds_storage_type
  username                        = var.target_username
  vpc_security_group_ids          = concat(var.rds_additional_security_groups, [aws_security_group.rds.id])
  tags                            = var.tags
}

################################
# Route53 CNAME for RDS Endpoint
################################
resource "aws_route53_record" "rds" {
  count = var.create_dns_entries == true ? 1 : 0

  zone_id = data.aws_route53_zone.rds[0].id
  name    = "${var.name}-replica"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.rds.address]
}

#####################
# DMS Target Endpoint
#####################
resource "aws_dms_endpoint" "target" {
  database_name               = var.target_db_name
  endpoint_id                 = "${var.name}-${var.environment_name}-replica"
  endpoint_type               = "target"
  engine_name                 = replace(var.target_engine_name, "/-.+/", "")
  extra_connection_attributes = ""
  password                    = var.target_password
  port                        = var.target_port
  server_name                 = var.create_dns_entries == true && var.target_ssl_mode == "none" ? aws_route53_record.rds[0].fqdn : aws_db_instance.rds.address
  ssl_mode                    = var.target_ssl_mode
  username                    = var.target_username
  tags                        = var.tags
}

#####################
# DMS Source Endpoint
#####################
resource "aws_dms_endpoint" "source" {
  database_name               = var.source_db_name
  endpoint_id                 = "${var.name}-${var.environment_name}-master"
  endpoint_type               = "source"
  engine_name                 = var.source_engine_name
  extra_connection_attributes = ""
  password                    = var.source_password
  port                        = var.source_port
  server_name                 = var.source_server
  ssl_mode                    = var.source_ssl_mode
  username                    = var.source_username
  tags                        = var.tags
}
