# Releasing

Applies to: public GitHub release workflow for `bash-lsp-plugin`.

## Release Goals

- Keep the release candidate private until validation is complete.
- Preserve local-only state and existing worktree changes.
- Publish a marketplace-installable plugin on a release branch.
- Do not push, tag, or create a GitHub release until explicitly approved.

## Preflight

1. Verify the repo path is `/root/claude-plugin-bash-lsp`.
2. Confirm the release branch is `release/v1.1.0`.
3. Ensure the worktree is clean or every remaining path is explained.
4. Run `scripts/validate.sh`.
5. Re-check security and privacy findings.

## Versioning

- The plugin version lives in `.claude-plugin/plugin.json`.
- The marketplace entry should reference the plugin root and avoid duplicating the version source.
- Bump to `1.1.0` only after all validation passes.

## Local Validation

- `claude plugin validate ./.claude-plugin/plugin.json --strict`
- `claude plugin validate ./.claude-plugin/marketplace.json --strict`
- `scripts/validate.sh`
- `claude --plugin-dir /root/claude-plugin-bash-lsp plugins details bash-lsp-plugin`

## Local Deployment

1. Back up live Claude plugin metadata.
2. Install or refresh the plugin from the local marketplace source.
3. Verify the enabled plugin state.
4. Keep the old `bash-lsp-plugin@user` state available until the replacement is proven.
5. Record the rollback command before replacing anything.

## Push Approval Gate

The only approved push target for this release candidate is:

```bash
git -C /root/claude-plugin-bash-lsp push -u origin release/v1.1.0
```

Do not run that command until the user explicitly approves it.
