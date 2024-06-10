
# 1resources：VPC,subnet(a,c),IGW,routetable,endpoint(dynamoDb,s3)
# 2output 


############
# リソース定義
############
# ----------
# VPC
# ----------
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr_block #"10.0.0.0/19"
  enable_dns_support   = true #Public DNSを割り当てるため
  enable_dns_hostnames = true #Public DNSを割り当てるため

  tags = {
    Name = "${var.create_by}-${var.my_env}-vpc"
  }
}

# ---------------------------
# Subnet
# ---------------------------
# PublicSubnet1a
resource "aws_subnet" "public_1a_sn" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = var.az_a

  tags = {
    Name = "${var.create_by}-${var.my_env}-subneta"
  }
}

# PublicSubnet1c
resource "aws_subnet" "public_1c_sn" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az_c

  tags = {
    Name = "${var.create_by}-${var.my_env}-subnetc"
  }
}



# PrivateSubnet1a
resource "aws_subnet" "private_1a_sn" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.8.0/24"
  availability_zone = var.az_a

  tags = {
    Name = "${var.create_by}-${var.my_env}-private-1a-sn"
  }
}

# PrivateSubnet1c
resource "aws_subnet" "private_1c_sn" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.9.0/24"
  availability_zone = var.az_c

  tags = {
    Name = "${var.create_by}-${var.my_env}-private-1c-sn"
  }
}



# ----------
# IGW
# ----------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.create_by}-${var.my_env}-igw"
  }
}


# # ----------
# # IGWAttachment　→ 不要　理由：デフォでIGWアタッチされている。記載すると”terraform apply”でエラー
# # ----------
#resource "aws_internet_gateway_attachment" "gw_att" {
#  internet_gateway_id = aws_internet_gateway.gw.id
#  vpc_id              = aws_vpc.main_vpc.id
#}

# ---------------------------
# Route table
# ---------------------------
# Route table作成
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.create_by}-${var.my_env}-rt"
  }
}

# PublicSubnet1aとRoute tableの関連付け
resource "aws_route_table_association" "public1a_rt_associate" {
  subnet_id      = aws_subnet.public_1a_sn.id
  route_table_id = aws_route_table.public_rt.id
}

# PublicSubnet1cとRoute tableの関連付け
resource "aws_route_table_association" "public1c_rt_associate" {
  subnet_id      = aws_subnet.public_1c_sn.id
  route_table_id = aws_route_table.public_rt.id
}


# ---------------------------
# endpoint
# ---------------------------
resource "aws_vpc_endpoint" "dynamoDB" {
  vpc_id       = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.ap-northeast-1.dynamodb"

  tags = {
    Environment = "${var.create_by}-${var.my_env}-epdynamoDB"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.ap-northeast-1.s3"

  tags = {
    Environment = "${var.create_by}-${var.my_env}-eps3"
  }
}




############
# Output定義
############
# 名前付けの上、ターミナルへの出力・他ファイルからの参照
# 同じファイル内なら、VPC IDは「aws_vpc.main_vpc.id」で参照ができる
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}
output "public1a_id" {
  value = aws_subnet.public_1a_sn.id
}
output "public1c_id" {
  value = aws_subnet.public_1c_sn.id
}
output "private1a_id" {
  value = aws_subnet.private_1a_sn.id
}
output "private1c_id" {
  value = aws_subnet.private_1c_sn.id
}
