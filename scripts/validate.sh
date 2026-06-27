#!/bin/bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
plugin_manifest="${repo_root}/.claude-plugin/plugin.json"
marketplace_manifest="${repo_root}/.claude-plugin/marketplace.json"
lsp_manifest="${repo_root}/.lsp.json"

claude plugin validate "${plugin_manifest}" --strict
claude plugin validate "${marketplace_manifest}" --strict

expected_extensions=$'.bash\n.sh'
actual_extensions=$(
	jq -r '.bash.extensionToLanguage | keys_unsorted[]' "${lsp_manifest}" | sort
)
if [[ "${actual_extensions}" != "${expected_extensions}" ]]; then
	printf 'Unexpected .lsp.json extension set:\nexpected:\n%s\nactual:\n%s\n' \
		"${expected_extensions}" "${actual_extensions}" >&2
	exit 1
fi

if jq -e '.bash | has("initializationOptions") or has("settings")' "${lsp_manifest}" >/dev/null; then
	printf '.lsp.json must not contain initializationOptions or settings\n' >&2
	exit 1
fi

expected_keys=$'args\ncommand\nenv\nextensionToLanguage'
actual_keys=$(
	jq -r '.bash | keys_unsorted[]' "${lsp_manifest}" | sort
)
if [[ "${actual_keys}" != "${expected_keys}" ]]; then
	printf 'Unexpected .lsp.json key set:\nexpected:\n%s\nactual:\n%s\n' \
		"${expected_keys}" "${actual_keys}" >&2
	exit 1
fi

expected_env_keys=$'GLOB_PATTERN\nSHELLCHECK_ARGUMENTS\nSHELLCHECK_PATH\nSHFMT_IGNORE_EDITORCONFIG\nSHFMT_LANGUAGE_DIALECT\nSHFMT_PATH'
actual_env_keys=$(
	jq -r '.bash.env | keys_unsorted[]' "${lsp_manifest}" | sort
)
if [[ "${actual_env_keys}" != "${expected_env_keys}" ]]; then
	printf 'Unexpected .lsp.json env key set:\nexpected:\n%s\nactual:\n%s\n' \
		"${expected_env_keys}" "${actual_env_keys}" >&2
	exit 1
fi

expected_env_values=$'GLOB_PATTERN=**/*@(.sh|.bash)\nSHELLCHECK_ARGUMENTS=--rcfile ${CLAUDE_PLUGIN_ROOT}/.shellcheckrc\nSHELLCHECK_PATH=shellcheck\nSHFMT_IGNORE_EDITORCONFIG=false\nSHFMT_LANGUAGE_DIALECT=auto\nSHFMT_PATH=shfmt'
actual_env_values=$(
	jq -r '.bash.env | to_entries | map("\(.key)=\(.value)") | sort[]' "${lsp_manifest}"
)
if [[ "${actual_env_values}" != "${expected_env_values}" ]]; then
	printf 'Unexpected .lsp.json env values:\nexpected:\n%s\nactual:\n%s\n' \
		"${expected_env_values}" "${actual_env_values}" >&2
	exit 1
fi

if jq -e '.bash | has("shellcheckExternalSources")' "${lsp_manifest}" >/dev/null; then
	printf '.lsp.json must not redundantly set shellcheckExternalSources\n' >&2
	exit 1
fi

if jq -e '.bash | has("startupTimeout") or has("maxRestarts") or has("shutdownOnExit") or has("shutdownTimeout")' "${lsp_manifest}" >/dev/null; then
	printf '.lsp.json must not contain obsolete restart/shutdown fields\n' >&2
	exit 1
fi

if rg -n -F '/root/' "${lsp_manifest}" >/dev/null || rg -n -F '/Users/' "${lsp_manifest}" >/dev/null; then
	printf '.lsp.json must not contain hard-coded host paths\n' >&2
	exit 1
fi

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
