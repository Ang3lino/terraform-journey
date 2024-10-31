
provider "aws" { region = "us-east-2" }

variable "http_port" { default = 80 }
variable "portal_port" { default = 8080 }
variable "all_cidr" { default = "0.0.0.0/0" }
variable "ami_free" { default = "ami-0fb653ca2d3203ac1" }


resource "aws_security_group" "instance" {
    name = "tf-example-instance"
    ingress {
        from_port = var.portal_port
        to_port = var.portal_port
        protocol = "tcp"
        cidr_blocks = [var.all_cidr]
    }
}

# ALB blocks all incoming or outgoing traffic by default, thus this is required 
resource "aws_security_group" "alb" {
    name = "tf-example-alb"
    ingress {
        from_port = var.http_port
        to_port = var.http_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# resource "aws_launch_configuration" "as_config" {
resource "aws_launch_template" "as_template" {
    name_prefix = "tf-example-"
    image_id = var.ami_free
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    user_data = base64encode(<<-EOF
        #!/bin/bash
        echo "Hello, World" > index.html
        nohup busybox httpd -f -p ${var.portal_port} &
        EOF
    )

    lifecycle {
      create_before_destroy = true
    }
}


data "aws_vpc" "default" { default = true }
data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}


resource "aws_autoscaling_group" "example" {
    launch_template {
      id = aws_launch_template.as_template.id
      version = "$Latest"
    }
    # launch_configuration = aws_launch_configuration.as_conf.name
    vpc_zone_identifier = data.aws_subnets.default.ids

    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    min_size = 2
    max_size = 10

    tag {
        key = "Name"
        value = "tf-asg-example"
        propagate_at_launch = true
    }
}

# ALB
resource "aws_lb" "example" {
    name = "tf-asg-example"
    load_balancer_type = "application"
    subnets = data.aws_subnets.default.ids
    security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "404: not found"
            status_code = 404
        }
    }
}

resource "aws_lb_target_group" "asg" {
  name = "tf-asg-example"
  port = var.portal_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100
    condition {
        path_pattern {
            values = ["*"]
        }
    }
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}

output "alb_dns_name" {
    value = aws_lb.example.dns_name
    description = "Domain name of the server"
}
