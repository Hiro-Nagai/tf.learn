#タグ情報==================
#完成例：terraform-prd-vpc
variable "create_by" {
  default     = "terraform"
  description = "create_by tag"
}
variable "my_env" {
  default     = "prd"
  description = "enviroment tag"
}
#=========================


#=========================
# ネットワーク関連の変数定義
#=========================

variable "vpc_cidr_block" {}
variable "az_a" {
  default     = "ap-northeast-1a"
  description = "availability_zone_a"
}
variable "az_c" {
  default     = "ap-northeast-1c"
  description = "availability_zone_c"
}

#=========================
# EC2関連の変数定義
#=========================
variable "ec2key_name" {}
variable "ec2instance_type" {
  default = "t2.micro"
  description = "ec2 via alb t2.micro"
}


#=========================
# RDS関連の変数定義
#=========================
variable "dbengine" {}
variable "dbengine_version" {}
variable "dbinstance_class" {
  default = "db.t3.micro"
  description = "rds t3.micro"
}
variable "mysqlusername" {}
