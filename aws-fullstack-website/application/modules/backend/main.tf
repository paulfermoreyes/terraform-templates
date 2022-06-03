##############################
##### Backend Instances ######
##############################
resource "aws_instance" "backend" {
  count         = length(var.private_subnets)
  ami           = var.default_ami
  instance_type = "t2.micro"
  key_name      = "${var.app_name}-keypair"
  subnet_id     = var.private_subnets[count.index % length(var.private_subnets)]

  tags = {
    Name = "${var.app_name}-${var.env}-backend-${count.index}"
  }

  vpc_security_group_ids = [aws_security_group.instance_sec_group.id]
  user_data              = <<EOF
    #!/bin/sh
    yum update -y
    yum install -y docker
    systemctl enable docker
    systemctl start docker
    usermod -a -G docker ec2-user
    chkconfig docker on
    curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    EOF
}

###########################################
##### Backend Instance Security Group #####
###########################################
resource "aws_security_group" "instance_sec_group" {
  name        = "${var.app_name}-${var.env}-instance-sec-group"
  description = "Allow SSH access from VPC and Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from Public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description     = "Load Balancer SG"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sec_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-${var.env}-instance-sec-group"
  }
}

#############################################
##### Backend Security Group Attachment #####
#############################################
# resource "aws_network_interface_sg_attachment" "backend_sg_attachment" {
#   count = length(aws_instance.backend)
#   security_group_id    = aws_security_group.instance_sec_group.id
#   network_interface_id = aws_instance.backend[count.index].primary_network_interface_id
# }

#################################
##### Backend Load Balancer #####
#################################
resource "aws_lb" "load_balancer" {
  name               = "${var.app_name}-${var.env}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sec_group.id]
  subnets            = [for subnet_id in var.public_subnets : subnet_id]
}

################################################
##### Backend Load Balancer Security Group #####
################################################
resource "aws_security_group" "load_balancer_sec_group" {
  name        = "${var.app_name}-${var.env}-load-balancer-sec-group"
  description = "Allow SSH access from VPC and Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Public Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-${var.env}-load-balancer-sec-group"
  }
}

##############################################
##### Backend Load Balancer Target Group #####
##############################################
resource "aws_lb_target_group" "target_group" {
  name     = "${var.app_name}-${var.env}-target-group"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    matcher = "200"
    path    = "/api/docs/"
  }
}

############################################
##### Backend Target Group Attachments #####
############################################
resource "aws_lb_target_group_attachment" "tg_attach" {
  count            = 3 #This can be passed as variable.
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = element(split(",", join(",", aws_instance.backend.*.id)), count.index)
  port             = 8000
}

##########################################
##### Backend Load Balancer Listener #####
##########################################
resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

############################################
##### Backend Elasticache Subnet Group #####
############################################
resource "aws_elasticache_subnet_group" "cache_sub_group" {
  name        = "${var.app_name}-${var.env}-cache-subnet-group"
  description = "Subnet Group for Elasticache Redis"
  subnet_ids  = var.private_subnets
}

##############################################
##### Backend Elasticache Security Group #####
##############################################
resource "aws_security_group" "cache_sec_group" {
  name        = "${var.app_name}-${var.env}-cache-sec-group"
  description = "Enable Redis access to instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis Access"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.instance_sec_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-${var.env}-cache-sec-group"
  }
}

#################################################
##### Backend Elasticache Replication Group #####
#################################################
resource "aws_elasticache_replication_group" "cache_replication_group" {
  replication_group_id       = "${var.app_name}-${var.env}-replication-group"
  description                = "Replication Group Redis"
  engine                     = "redis"
  engine_version             = "6.x"
  node_type                  = var.cache_node_type
  port                       = 6379
  parameter_group_name       = "default.redis6.x.cluster.on"
  subnet_group_name          = aws_elasticache_subnet_group.cache_sub_group.name
  security_group_ids         = [aws_security_group.cache_sec_group.id]
  automatic_failover_enabled = true
  num_node_groups            = 2
  replicas_per_node_group    = 2
  maintenance_window         = "sat:23:00-sun:01:30"
  multi_az_enabled           = true
  snapshot_retention_limit   = 5
  snapshot_window            = "13:00-16:00"
}

############################################
##### Backend Database Parameter Group #####
############################################
resource "aws_db_parameter_group" "rds_parameter_group" {
  name        = "${var.app_name}-${var.env}-rds-parameter-group"
  description = "Parameter Group for MySQL Database"
  family      = "mysql8.0"

  parameter {
    name  = "time_zone"
    value = "Asia/Taipei"
  }
}

############################################
##### Backend Database Monitoring Role #####
############################################
resource "aws_iam_role" "rds_monitoring_role" {
  name        = "${var.app_name}-${var.env}-rds-monitor-role"
  description = "To be able to execute DLM to automatically create EBS snapshots"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
}

###########################################
##### Backend Database Security Group #####
###########################################
resource "aws_security_group" "db_security_group" {
  name        = "${var.app_name}-${var.env}-db-security-group"
  description = "Ingress for CIDRIP"
  vpc_id      = var.vpc_id

  ingress {
    cidr_blocks = [var.vpc_cidr]
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
  }
}

#########################################
##### Backend Database Subnet Group #####
#########################################
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.app_name}-${var.env}-db-subnet-group"
  description = "Subnet group for RDS"
  subnet_ids  = var.private_subnets

  tags = {
    Name    = "${var.app_name}-${var.env}-db-subnet-group",
    Purpose = "Backend Deployment"
  }
}

#####################################
##### Backend Database Instance #####
#####################################
resource "aws_db_instance" "db_instance" {
  identifier             = "${var.app_name}-db-${var.env}"
  allocated_storage      = var.db_allocated_storage
  engine                 = "MySQL"
  engine_version         = "8.0.16"
  instance_class         = var.db_instance_class
  db_name                = join("", [var.app_name, var.env, "db"])
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.rds_parameter_group.name
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  monitoring_interval    = "60"
  monitoring_role_arn    = aws_iam_role.rds_monitoring_role.arn
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  skip_final_snapshot    = true
  multi_az               = true
}
