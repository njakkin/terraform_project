provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}


resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}


# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "default" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t1.micro"
}



#source registry is from https://registry.terraform.io/modules/ulamlabs/rabbitmq/aws/2.0.0
module "rabbitmq" {
  source                            = "ulamlabs/rabbitmq/aws"
  version                           = "2.0.0"
  vpc_id                            = "${aws_vpc.default.id}"
  ssh_key_name                      = "${var.ssh_key_name}"
  subnet_ids                        = ["${aws_subnet.default.id}"]
  elb_additional_security_group_ids = ["${aws_security_group.default.id}"]
  min_size                          = "2"
  max_size                          = "2"
  desired_size                      = "2"
  #instance_type can be specified or default would be m4.large / this key can be moved to variables.tf
  #instance_type                     = "t1.micro"
}