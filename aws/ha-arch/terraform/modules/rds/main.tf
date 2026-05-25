resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-rds-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = { Name = "${var.project}-rds-subnet-group" }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg"
  description = "Allow MySQL from application tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-rds-sg" }
}

resource "aws_db_instance" "this" {
  identifier              = "${var.project}-rds"
  allocated_storage       = var.allocated_storage
  engine                  = "mysql"
  engine_version          = var.engine_version
  instance_class          = var.db_instance_type
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  backup_retention_period = var.backup_retention_period
  multi_az                = var.multi_az
  deletion_protection     = var.deletion_protection

  tags = { Name = "${var.project}-rds" }
}
