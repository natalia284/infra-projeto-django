terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.regiao_aws
}
resource "aws_launch_template" "maquina" {
  image_id = "ami-0cf2b4e024cdb6960"
  instance_type = var.instancia
  key_name = var.chave
  tags = {
    Name = "Terraform Ansible Python"
  }
  security_group_names = [ var.grupoDeSeguranca ]
  user_data = base64encode(file("/home/natalia/Música/IaC/env/Prod/ansible.sh"))
  
}

resource "aws_key_pair" "chaveSSH" {
  key_name = var.chave
  public_key = file("${var.chave}.pub")
  
}

resource "aws_autoscaling_group" "grupo" {
  availability_zones = ["${var.regiao_aws}a", "${var.regiao_aws}b"]
  name = var.nomeGrupo
  max_size = var.maximo
  min_size = var.minino
  launch_template {
    id = aws_launch_template.maquina.id
    version = "$Latest"
  }
  target_group_arns = var.producao ? [aws_lb_target_group.alvoLoadBalancer[0].arn ] : [] 
}

resource "aws_default_subnet" "subnet_1" {
  availability_zone = "${var.regiao_aws}a"
}

resource "aws_default_subnet" "subnet_2" {
  availability_zone = "${var.regiao_aws}b"
}

resource "aws_lb" "loadBalancer" {
  internal = false
  subnets = [aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id]
  count = var.producao ? 1 : 0
}

resource "aws_default_vpc" "default" {
  
}

resource "aws_lb_target_group" "alvoLoadBalancer" {
  name = "maquinasAlvo"
  port = "8000"
  protocol = "HTTP"
  vpc_id = aws_default_vpc.default.id
  count = var.producao ? 1 : 0
}

resource "aws_lb_listener" "entradaLoadBalancer" {
  load_balancer_arn = aws_lb.loadBalancer[0].arn
  port = "8000"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alvoLoadBalancer[0].arn
  }
  count = var.producao ? 1 : 0
}

resource "aws_autoscaling_policy" "escala-Producao" {
  name = "terraform-escala"
  autoscaling_group_name = var.nomeGrupo
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
  count = var.producao ? 1 : 0
}
