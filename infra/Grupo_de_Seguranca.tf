resource "aws_security_group" "acesso_geral" {
    name = var.grupoDeSeguranca
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        from_port = 0
        to_port = 0
        protocol = "-1"
    }
    ingress {
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        from_port        = 8080
        to_port          = 8080
        protocol         = "tcp"
    }
    egress{
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        from_port = 0
        to_port = 0
        protocol = "-1"
    }
    tags = {
        Name = "acesso_geral"
    }
}