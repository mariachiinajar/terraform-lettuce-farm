resource "aws_instance" "app_server" {
  ami           = "ami-022e1a32d3f742bd8"
  instance_type = "t2.micro"

  tags = {
    Name = "AppServer"
  }
}

