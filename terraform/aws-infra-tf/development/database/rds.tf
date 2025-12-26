module "postgresql_main_db" {
  source = "terraform-aws-modules/rds/aws"
  version = "6.7.0"
  identifier = "${var.project}-${var.env}-${var.region}-postgresql"

  engine            = "postgres"
  engine_version    = "13"
  family               = "postgres13"
  instance_class    = "db.t4g.small"
  allocated_storage = 50
  storage_type      = "gp3"
  username = "postgres"
  manage_master_user_password = true
  port     = 5432
  vpc_security_group_ids = [module.rds_sg.security_group_id]
  tags = {
    Owner       = "postgres"
    Environment = var.env
    Terraform   = true
  }

  # DB subnet group
  db_subnet_group_name   = "development-vpc"
  subnet_ids = [
    "subnet-123456789",
    "subnet-123456789"
  ]
  # Database Deletion Protection
  deletion_protection = true

  # Database public access
  publicly_accessible    = false
}

module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project}-${var.env}-${var.region}-rds-sg"
  description = "Complete PostgreSQL  security group"
  vpc_id      = "vpc-123456789"

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = "10.1.0.0/16"
    },
  ]

}
