# main.tf内で記述する変数についての定義
# 各moduleの.tfファイル内に登場する変数はmodulesフォルダ内"variables.tf"ファイルに記述

variable "region" {
  # default = "ap-northeast-1"
  description = "AWS region"
}

variable "mysqlusername" {}
 