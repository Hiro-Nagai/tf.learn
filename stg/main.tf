# provider
# 公式から　https://registry.terraform.io/providers/hashicorp/aws/latest/docs

terraform {
  required_version = "1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-1"
}

# backend
## terraformブロックの中では変数不可の為regionはハードコード
terraform {
  backend "s3" {
    bucket = "tf.learn"
    key    = "tf.learn/stg/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# moduleの利用
module "aws-modules" {
  # module位置
  source = "../modules"
  #=========================
  # 環境ごとの変数定義（今回はstg）
  #=========================
  # タグ定義
  my_env    = "stg"
  create_by = "terraform"

  # ネットワーク定義
  vpc_cidr_block = "10.0.0.0/16"

  # EC2定義
  ec2key_name      = "hiro-nagai"
  ec2instance_type = "t2.micro"

  # DB定義
  mysqlusername    = "admin"
  dbengine         = "mysql"
  dbengine_version = "8.0.33"
  dbinstance_class = "db.t3.micro"
}
