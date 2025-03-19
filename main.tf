provider "aws" {
  region = var.region
  profile = "sandbox"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "ssm-vpc"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "main_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}b"
}

resource "aws_subnet" "main_subnet_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}c"
}


resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.region}a"
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ssm-internet-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "ssm-public-rtb"
  }
}

resource "aws_route_table_association" "testapp-custom-rtb-public-subnet" {
  count          = 1
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "ssm_instance" {
  ami                    = "ami-00bc358fb32983be0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids = [aws_security_group.ssm_ec2_https.id]
  associate_public_ip_address = true
  tags = {
    Name = "SSMInstance"
  }
}

# resource "aws_instance" "ssm-private-instance" {
#   ami                    = "ami-00bc358fb32983be0"
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.main_subnet.id
#   vpc_security_group_ids = [aws_security_group.sg_all.id]

#   tags = {
#     Name = "SSMPrivateInstance"
#   }
# }

resource "aws_db_subnet_group" "sbg_database" {
  name       = "ssm-database-subnet-group"
  subnet_ids = [
    aws_subnet.main_subnet.id,
    aws_subnet.main_subnet_b.id,
    aws_subnet.main_subnet_c.id
  ]

  tags = {
    Name = "mydb-subnet-group"
  }
}

# resource "aws_db_instance" "database" {
#   identifier        = "ssm-database-example"
#   allocated_storage = 50
#   engine            = "mysql"
#   engine_version    = "8.0"
#   instance_class    = "db.t3.micro"
#   username          = "root"
#   password          = "pawsd098"
#   skip_final_snapshot = true
#   db_subnet_group_name = aws_db_subnet_group.sbg_database.name
#   vpc_security_group_ids = [aws_security_group.ssm_sg_db.id]
#   tags = {
#     Name = "ssm-database-example"
#   }
# }

output "instance_id" {
  value = aws_instance.ssm_instance.id
}

# output "rds_endpoint" {
#   value = aws_db_instance.database.endpoint
# }
