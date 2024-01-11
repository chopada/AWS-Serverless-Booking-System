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
variable "cancel_payment_function" {
  type = string
}
variable "book_sns" {
  type = string
}
variable "cancel_sns" {
  type = string
}
variable "cancel_sqs_success" {
  type = string
}
variable "book_sqs_success" {
  type = string
}
variable "book_db_entry_function" {
  type = string
}
variable "cancel_db_entry_function" {
  type = string
}
variable "admin_table" {
  type = string
}
variable "billing_mode" {
  type = string
}
variable "admin_attribute1" {
  type = string
}
variable "admin_attribute2" {
  type = string
}

variable "attribute_type_string" {
  type = string
}
variable "rcus" {
  type = number
}
variable "wcus" {
  type = number
}
variable "streams" {
  type = bool
}
variable "stream_view" {
  type = string
}
variable "notification_function" {
  type = string
}
