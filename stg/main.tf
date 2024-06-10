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

}
