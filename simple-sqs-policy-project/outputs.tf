output "fila_a_url" {
  value = module.fila_a.queue_url
}

output "fila_b_url" {
  value = module.fila_b.queue_url
}

output "fila_c_url" {
  value = module.fila_c.queue_url
}

output "kms_key_arn" {
  value = module.kms.key_arn
}

output "kms_key_policy_arn" {
  value = module.kms_key_policy.policy_arn
}

output "sqs_queue_policy_arn" {
  value = module.sqs_queue_policy.policy_arn
}
