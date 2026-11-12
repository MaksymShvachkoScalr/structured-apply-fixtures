# large-log

A large structured apply log, for performance tests of anything that reads or renders
`apply -json` output.

> **Do not apply this configuration on shared infrastructure.** The apply creates 10,032 resources and
> keeps a runner busy for many minutes (about 5 on an 18-core laptop, ~425 MB peak memory for
> the plan, a 5.3 MB state). Use the log file below instead. The `.tf` files are kept only to
> regenerate it locally.

## The log

[`apply-terraform-1.13.3.jsonl.gz`](apply-terraform-1.13.3.jsonl.gz): the raw output of
`terraform apply -json` for this configuration, one JSON event per line, gzipped
(847 KB packed, 13,521,125 bytes / about 13.4 MB unpacked).

- 10,032 resources: `planned_change`, `apply_start` and `apply_complete` for each, then
  `change_summary` and `outputs`. Each resource adds about 1.34 KB of events.
- 20 of them (`terraform_data.chatty[*]`) print a few provisioner lines, one in colour, so the
  log is not only create events.
- No diagnostics. For errors and warnings, use [`../all-cases`](../all-cases).
- Captured with Terraform 1.13.3; timestamps are local time (`+01:00`).

Unpack it:

```bash
gunzip -k apply-terraform-1.13.3.jsonl.gz
```

## What to check with it

Feed the log to your reader or renderer (for example by serving it as a run's apply log), then
check that:

- it opens the log without freezing, and scrolling stays smooth;
- search finds a line near the end (e.g. `item[10011]`);
- exporting the rendered text is quick;
- re-rendering the log (e.g. after switching views) is quick.

## Regenerate it (locally only)

```bash
terraform init
terraform plan -out=tfplan
terraform apply -json tfplan > apply.jsonl
gzip -9 -c apply.jsonl > apply-terraform-<version>.jsonl.gz
```

Then remove the local state, plan and `.terraform` folder; they are git-ignored. Lower
`resource_count` (plain resources, default 10012) for a smaller log; `chatty_count`
(default 20) sets the resources that print provisioner output.
