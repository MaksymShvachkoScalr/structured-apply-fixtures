# structured-apply-fixtures

Terraform and OpenTofu configurations that produce structured apply logs (`terraform apply -json`,
`tofu apply -json`). Use them to test anything that reads or renders those logs, such as a run
console that shows the apply output.

| Folder | Use |
| --- | --- |
| [`basic`](basic) | A small apply with UI events, an error and a warning diagnostic, ANSI provisioner output and outputs. Quick to run. |
| [`all-cases`](all-cases) | Every case a structured apply console has to render, in one configuration: create, update, replace and destroy, live progress, ANSI and non-ASCII output, sensitive output, error and warning diagnostics with multi-line snippets, every kind of output value. |
| [`large-log`](large-log) | **Log file only; do not apply this configuration on shared infrastructure.** A captured JSON apply log of 10,032 resources (about 13.4 MB, gzipped), for performance tests on a big log. |

All folders use only the built-in `terraform_data` resource, so no provider is downloaded and no
cloud account is needed. They need Terraform >= 1.5 or OpenTofu >= 1.6 (`check` blocks). Run
`basic` and `all-cases` on both tools, because their JSON events differ slightly.

Each folder keeps its own state, so apply each one from its own working directory. `basic` and
`all-cases` apply in about a minute or less.

## Run one locally

```bash
cd all-cases
terraform init
terraform apply -json -auto-approve > apply.jsonl
```

The state, plan and log files are git-ignored.
