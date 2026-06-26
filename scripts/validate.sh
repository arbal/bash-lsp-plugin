#!/bin/bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
plugin_manifest="${repo_root}/.claude-plugin/plugin.json"
marketplace_manifest="${repo_root}/.claude-plugin/marketplace.json"

claude plugin validate "${plugin_manifest}" --strict
claude plugin validate "${marketplace_manifest}" --strict

valid_scripts=(
	"${repo_root}/test.sh"
	"${repo_root}/test-config.sh"
	"${repo_root}/test-advanced.sh"
	"${repo_root}/demo-live.sh"
	"${repo_root}/demo-issues.sh"
)

for script in "${valid_scripts[@]}"; do
	bash -n "${script}"
	shfmt -d "${script}"
done

if bash -n "${repo_root}/test-errors.sh"; then
	printf 'test-errors.sh was expected to fail bash -n\n' >&2
	exit 1
fi

shellcheck_output=$(
	shellcheck --rcfile "${repo_root}/.shellcheckrc" "${repo_root}/test-config.sh" 2>&1 || true
)

for code in SC2249 SC2230 SC2244 SC2250 SC2154; do
	if ! grep -q "${code}" <<<"${shellcheck_output}"; then
		printf 'Missing expected ShellCheck code: %s\n' "${code}" >&2
		printf '%s\n' "${shellcheck_output}" >&2
		exit 1
	fi
done

shellcheck "${repo_root}/scripts/validate.sh"

git -C "${repo_root}" diff --check
