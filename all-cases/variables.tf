variable "fail_apply" {
  description = "When true, two resources fail during apply, so the log carries error diagnostics. Set to false for a successful apply (the warnings stay)."
  type        = bool
  default     = true
}

variable "quick_count" {
  description = "Number of plain resources created."
  type        = number
  default     = 5
}

variable "slow_seconds" {
  description = "How long the slow resource takes, so the apply streams \"Still creating...\" lines."
  type        = number
  default     = 35
}

variable "burst_pause_seconds" {
  description = "Pause between output bursts, so a console that polls the log reads each burst separately."
  type        = number
  default     = 12
}

variable "long_line_length" {
  description = "Length of the very long provisioner output line."
  type        = number
  default     = 5000
}

variable "secret" {
  description = "Used in a provisioner command and a sensitive output. Not a real secret."
  type        = string
  default     = "not-a-real-secret"
  sensitive   = true
}
