
provider "aws" {
    region = "us-east-2"
}

variable "port" {
    default = 8080
}

variable "ami_free" {
    default = "ami-0fb653ca2d3203ac1"
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    ingress {
        from_port = var.port
        to_port = var.port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # egress {
    #     from_port   = 0
    #     to_port     = 0
    #     protocol    = "-1"
    #     cidr_blocks = ["0.0.0.0/0"]
    # }
}

resource "aws_instance" "example" {
    ami = var.ami_free
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    # associate_public_ip_address = true # Ensures a public IP is assigned
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World" > index.html
        nohup busybox httpd -f -p ${var.port} &
        EOF
    user_data_replace_on_change = true
    tags = {
        name = "terraform-example"
    }
}

output "public_ip" {
    value = "http://${aws_instance.example.public_ip}:${var.port}"
}
