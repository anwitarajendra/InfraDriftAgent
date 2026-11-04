#!/usr/bin/env bash
# ==============================================================================
# InfraDriftAgent Doctor Script
# Checks that all required local CLI tools are installed and operational.
# ==============================================================================

set -uo pipefail

# ANSI color codes
COLOR_RESET="\033[0m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_YELLOW="\033[1;33m"
COLOR_CYAN="\033[1;36m"
COLOR_BOLD="\033[1m"

# Counters
TOTAL_CHECKED=0
TOTAL_PASSED=0
TOTAL_MISSING=0

echo -e "${COLOR_CYAN}${COLOR_BOLD}====================================================${COLOR_RESET}"
echo -e "${COLOR_CYAN}${COLOR_BOLD}   InfraDriftAgent Environment Doctor (Task 0.5)    ${COLOR_RESET}"
echo -e "${COLOR_CYAN}${COLOR_BOLD}====================================================${COLOR_RESET}"
echo ""

# Helper function to print success
report_ok() {
    local tool="$1"
    local version="$2"
    TOTAL_CHECKED=$((TOTAL_CHECKED + 1))
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
    printf "  ${COLOR_GREEN}[OK]     %-14s${COLOR_RESET} %s\n" "$tool" "$version"
}

# Helper function to print failure / missing
report_missing() {
    local tool="$1"
    local hint="$2"
    TOTAL_CHECKED=$((TOTAL_CHECKED + 1))
    TOTAL_MISSING=$((TOTAL_MISSING + 1))
    printf "  ${COLOR_RED}[MISSING] %-14s${COLOR_RESET} %s\n" "$tool" "$hint"
}

# 1. python3.12
check_python312() {
    local tool="python3.12"
    local ver=""
    if command -v python3.12 >/dev/null 2>&1; then
        ver=$(python3.12 --version 2>&1 | head -n1)
        report_ok "$tool" "$ver"
    elif command -v py >/dev/null 2>&1 && py -3.12 --version >/dev/null 2>&1; then
        ver=$(py -3.12 --version 2>&1 | head -n1)
        report_ok "$tool" "$ver (via py -3.12)"
    elif command -v python3 >/dev/null 2>&1 && [[ "$(python3 -V 2>&1)" =~ 3\.12 ]]; then
        ver=$(python3 --version 2>&1 | head -n1)
        report_ok "$tool" "$ver (via python3)"
    elif command -v python >/dev/null 2>&1 && [[ "$(python -V 2>&1)" =~ 3\.12 ]]; then
        ver=$(python --version 2>&1 | head -n1)
        report_ok "$tool" "$ver (via python)"
    else
        local found=""
        if command -v python3 >/dev/null 2>&1; then
            found=$(python3 --version 2>&1 | head -n1)
        elif command -v python >/dev/null 2>&1; then
            found=$(python --version 2>&1 | head -n1)
        fi
        if [ -n "$found" ]; then
            report_missing "$tool" "Python 3.12 not found (detected: $found). Install Python 3.12."
        else
            report_missing "$tool" "Python 3.12 is not installed. Install via pyenv, winget, or python.org."
        fi
    fi
}

# 2. docker
check_docker() {
    local tool="docker"
    if command -v docker >/dev/null 2>&1; then
        local ver
        ver=$(docker --version 2>&1 | head -n1)
        report_ok "$tool" "$ver"
    else
        report_missing "$tool" "Docker is not installed or not in PATH."
    fi
}

# 3. kind
check_kind() {
    local tool="kind"
    if command -v kind >/dev/null 2>&1; then
        local ver
        ver=$(kind --version 2>&1 | head -n1)
        report_ok "$tool" "$ver"
    else
        report_missing "$tool" "kind is not installed. Install via: winget install Kubernetes.kind / brew install kind"
    fi
}

# 4. kubectl
check_kubectl() {
    local tool="kubectl"
    if command -v kubectl >/dev/null 2>&1; then
        local ver
        ver=$(kubectl version --client 2>&1 | grep -i "Client Version" | head -n1 | grep -oE "v[0-9]+\.[0-9]+\.[0-9]+" | head -n1)
        if [ -n "$ver" ]; then
            ver="Client Version: $ver"
        else
            ver="Client Version: installed"
        fi
        report_ok "$tool" "$ver"
    else
        report_missing "$tool" "kubectl is not installed. Install via Docker Desktop, winget, or brew."
    fi
}

# 5. helm
check_helm() {
    local tool="helm"
    if command -v helm >/dev/null 2>&1; then
        local ver
        ver=$(helm version --short 2>&1 | head -n1)
        report_ok "$tool" "$ver"
    else
        report_missing "$tool" "helm is not installed. Install via: winget install Helm.Helm / brew install helm"
    fi
}

# 6. opentofu
check_opentofu() {
    local tool="opentofu"
    if command -v opentofu >/dev/null 2>&1; then
        local ver
        ver=$(opentofu --version 2>&1 | head -n1)
        report_ok "$tool" "$ver"
    elif command -v tofu >/dev/null 2>&1; then
        local ver
        ver=$(tofu --version 2>&1 | head -n1)
        report_ok "$tool" "$ver (via tofu)"
    else
        report_missing "$tool" "opentofu is not installed. Install via: winget install OpenTofu.Tofu / brew install opentofu"
    fi
}

# 7. conftest
check_conftest() {
    local tool="conftest"
    if command -v conftest >/dev/null 2>&1; then
        local ver
        ver=$(conftest --version 2>&1 | head -n1)
        report_ok "$tool" "$ver"
    else
        report_missing "$tool" "conftest is not installed. Install via: brew install conftest / https://github.com/open-policy-agent/conftest/releases"
    fi
}

# 8. kubeconform
check_kubeconform() {
    local tool="kubeconform"
    if command -v kubeconform >/dev/null 2>&1; then
        local ver
        ver=$(kubeconform -v 2>&1 | head -n1)
        report_ok "$tool" "$ver"
    else
        report_missing "$tool" "kubeconform is not installed. Install via: winget install YannHamon.kubeconform / brew install kubeconform"
    fi
}

# 9. actionlint
check_actionlint() {
    local tool="actionlint"
    if command -v actionlint >/dev/null 2>&1; then
        local ver
        ver=$(actionlint --version 2>&1 | head -n1)
        report_ok "$tool" "$ver"
    else
        report_missing "$tool" "actionlint is not installed. Install via: winget install rhysd.actionlint / brew install actionlint"
    fi
}

# 10. yamllint
check_yamllint() {
    local tool="yamllint"
    if command -v yamllint >/dev/null 2>&1; then
        local ver
        ver=$(yamllint --version 2>&1 | head -n1)
        report_ok "$tool" "$ver"
    elif command -v py >/dev/null 2>&1 && py -m yamllint --version >/dev/null 2>&1; then
        local ver
        ver=$(py -m yamllint --version 2>&1 | head -n1)
        report_ok "$tool" "$ver (via py -m yamllint)"
    elif command -v python3 >/dev/null 2>&1 && python3 -m yamllint --version >/dev/null 2>&1; then
        local ver
        ver=$(python3 -m yamllint --version 2>&1 | head -n1)
        report_ok "$tool" "$ver (via python3 -m yamllint)"
    elif command -v python >/dev/null 2>&1 && python -m yamllint --version >/dev/null 2>&1; then
        local ver
        ver=$(python -m yamllint --version 2>&1 | head -n1)
        report_ok "$tool" "$ver (via python -m yamllint)"
    else
        report_missing "$tool" "yamllint is not installed. Install via: pip install yamllint / brew install yamllint"
    fi
}

# 11. gh
check_gh() {
    local tool="gh"
    if command -v gh >/dev/null 2>&1; then
        local ver
        ver=$(gh --version 2>&1 | head -n1)
        report_ok "$tool" "$ver"
    else
        report_missing "$tool" "gh is not installed. Install via: winget install GitHub.cli / brew install gh"
    fi
}

# 12. cosign
check_cosign() {
    local tool="cosign"
    if command -v cosign >/dev/null 2>&1; then
        local ver
        ver=$(cosign version 2>&1 | grep -i "GitVersion:" | head -n1 | awk '{print $2}')
        if [ -z "$ver" ]; then
            ver=$(cosign version 2>&1 | head -n1)
        fi
        report_ok "$tool" "$ver"
    else
        report_missing "$tool" "cosign is not installed. Install via: winget install Sigstore.Cosign / brew install cosign"
    fi
}

# Run all checks
check_python312
check_docker
check_kind
check_kubectl
check_helm
check_opentofu
check_conftest
check_kubeconform
check_actionlint
check_yamllint
check_gh
check_cosign

echo ""
echo -e "${COLOR_CYAN}----------------------------------------------------${COLOR_RESET}"
echo -e "Summary: ${COLOR_GREEN}${TOTAL_PASSED} passed${COLOR_RESET}, ${COLOR_RED}${TOTAL_MISSING} missing${COLOR_RESET} (Total: ${TOTAL_CHECKED})"
echo -e "${COLOR_CYAN}----------------------------------------------------${COLOR_RESET}"

if [ "$TOTAL_MISSING" -eq 0 ]; then
    echo -e "${COLOR_GREEN}${COLOR_BOLD}[+] All required CLI tools are installed!${COLOR_RESET}"
    exit 0
else
    echo -e "${COLOR_YELLOW}${COLOR_BOLD}[!] Some required tools are missing. Please install them using the hints above.${COLOR_RESET}"
    exit 1
fi
