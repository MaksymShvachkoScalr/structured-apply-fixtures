variable "resource_count" {
  description = "Number of plain terraform_data resources. With the default chatty_count, the apply creates 10,032 resources (a JSON apply log of about 13.4 MB)."
  type        = number
  default     = 10012
}

variable "chatty_count" {
  description = "Number of resources that print provisioner output."
  type        = number
  default     = 20
}
