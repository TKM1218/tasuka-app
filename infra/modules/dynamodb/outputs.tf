# --------------------------------------------------
# outputs: lists
# --------------------------------------------------
output "lists_table_name" {
  description = "listsテーブル名"
  value       = aws_dynamodb_table.lists.name
}

output "lists_table_arn" {
  description = "listsテーブルARN"
  value       = aws_dynamodb_table.lists.arn
}

# --------------------------------------------------
# outputs: list_members
# --------------------------------------------------
output "list_members_table_name" {
  description = "list_membersテーブル名"
  value       = aws_dynamodb_table.list_members.name
}

output "list_members_table_arn" {
  description = "list_membersテーブルARN"
  value       = aws_dynamodb_table.list_members.arn
}

# --------------------------------------------------
# outputs: items
# --------------------------------------------------
output "items_table_name" {
  description = "itemsテーブル名"
  value       = aws_dynamodb_table.items.name
}

output "items_table_arn" {
  description = "itemsテーブルARN"
  value       = aws_dynamodb_table.items.arn
}

# --------------------------------------------------
# outputs: notifications
# --------------------------------------------------
output "notifications_table_name" {
  description = "notificationsテーブル名"
  value       = aws_dynamodb_table.notifications.name
}

output "notifications_table_arn" {
  description = "notificationsテーブルARN"
  value       = aws_dynamodb_table.notifications.arn
}
