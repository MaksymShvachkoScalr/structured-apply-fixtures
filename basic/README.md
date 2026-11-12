# basic

A small fixture whose `apply -json` log has the main kinds of structured apply output.

One apply produces:

- normal UI events: create, progress ("Still creating..."), complete, provisioner output, summary, outputs;
- an **error** diagnostic with a source location (`terraform_data.failing`, local-exec exits with 1);
- a **warning** diagnostic (the `always_warns` check block);
- provisioner output with ANSI colours and several lines;
- outputs, including a sensitive one and a multi-line one.

## Variables

| Variable | Default | Use |
| --- | --- | --- |
| `fail_apply` | `true` | Set to `false` for a successful apply (the warning stays). |
| `resource_count` | `3` | Raise it (e.g. `2000`) to test a large apply log. |
| `slow_seconds` | `25` | How long one resource keeps creating, so "Still creating..." lines appear. |

## How to use

1. Apply this folder with `-json` (locally or from a CI/CD workspace whose working directory is this folder).
2. Run it once on Terraform (>= 1.5) and once on OpenTofu (>= 1.6).
3. If your runner supports pre-apply or post-apply hooks, add one (e.g. `echo hook-output`) to get plain text lines mixed with the JSON events.
4. Every apply creates the resources again, because `local-exec` provisioners run on create only:
   use a destroy run, or change `resource_count`, between attempts.
