data "aws_ami" "amazonlinux" {
  most_recent = true

  # search the image with the following conditions
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    # type of AMI (ie: hvm or paravirtual).
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"]
}

resource "aws_security_group" "public" {
  name        = "public"
  description = "allows public traffic"
  vpc_id      = aws_vpc.main.id

  # Exclusively allow ssh traffic
  # only from your machine. 
  ingress {
    description = "ssh from local machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["211.237.245.156/32"]
  }

  # traffic goes out to the internet, to all clients. 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "public"
    environment = var.environment[0]
    terraform   = var.terraform
  }
}

resource "aws_instance" "public" {
  count = length(var.public_subnet_cidr_blocks)

  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.public.id]
  associate_public_ip_address = true
  key_name                    = "greenhouse"
  # putin_khuylo                = true

  tags = {
    Name        = "PublicAppServer-${count.index}"
    environment = var.environment[0]
    terraform   = var.terraform
  }
}

resource "aws_security_group" "private" {
  name        = "private"
  description = "Allows traffic within VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "private"
    environment = var.environment[0]
    terraform   = var.terraform
  }
}

resource "aws_instance" "private0" {
  count                       = length(var.private_subnet_cidr_blocks)
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private[count.index].id
  vpc_security_group_ids      = [aws_security_group.private.id]
  associate_public_ip_address = false
  key_name                    = "greenhouse"
  # putin_khuylo                = true

  tags = {
    Name        = "private-${var.environment[0]}"
    environment = var.environment[0]
    terraform   = var.terraform
  }
}

resource "aws_instance" "private1" {
  count                       = length(var.private_subnet_cidr_blocks)
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private[count.index].id
  vpc_security_group_ids      = [aws_security_group.private.id]
  associate_public_ip_address = false
  key_name                    = "greenhouse"
  # putin_khuylo                = true

  tags = {
    Name        = "private-${var.environment[1]}"
    environment = var.environment[1]
    terraform   = var.terraform
  }
}


output "public_ip_address" {
  value = aws_instance.public[*].public_ip
}
