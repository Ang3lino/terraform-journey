
variable "http_port" {
  default = 80
}

variable "ssh_port" {
  default = 22
}

# variable "ami_free" { default = "ami-0fb653ca2d3203ac1" }
# changed when using us-east-1
variable "ami_free" {
  default = "ami-063d43db0594b521b"
}

variable "ec2_type" {
  default = "t2.micro"
}
