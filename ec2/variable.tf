variable "ami" {
    type = string
    default = "ami-05c13eab67c5d8861"
    description = "Ami ID"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
    description = "type of the instance"
}

variable "tags" {
    type = map
    description = "tags"
}

variable "public_subnet_id" {
    type = string
    description = "subnet id to launch ec2"
}

variable "vpc_id" {
    type = string
    description = "vpc-id to launch web-server sg"
}