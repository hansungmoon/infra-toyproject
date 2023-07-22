################################ VPC ####################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "tf-marketboro-vpc"
  cidr = "10.2.0.0/16"

  azs = [
    "ap-northeast-2a",
    "ap-northeast-2c"
  ]
  private_subnets = [
    "10.2.101.0/24",
    "10.2.102.0/24"
  ]
  public_subnets = [
    "10.2.1.0/24",
    "10.2.2.0/24"
  ]

  # Single NAT Gateway
  enable_nat_gateway     = false
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

################################ VPC 엔드포인트 ####################################
resource "aws_vpc_endpoint" "tf_s3_endpoint_gateway" {
  vpc_id               = module.vpc.vpc_id
  service_name         = "com.amazonaws.ap-northeast-2.s3"
  vpc_endpoint_type    = "Gateway"
  route_table_ids      = module.vpc.private_route_table_ids
}

resource "aws_vpc_endpoint" "tf_ecr_endpoint_api" {
  vpc_id               = module.vpc.vpc_id
  service_name         = "com.amazonaws.ap-northeast-2.ecr.api"
  vpc_endpoint_type    = "Interface"
  security_group_ids = [aws_security_group.private_sg.id]
  subnet_ids           = module.vpc.private_subnets
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "tf_ecr_endpoint_dkr" {
  vpc_id               = module.vpc.vpc_id
  service_name         = "com.amazonaws.ap-northeast-2.ecr.dkr"
  vpc_endpoint_type    = "Interface"
  security_group_ids = [aws_security_group.private_sg.id]
  subnet_ids           = module.vpc.private_subnets
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "tf_race_endpoint_logs" {
  vpc_id               = module.vpc.vpc_id
  service_name         = "com.amazonaws.ap-northeast-2.logs"
  vpc_endpoint_type    = "Interface"
  security_group_ids = [aws_security_group.private_sg.id]
  subnet_ids           = module.vpc.private_subnets
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "tf_race_endpoint_dynamodb" {
  vpc_id               = module.vpc.vpc_id
  service_name         = "com.amazonaws.ap-northeast-2.dynamodb"
  vpc_endpoint_type    = "Gateway"
  route_table_ids      = module.vpc.private_route_table_ids
}

################################ 보안그룹 ####################################

resource "aws_security_group" "public_sg" {

  name = "TRF_SG_PUBLIC"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "TRF-SG-PUB"
  }
}

resource "aws_security_group" "private_sg" {

  name = "TRF_SG_PRIVATE"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "TRF-SG-PRV"
  }
}
