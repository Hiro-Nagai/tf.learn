

############
# データ取得の定義
############
#System ManegerのParameter Storeに保管しているPWを取得　※予め作成すること
#ParameterStore→無料　SecretManager→有料　∴　ParameterStoreにした
#現場で書くなら変数扱いにしたほうがいいと思います
data "aws_ssm_parameter" "ssm_paramstr_pw_tf" {
  name            = "RDSMasterPassword"
  with_decryption = true
}


############
# リソース定義
############
#DBSubnetGroup作成（RDSを入れるvpcを指定するため）
resource "aws_db_subnet_group" "dbsng_tf" {
  name       = "dbsng_tf"
  subnet_ids = [aws_subnet.private_1a_sn.id, aws_subnet.private_1c_sn.id]

  tags = {
    Name = "${var.create_by}-${var.my_env}-db_sng"
  }
}

#DBインスタンスRDS作成
resource "aws_db_instance" "rds_tf" {
  allocated_storage = 10
  #↓「An argument named "db_name" is not expected here.」と言われたのでコメントアウト
  # db_name           = "rds"
  engine            = var.dbengine
  engine_version    = var.dbengine_version
  instance_class    = var.dbinstance_class
  #mysqlのusernameは"admin"と書いてもよかったが、今回はtfvarsに変数として入れ、公開しない（.gitignore）と仮定してこの記述とした
  username          = var.mysqlusername
  availability_zone = var.az_c
  multi_az          = false
  #dataで取得した値を入れる
  password            = data.aws_ssm_parameter.ssm_paramstr_pw_tf.value
  skip_final_snapshot = true
  #上で作成したsubnet_groupを入れ、適用するvpcを指定
  db_subnet_group_name   = aws_db_subnet_group.dbsng_tf.name
  vpc_security_group_ids = [aws_security_group.sg_rds.id]

  tags = {
    Name = "${var.create_by}-${var.my_env}-rdsinstance"
  }
}

############
# Output定義
############
output "dbsng_tf" {
  value = aws_db_subnet_group.dbsng_tf.id
}

output "db-entpoint" {
  value = aws_db_instance.rds_tf.endpoint
}
