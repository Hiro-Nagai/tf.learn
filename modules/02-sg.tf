# 1resources：ec2sg,albsg,rdssg
# 2output 


############
# リソース定義
############
# albの後ろのEC2（webサーバ）用のsg：HTTP(80ポート),SSH接続(22ポート)
resource "aws_security_group" "sg_ec2" {
  name        = "sg_ec2"
  description = "sg_ec2"
  vpc_id      = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.create_by}-${var.my_env}-sg_ec2viaalb"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# ALB用のsg：HTTP(80ポート)HTTPs(443ポート)
resource "aws_security_group" "sg_alb" {
  name        = "sg_alb"
  description = "sg_alb"
  vpc_id      = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.create_by}-${var.my_env}-sg_alb"
  }

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
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS用のsg：MySQL用の3306
resource "aws_security_group" "sg_rds" {
  name        = "sg_rds"
  description = "sg_rds"
  vpc_id      = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.create_by}-${var.my_env}-sg_rds"
  }
}
# RDS用のsgのルール｜source_security_group_idを使いたいので"aws_security_group_rule"を使った
resource "aws_security_group_rule" "sg_rds_ingress" {
  type                     = "ingress"
  to_port                  = 3306
  from_port                = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg_rds.id
  source_security_group_id = aws_security_group.sg_ec2.id
}

############
# Output定義
############

output "sg_ec2_id" {
  value = aws_security_group.sg_ec2.id
}
output "sg_alb_id" {
  value = aws_security_group.sg_alb.id
}
output "sg_rds_id" {
  value = aws_security_group.sg_rds.id
}
