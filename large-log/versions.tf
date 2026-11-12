terraform {
  # `check` blocks need Terraform 1.5+ / OpenTofu 1.6+. No providers: only the
  # built-in terraform_data resource is used, so runs start fast.
  required_version = ">= 1.5.0"
}
