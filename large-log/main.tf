# Large structured apply (`apply -json`) log.
#
# Do not apply this on shared infrastructure: run it locally only, to
# regenerate apply-terraform-*.jsonl.gz (see README.md).
#
# With the defaults, one apply creates 10,032 resources (10,012 plain + 20
# chatty) and writes a JSON apply log of about 13.4 MB. Use it to check that
# a renderer opens it without freezing, that search stays usable, and how
# long exporting the text takes.
#
# Only the built-in terraform_data resource is used, so no provider is
# downloaded and the apply is quick for its size.

resource "terraform_data" "item" {
  count = var.resource_count

  # Each resource writes about 1.34 KB of JSON events (planned_change,
  # apply_start, apply_complete), so the log size follows the count.
  input = format("large-log-item-%05d", count.index)
}

# A few resources that print several provisioner lines each, so the large log
# is not only create events.
resource "terraform_data" "chatty" {
  count = var.chatty_count

  input = "chatty-${count.index}"

  provisioner "local-exec" {
    command = <<-EOT
      echo "chatty ${count.index}: line 1"
      printf '\033[36mchatty ${count.index}: cyan line 2\033[0m\n'
      echo "chatty ${count.index}: line 3"
    EOT
  }
}

output "item_count" {
  value = length(terraform_data.item)
}

output "last_item" {
  value = try(terraform_data.item[var.resource_count - 1].output, null)
}
