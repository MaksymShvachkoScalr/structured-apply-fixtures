# Every case a structured apply (`apply -json`) console has to render,
# in one configuration. Each block below says which case it covers; README.md
# lists the checks to make for each one.
#
# Only the built-in terraform_data resource is used, so no provider is
# downloaded and runs start fast. Run it on Terraform (>= 1.5) and on
# OpenTofu (>= 1.6): their JSON events differ slightly.

# ---------------------------------------------------------------------------
# Resource operations
# ---------------------------------------------------------------------------

# Create: ordinary apply_start / apply_complete lines.
resource "terraform_data" "created" {
  count = var.quick_count

  input = "created-${count.index}"
}

# Update in place on every run after the first one: the input changes each time.
resource "terraform_data" "updated_every_run" {
  input = timestamp()
}

# Replace on every run after the first one: "Destroying..." and
# "Destruction complete" lines, then a create.
resource "terraform_data" "replaced_every_run" {
  input            = "replaced"
  triggers_replace = timestamp()
}

# ---------------------------------------------------------------------------
# Live tail
# ---------------------------------------------------------------------------

# Keeps creating long enough to see "Still creating... [10s elapsed]" lines
# arrive during the apply.
resource "terraform_data" "slow" {
  input = var.slow_seconds

  provisioner "local-exec" {
    command = "sleep ${var.slow_seconds}"
  }
}

# Prints output in bursts with long pauses, so a console that polls the log
# gets the lines in separate reads. Terraform drops blank provisioner lines,
# so any blank lines a console shows (before diagnostics, the summary and
# outputs) come from its own spacing; this resource pushes them past several
# read boundaries.
resource "terraform_data" "streamed_output" {
  input = "streamed"

  provisioner "local-exec" {
    command = <<-EOT
      echo 'burst 1: first line'
      echo 'burst 1: second line'
      sleep ${var.burst_pause_seconds}
      echo 'burst 2: first line'
      echo 'burst 2: second line'
      sleep ${var.burst_pause_seconds}
      echo 'burst 3: last line'
    EOT
  }

  depends_on = [terraform_data.slow]
}

# ---------------------------------------------------------------------------
# Provisioner output content
# ---------------------------------------------------------------------------

# ANSI colours and styles: foreground, bright, bold, underline, background,
# 256-colour, and a colour left open at the end of the line.
resource "terraform_data" "ansi_output" {
  input = "ansi"

  provisioner "local-exec" {
    command = <<-EOT
      printf '\033[32mgreen\033[0m \033[31mred\033[0m \033[33myellow\033[0m \033[34mblue\033[0m \033[35mmagenta\033[0m \033[36mcyan\033[0m\n'
      printf '\033[92mbright green\033[0m \033[91mbright red\033[0m\n'
      printf '\033[1mbold\033[0m \033[4munderline\033[0m \033[1;33mbold yellow\033[0m\n'
      printf '\033[41;97m white on red \033[0m \033[42;30m black on green \033[0m\n'
      printf '\033[38;5;208m256-colour orange\033[0m\n'
      printf '\033[35mcolour left open at the end of the line\n'
      printf 'plain line after an open colour\033[0m\n'
    EOT
  }
}

# Text shapes: non-ASCII, emoji, tabs, leading spaces, lines that are only
# "{" and "}", a very long line, a Windows line end and HTML-like text.
# Terraform drops blank and whitespace-only lines, so there are none here.
resource "terraform_data" "text_output" {
  input = "text"

  provisioner "local-exec" {
    command = <<-EOT
      echo 'Українська: привіт, світе! Čeština: příliš žluťoučký kůň'
      echo 'Emoji: ✅ ⚠️ 🚀  CJK: 你好世界'
      printf 'tab\tseparated\tcolumns\n'
      echo '    four leading spaces'
      echo '{'
      echo '}'
      echo '{"json": "on one line", "n": 1}'
      printf 'long line: %s\n' "$(printf 'x%.0s' $(seq 1 ${var.long_line_length}))"
      printf 'windows line end\r\n'
      echo '<b>html-like text must stay text</b> & &amp; <script>'
    EOT
  }
}

# Sensitive value in the command: Terraform hides the provisioner output and
# prints "(output suppressed due to sensitive value in config)".
resource "terraform_data" "sensitive_output" {
  input = "sensitive"

  provisioner "local-exec" {
    command = "echo 'secret is ${var.secret}'"
  }
}

# ---------------------------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------------------------

# Error: the provisioner exits with code 1. The diagnostic has a source
# location and a snippet; the output before the failure is printed first.
resource "terraform_data" "failing_provisioner" {
  count = var.fail_apply ? 1 : 0

  input = "fail"

  provisioner "local-exec" {
    command = "echo 'about to fail: помилка' && exit 1"
  }
}

# Error: a postcondition fails after the resource is created. The snippet
# spans several lines and holds non-ASCII text; the highlight offsets in the
# JSON are UTF-8 bytes, not characters.
resource "terraform_data" "failing_postcondition" {
  count = var.fail_apply ? 1 : 0

  input = "привіт ✓"

  lifecycle {
    postcondition {
      condition = (
        self.output == "привіт ✓"
        && length(self.output) > 100
      )
      error_message = <<-EOT
        Postcondition failed on purpose.
        The message has two lines and non-ASCII text: ще один рядок.
      EOT
    }
  }
}

# Warning: a failing check assertion is a warning, it never blocks the run.
check "always_warns" {
  assert {
    condition     = var.quick_count < 0
    error_message = "This check always fails on purpose, so the apply log has a warning diagnostic."
  }
}

# Warning: a second check, with a multi-line condition and non-ASCII text.
check "warns_multiline" {
  assert {
    condition = (
      var.quick_count < 0
      || var.secret == "ніколи"
    )
    error_message = "Друге попередження: this check also always fails on purpose."
  }
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "string" {
  value = "plain string"
}

output "multiline" {
  value = "first line\nsecond line"
}

output "non_ascii" {
  value = "привіт ✓ 🚀"
}

output "number" {
  value = length(terraform_data.created)
}

output "bool" {
  value = var.fail_apply
}

output "list" {
  value = terraform_data.created[*].output
}

output "map" {
  value = {
    created  = length(terraform_data.created)
    replaced = terraform_data.replaced_every_run.id
  }
}

output "empty_string" {
  value = ""
}

output "secret" {
  value     = var.secret
  sensitive = true
}
