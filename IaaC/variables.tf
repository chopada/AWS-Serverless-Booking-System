variable "region" {
  type = string
}
variable "profile_name" {
  type = string
}
variable "api_gateway" {
  type = string
}
variable "api_gateway_book_path" {
  type = string
}
variable "api_gateway_cancel_path" {
  type = string
}
variable "book_ack_req" {
  type = string
}
variable "cancel_ack_req" {
  type = string
}
variable "runtime" {
  type = string
}
variable "book_sqs_queue" {
  type = string
}
variable "max_message_size" {
  type = number
}
variable "receive_wait_time_seconds" {
  type = number
}
variable "message_retention_seconds" {
  type = number
}
variable "cancel_sqs_queue" {
  type = string
}
variable "book_payment_function" {
  type = string
}
