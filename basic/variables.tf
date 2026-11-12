variable "fail_apply" {
  description = "When true, one resource fails during apply, so the log carries an error diagnostic."
  type        = bool
  default     = true
}

variable "resource_count" {
  description = "Number of quick resources. Raise it (e.g. 2000) to test a large apply log."
  type        = number
  default     = 3
}

variable "slow_seconds" {
  description = "How long the slow resource takes, so the apply streams \"Still creating...\" lines."
  type        = number
  default     = 25
}
