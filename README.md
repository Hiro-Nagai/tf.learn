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
![構成図](https://raw.githubusercontent.com/Hiro-Nagai/tf.learn/main/image%2018.45.27.png)

## フォルダ構成

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

## 手順１-準備　空フォルダ作成

* ユーザ名のディレクトリの下に以下の手順でディレクトリ作成
```bash
$ mkdir ~/tf.learn/
```
* 先にGitHubでリモートリポジトリを作成してローカルに"git clone"で降ろすとこから始める
```bash
# <最上階のフォルダ作成>
$ git clone https://github.com/username/tf.learn.git
$ cd tf.learn
$ mkdir modules && cd $_
$ touch aws-vpc.tf aws-sg.tf aws-ec2.tf aws-rds.tf aws-alb.tf aws-s3.tf variables.tf
# <stgのフォルダ作成>
$ mkdir ../stg
$ cd ../stg
$ touch main.tf
$ cd ../
$ pwd
/c/Users/username/tf.learn
# <当該ディレクトリではこのバージョンで使うことを指定>
$ tfenv pin 
Pinned version by writing "1.8.5" to /c/Users/username/tf.learn/.terraform-version
$ ls -al | grep .terra
$ cat .terraform-version
1.7.0
$ cd ../
$ pwd
/c/Users/username/tf.learn
```


## 手順２-Backend機能を使う
目的としては、tfstateをS3に置いて、チームで共有できるようにする。

先に以下のコマンドでS3バケットを生成しておく
```bash
$ aws s3 mb s3://tf.learn
make_bucket: tf.learn
```
backendの定義をmain.tfに追記
```bash
# backendの定義
terraform {
  backend "s3" {
    bucket = "tf.learn"
    key = "tf.learn/stg/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
```


## 手順3-各moduleを作成
stgのディレクトリで`terraform init`してから以下の順に操作
```bash
$ terraform fmt
$ terraform validate    #細かいルールに慣れなくて、何度も繰り返した
$ terraform apply
```


<details><summary>以下参考(ほぼTerraform公式)</summary>

### main.tfを編集
#### module構成の参考記事
わかりやすかったものをピックアップして以下にメモ
* https://dev.classmethod.jp/articles/directory-layout-bestpractice-in-terraform/
* https://qiita.com/reireias/items/253529c889cafb3fa4c7


### vpc.tfを編集
#### 参考記事
* [【Terraform入門】AWSのVPCとEC2を構築してみる](https://kacfg.com/terraform-vpc-ec2/)
* 公式doc
  * https://kacfg.com/terraform-vpc-ec2/
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway_attachment
  * 
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
    * Routeととしてのresource記載は不要で、RouteTableのresource内部にrouteの内容を記述できる
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association

### sg.tfを編集
#### 参考記事
* https://dev.classmethod.jp/articles/terraform-security-group/
* https://beyondjapan.com/blog/2022/10/terraform-how-to-use-security-group/
* 公式
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
    * 特にRDS用のセキュリティグループのインバウンドルールにおけるソースをEC2用のセキュリティグループIDにするという方法の参照として使いました。↓の参考記事も同様です。
* https://ohshige.hatenablog.com/entry/2019/11/11/190000
* https://qiita.com/suzuki0430/items/2dbd88dfb5ed53016914

### ec2.tfを編集
#### 参考記事
* https://zenn.dev/supersatton/articles/c87853cc5a3dbd
* https://qiita.com/okdyy75/items/73641a0247bae1fa7f31
* https://khasegawa.hatenablog.com/entry/2017/10/03/000000
* [[Terraform][CloudFormation]最新のAMI IDの取得方法](https://qiita.com/to-fmak/items/7623ee6e15249a4bcedd#:~:text=%E3%80%8CData%20Source%E3%80%8D%E3%81%A7%E6%9C%80%E6%96%B0%E3%81%AE,AMI%E3%82%92%E5%8F%96%E5%BE%97%E3%81%A7%E3%81%8D%E3%81%BE%E3%81%99%E3%80%82)
* 公式
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance

### rds.tfを編集
#### 参考記事
* https://zenn.dev/suganuma/articles/fe14451aeda28f
* https://tech.isid.co.jp/entry/terraform_manage_master_user_password
* https://zenn.dev/yumemi_inc/articles/081b0190db8260
* 公式
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance

### alb.tfとs3.tfを編集
#### 参考記事
* https://katsuya-place.com/terraform-elb-basic/
* https://cloud5.jp/terraform-alb/
* https://y-ohgi.com/introduction-terraform/handson/alb/
* 公式
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
  * https://www.terraform.io/docs/providers/aws/r/lb_listener.html
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

</details>


## 手順4-terraform apply
terrform applyの際、エラーあり（定義がない、インデントずれ、変数が違うetc）
ほぼ文法間違いのくだらないミスエラー。terraform公式で対応


### terraform apply 完了

## 手順5-結果を検証-terraform destroyまで
検証対象
  - EC2  →   SSH接続で
  - RDS  →   EC2からRDS(mysql)への接続
  - ALB  →   EC2内でNginx起動させ、ALBのDNSを入力して確認

<details><summary>(詳細)検証した結果</summary>

#### SSH接続
22ポートの記述もれあり。02-sg.tfの"sg_ec2"に以下追記

```bash
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
```
マネコン画面EC2→keypairにて発行
.sshにDLしたKeyPairファイル入れて以下実行

```bash
ssh -i ~/.ssh/(KeyPair).pem ec2-user@(Public IPv4 DNS).ap-northeast-1.compute.amazonaws.com
```
※今回はEIPを使っていないので”Public IPv4 DNS”はEC2起動ごとに変化するので注意

#### RDS接続＆Nginx起動確認
```bash
#　※EC2接続状態で
#　<RDS接続確認>
$ sudo yum update
$ sudo yum install mysql
$ mysql -u admin -p -h (RDSのエンドポイント)
#Parameter Storeに保管しているパスワードを入力
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 21
Server version: 8.0.33 Source distribution
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [(none)]> exit
Bye
#　<Nginx起動>
$ amazon-linux-extras list | grep nginx
$ sudo amazon-linux-extras install nginx1
$ nginx -v
nginx version: nginx/1.22.1
$ sudo systemctl start nginx
$ sudo systemctl status nginx
$ sudo systemctl enable nginx
$ systemctl is-enabled nginx
#　<ALB動作確認>
$ curl http://alb-tf-*********.ap-northeast-1.elb.amazonaws.com/(DNS name)
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
$ exit
```

#### インフラ削除-terraform destoyを実行する
##### リソース情報取得-削除対象を認識する
* 今回Terraformで作ったリソースはtagを入れているので、tagがついたリソースを、AWS CLIで取得
  * 公式）https://awscli.amazonaws.com/v2/documentation/api/latest/reference/resourcegroupstaggingapi/get-resources.html

まずはリソースの情報取得
https://docs.aws.amazon.com/cli/latest/reference/resourcegroupstaggingapi/get-resources.html
```bash
$ aws resourcegroupstaggingapi get-resources --no-paginate --region ap-northeast-1 \
--tag-filters Key=Name,\
Values=terraform-stg,terraform-stg-public-1a-sn,terraform-stg-public-1c-sn
```
取得した値は以下（多いので抜粋）※イメージ湧かせるために抜粋だけでも記載
```json
        {
            "ResourceARN": "arn:aws:ec2:ap-northeast-1:************:route-table/rtb-0b42571d2f38c6100",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "terraform-stg-rt"
                }
            ]
        },
        {
            "ResourceARN": "arn:aws:ec2:ap-northeast-1:************:security-group/sg-0a623d83ccb77cd23",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "terraform-stg-sg"
                }
            ]
        },

```

##### ALBのアクセスログをオフにする
ALBのアクセスログがS3バケットに過剰に溜まる。まずは、ログの蓄積を解除する。
https://docs.aws.amazon.com/cli/latest/reference/elbv2/modify-load-balancer-attributes.html
```bash
aws elbv2 modify-load-balancer-attributes --load-balancer-arn arn:aws:elasticloadbalancing:ap-northeast-1:************:loadbalancer/app/alb-tf/036cf7d537523dd9 --attributes Key=access_logs.s3.enabled,Value=false
```
※「**********」はarn伏せ字


以下のように返され、マネコンでもアクセスログがオフになっている。ALBの「Attributes属性」情報で他パラメータも含めて返っている。
```json
{
    "Attributes": [
        {
            "Key": "access_logs.s3.enabled",
            "Value": "false"  //オフになっています
        },
        {
            "Key": "access_logs.s3.bucket",
            "Value": "s3-alb-log-tf"
        },
        {
            "Key": "access_logs.s3.prefix",
            "Value": ""
        },
        {
            "Key": "idle_timeout.timeout_seconds",
            "Value": "60"
        },
        {
            "Key": "deletion_protection.enabled",
            "Value": "false"
        },
        {
            "Key": "routing.http2.enabled",
            "Value": "true"
        },
        {
            "Key": "routing.http.drop_invalid_header_fields.enabled",
            "Value": "false"
        },
        {
            "Key": "routing.http.xff_client_port.enabled",
            "Value": "false"
        },
        {
            "Key": "routing.http.preserve_host_header.enabled",
            "Value": "false"
        },
        {
            "Key": "routing.http.xff_header_processing.mode",
            "Value": "append"
        },
        {
            "Key": "load_balancing.cross_zone.enabled",
            "Value": "true"
        },
        {
            "Key": "routing.http.desync_mitigation_mode",
            "Value": "defensive"
        },
        {
            "Key": "waf.fail_open.enabled",
            "Value": "false"
        },
        {
            "Key": "routing.http.x_amzn_tls_version_and_cipher_suite.enabled",
            "Value": "false"
        },
        {
            "Key": "connection_logs.s3.enabled",
            "Value": "false"
        },
        {
            "Key": "connection_logs.s3.bucket",
            "Value": ""
        },
        {
            "Key": "connection_logs.s3.prefix",
            "Value": ""
        }
    ]
}
```


##### ALBのアクセスログ用のS3バケット内を空にする
```bash
$ aws s3 rm s3://s3-alb-log-tf --recursive
```


##### VPC内にあるEC2インスタンスを削除
* 公式）https://docs.aws.amazon.com/cli/latest/reference/ec2/terminate-instances.html
* https://blog.serverworks.co.jp/2020/01/10/000000
```bash
$ aws ec2 terminate-instances --instance-ids i-0791f5b3652cd1e1e
#以下の通り返される
{
    "TerminatingInstances": [
        {
            "CurrentState": {
                "Code": 32,
                "Name": "shutting-down"
            },
            "InstanceId": "i-0791f5b3652cd1e1e",
            "PreviousState": {
                "Code": 16,
                "Name": "running"
            }
        }
    ]
}
```

##### VPC内にあるRDSインスタンスを削除
公式）https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_DeleteInstance.html
https://qiita.com/tcsh/items/d7ca66fe8251f865c668
```bash
aws rds delete-db-instance \
    --db-instance-identifier terraform-20240105055854660100000002 \
    --skip-final-snapshot \
    --delete-automated-backups
#以下の通り返される
{
    "DBInstance": {
        "DBInstanceIdentifier": "terraform-20240105055854660100000002",
        "DBInstanceClass": "db.t3.micro",
        "Engine": "mysql",
        "DBInstanceStatus": "deleting",
        "MasterUsername": "admin",
        "Endpoint": {
            "Address": "terraform-20240105055854660100000002.c7nzmtxyau6j.ap-northeast-1.rds.amazonaws.com",
            "Port": 3306,
            "HostedZoneId": "Z24O6O9L7SGTNB"
        },
        "AllocatedStorage": 10,
        "InstanceCreateTime": "2024-01-05T06:02:01.112Z",
        "PreferredBackupWindow": "15:01-15:31",
        "BackupRetentionPeriod": 0,
        "DBSecurityGroups": [],
        "VpcSecurityGroups": [
            {
                "VpcSecurityGroupId": "sg-00dbf655578e404fc",
                "Status": "active"
            }
        ],
        "DBParameterGroups": [
            {
                "DBParameterGroupName": "default.mysql8.0",
                "ParameterApplyStatus": "in-sync"
            }
        ],
        "AvailabilityZone": "ap-northeast-1c",
        "DBSubnetGroup": {
            "DBSubnetGroupName": "dbsng_tf",
            "DBSubnetGroupDescription": "Managed by Terraform",
            "VpcId": "vpc-0b2521d9a5e690b70",
            "SubnetGroupStatus": "Complete",
            "Subnets": [
                {
                    "SubnetIdentifier": "subnet-01f2b56b3b0e50b82",
                    "SubnetAvailabilityZone": {
                        "Name": "ap-northeast-1a"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-0f82d6778caf3a507",
                    "SubnetAvailabilityZone": {
                        "Name": "ap-northeast-1c"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                }
            ]
        },
        "PreferredMaintenanceWindow": "thu:17:09-thu:17:39",
        "PendingModifiedValues": {},
        "MultiAZ": false,
        "EngineVersion": "8.0.33",
        "AutoMinorVersionUpgrade": true,
        "ReadReplicaDBInstanceIdentifiers": [],
        "LicenseModel": "general-public-license",
        "OptionGroupMemberships": [
            {
                "OptionGroupName": "default:mysql-8-0",
                "Status": "in-sync"
            }
        ],
        "PubliclyAccessible": false,
        "StorageType": "gp2",
        "DbInstancePort": 0,
        "StorageEncrypted": false,
        "DbiResourceId": "db-55UM2BIVUVOLVMKO4VIWSWDLSA",
        "CACertificateIdentifier": "",
        "DomainMemberships": [],
        "CopyTagsToSnapshot": false,
        "MonitoringInterval": 0,
        "DBInstanceArn": "arn:aws:rds:ap-northeast-1:************:db:terraform-20240105055854660100000002",
        "IAMDatabaseAuthenticationEnabled": false,
        "PerformanceInsightsEnabled": false,
        "DeletionProtection": false,
        "AssociatedRoles": [],
        "TagList": [
            {
                "Key": "Name",
                "Value": "20240105-terraform-stage"
            }
        ],
        "CustomerOwnedIpEnabled": false,
        "BackupTarget": "region",
        "NetworkType": "IPV4",
        "StorageThroughput": 0,
        "DedicatedLogVolume": false
    }
}
```

##### 一旦ここまでで`terraform destroy`
* Terraformで作ったリソースはすべて削除できた。(バージョンによっては、手動でのリソーセス削除が不要で、"terraform destroy"のみで削除できるらしい)


</details>



## 学んだこと


### ハマったエラー




