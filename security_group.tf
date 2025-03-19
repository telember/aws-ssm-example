resource "aws_security_group" "ssm_ec2_https" {

  name        = "ssm_ec2_https"
  description = "Allow SSM traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
     Name = "ssm_ec2_https"
  }
}

resource "aws_security_group" "ssm_sg_db" {
  name        = "ssm_sg_db"
  description = "database sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "ssm_sg_db"
  }
}

resource "aws_security_group" "sg_all" {
  name        = "allow all private network"
  description = "allow all private network"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.main_subnet.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
      Name = "ssm_all_sg"
  }
}