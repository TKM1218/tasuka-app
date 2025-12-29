# tasuka-app

## Terraform: tfstate bootstrap手順（S3 backend）

### よく出るエラー
```
Error: Backend initialization required, please run "terraform init"
Reason: Initial configuration of the requested backend "s3"
```

### 原因
`backend.tf` が存在すると、Terraform は **S3 backend が初期化済みであること**を必須とします。  
まだ S3 バケットや DynamoDB ロックテーブルが無い段階で `apply` すると、このエラーになります。

### 回避手順（初回のみ）
1. `backend.tf` を一時的にコメントアウト（または退避）
2. ローカル state で初回 `apply`（tfstate リソースのみ）
3. `backend.tf` を元に戻す
4. `init -migrate-state` で S3 へ移行

例:
```
# backend.tf を一時退避（コメントアウトでも可）
mv infra/envs/dev/backend.tf infra/envs/dev/backend.tf.disabled

terraform -chdir=infra/envs/dev init
terraform -chdir=infra/envs/dev apply \
  -target=aws_s3_bucket.tfstate \
  -target=aws_dynamodb_table.tfstate_lock

# backend.tf を戻す
mv infra/envs/dev/backend.tf.disabled infra/envs/dev/backend.tf

terraform -chdir=infra/envs/dev init -migrate-state
```

以後は通常の `terraform init` / `terraform apply` で動作します。

## Infra
`infra/` 配下に Terraform 構成があります。
