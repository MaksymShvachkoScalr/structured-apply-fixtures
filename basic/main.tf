# Structured apply (`apply -json`) fixture.
#
# One apply produces the main kinds of structured apply output:
# - UI events: apply_start, apply_progress, apply_complete, provision_*, change_summary, outputs
# - an error diagnostic with a source location (local-exec exits with code 1)
# - a warning diagnostic (a check block whose assertion fails)
# - provisioner output with ANSI colours and several lines
#
# Run it on Terraform and on OpenTofu: their JSON events differ slightly.

# Quick resources, so the log has many ordinary create events.
resource "terraform_data" "quick" {
  count = var.resource_count

  input = "quick-${count.index}"
}

# Keeps creating long enough to produce "Still creating..." progress lines.
resource "terraform_data" "slow" {
  input = var.slow_seconds

  provisioner "local-exec" {
    command = "sleep ${var.slow_seconds}"
  }
}

# Provisioner output with ANSI colours and several lines.
resource "terraform_data" "colored_output" {
  input = "colors"

  provisioner "local-exec" {
    command = <<-EOT
      printf '\033[32mgreen line\033[0m\n'
      printf '\033[31mred line\033[0m\n'
      printf '\033[1;33mbold yellow line\033[0m\n'
      printf 'plain line 1\nplain line 2\n'
    EOT
  }
}

# Error diagnostic: the provisioner exits with code 1 during apply.
resource "terraform_data" "failing" {
  count = var.fail_apply ? 1 : 0

  input = "fail"

  provisioner "local-exec" {
    command = "echo 'about to fail' && exit 1"
  }
}

# Warning diagnostic: a failing check assertion is reported as a warning
# during plan and apply, and it never blocks the run.
check "always_warns" {
  assert {
    condition     = var.resource_count < 0
    error_message = "This check always fails on purpose, so the apply log has a warning diagnostic."
  }
}

output "quick_count" {
  value = length(terraform_data.quick)
}

output "multiline" {
  value = "first line\nsecond line"
}

output "secret" {
  value     = "not-a-real-secret"
  sensitive = true
}
