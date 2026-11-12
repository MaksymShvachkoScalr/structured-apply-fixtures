# all-cases

Every case a structured apply (`apply -json`) console has to render, in one configuration.
`main.tf` is grouped by case; each block says what it covers.

## Variables

| Variable | Default | Use |
| --- | --- | --- |
| `fail_apply` | `true` | Two resources fail, so the log has error diagnostics. Set to `false` for a successful apply; the warnings stay. |
| `quick_count` | `5` | Plain resources created. |
| `slow_seconds` | `35` | How long the slow resource keeps creating, so "Still creating..." lines stream in. |
| `burst_pause_seconds` | `12` | Pause between output bursts, so a console that polls the log gets them in separate reads. |
| `long_line_length` | `5000` | Length of the very long output line. |
| `secret` | `not-a-real-secret` | Sensitive. Used in a provisioner command and a sensitive output. |

## Cases

| Case | Where | What to check in the rendered output |
| --- | --- | --- |
| Create | `created` | "Creating..." and "Creation complete" lines. |
| Update in place | `updated_every_run` (from the 2nd run) | "Modifying..." and "Modifications complete". |
| Replace | `replaced_every_run` (from the 2nd run) | "Destroying...", "Destruction complete", then a create. |
| Destroy | `failing_*` after switching `fail_apply` from `true` to `false` | "Destroying..." lines for the removed resources. |
| Live tail | `slow`, `streamed_output` | "Still creating... [10s elapsed]" arrives during the apply; bursts land in separate reads of the log and nothing is lost or doubled at the boundaries. |
| ANSI colours | `ansi_output` | Colours, bright colours, bold, underline, backgrounds, 256-colour; a colour left open at the end of a line. |
| Text shapes | `text_output` | Ukrainian, Czech, emoji and CJK text; tabs; leading spaces; a `{` line then a `}` line stay two lines; a 5,000-character line; a Windows line end; HTML-like text stays text. |
| Sensitive output | `sensitive_output` | "(output suppressed due to sensitive value in config)" instead of the command output. |
| Error with output | `failing_provisioner` | The provisioner's output, then an error block with the source location and snippet. |
| Error with a multi-line snippet | `failing_postcondition` | Multi-line, non-ASCII snippet and message; the highlighted range points at the condition (offsets are UTF-8 bytes). |
| Warnings | `always_warns`, `warns_multiline` | Two warning blocks, one with a multi-line condition and non-ASCII text. |
| Outputs | `output` blocks (successful apply only) | String, multi-line, non-ASCII, number, bool, list, map, empty string, sensitive. |
| Hook output | runner hook | Not in the code: if your runner supports pre-apply or post-apply hooks, add one (e.g. `echo hook-output`) and check the lines show in their place. |

Compare the rendered diagnostics with what `terraform apply` (without `-json`) prints for the same
configuration.

## How to use

1. Apply this folder with `-json` (locally or from a CI/CD workspace whose working directory is this folder).
2. Run it on Terraform (>= 1.5) and on OpenTofu (>= 1.6).
3. Run 1 (`fail_apply = true`): errored apply with creates, live tail, all output shapes,
   two errors and two warnings. Outputs are not printed, because the apply fails.
4. Run 2 (`fail_apply = false`): successful apply with updates, a replace, destroys, two
   warnings and every output.
5. Later runs with `fail_apply = false` repeat the update and the replace. Provisioners run on
   create only, so to see their output again run a destroy first.
