# ルビコン塾CloudFormationで構築した環境をTerraformで構築する


## このレポジトリの目的

* terraformの自己学習として思考整理と備忘
* やったことの手順書(これを元に再度構築できるように)として残す
* 実施手順に対して、各時点での所感、反省など残す

## 方針
* Modulesの構成で構築することに。以下理由
   1. 多くのWeb系企業がこれをやっているイメージ。ざっくり調べたがだいたいこの３つ　１モジュールごと　２環境ごと　３大規模(１と２ミックスの上さらに細かく各ファイル設定されている)。
   2. 各リソースがモジュールとして分離されているので、疎結合で構築ができる。実際の開発現場でも、モジュールごとに開発することがあれば便利そう
   3. workspaceなど他にも構成があるが、直感的にこっちの方がわかりやすい

## 今回作成する構成図
VPC(sb2つ,各SG,EP),EC2,RDS,ALB,S3
![構成図](https://raw.githubusercontent.com/Hiro-Nagai/tf.study/main/image%2018.45.27.png)

## フォルダ構成
* .terraformフォルダ以下はstageディレクトリで`terraform init`で自動生成
```bash
\---tf.learn
    |   .terraform-version        #バージョン指定 1.7.0
    |
    +---modules
    |       01-vpc.tf
    |       02-sg.tf
    |       03-ec2.tf
    |       04-rds.tf
    |       05-alb.tf
    |       06-s3.tf
    |       variables.tf          #modules下のリソースファイル.tfで使う変数の中身を記述
    |
    \---stg
        |   .terraform.lock.hcl   #`terraform init`で自動生成　重い。これでハマった
        |   main.tf               #内容：provider,terraform,baskend,modules各ブロック＋modulesで使う変数
        |   terraform.tfvars      #stgディレクトリ下での変数定義
        |   variables.tf          #stgディレクトリ下での変数名
        |
        \---.terraform            #これ以下は`terraform init`で自動生成
            |   terraform.tfstate
            |
            +---modules
            |       modules.json
            |
            \---providers
                \---registry.terraform.io
                    \---hashicorp
                        \---aws
                            \---3.76.1
                                \---windows_amd64
                                        terraform-provider-aws_v3.76.1_x5.exe


```

## 手順
* ユーザ名のディレクトリの下に以下の手順でディレクトリ作成
```bash
$ mkdir ~/tf.study/
```

## 結果検証-terraform destroyまで


### 簡易的な結果確認

## 学んだこと


### ハマったエラー




