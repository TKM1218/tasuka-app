# --------------------------------------------------
# outputs: scheduler
# --------------------------------------------------
output "schedule_name" {
  description = "Schedulerの名前"
  value       = aws_scheduler_schedule.main.name
}

output "schedule_arn" {
  description = "SchedulerのARN"
  value       = aws_scheduler_schedule.main.arn
}

output "scheduler_role_arn" {
  description = "Scheduler実行ロールのARN"
  value       = aws_iam_role.scheduler.arn
}
