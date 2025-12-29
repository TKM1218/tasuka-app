# -------------------------------
# tables: lists
# -------------------------------
# リストのメタデータを格納。
resource "aws_dynamodb_table" "lists" {
  name         = "${var.name_prefix}-lists"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "listId"

  attribute {
    name = "listId"
    type = "S"
  }

  tags = var.tags
}

# -------------------------------
# tables: list_members
# -------------------------------
# リストのメンバーと権限を格納。
resource "aws_dynamodb_table" "list_members" {
  name         = "${var.name_prefix}-list-members"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "listId"
  range_key    = "userId"

  attribute {
    name = "listId"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
    projection_type = "ALL"
  }

  tags = var.tags
}

# -------------------------------
# tables: items
# -------------------------------
# 買い物/ToDoの項目を格納（期限GSIあり）。
resource "aws_dynamodb_table" "items" {
  name         = "${var.name_prefix}-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "listId"
  range_key    = "itemId"

  attribute {
    name = "listId"
    type = "S"
  }

  attribute {
    name = "itemId"
    type = "S"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
    projection_type = "ALL"
  }

  tags = var.tags
}

# -------------------------------
# tables: notifications
# -------------------------------
# 通知ログ（1日単位）を格納。
resource "aws_dynamodb_table" "notifications" {
  name         = "${var.name_prefix}-notifications"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "date"
  range_key    = "itemKey"

  attribute {
    name = "date"
    type = "S"
  }

  attribute {
    name = "itemKey"
    type = "S"
  }

  tags = var.tags
}
