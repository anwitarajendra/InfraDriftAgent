#!/usr/bin/env python3
"""
InfraDriftAgent Doctor Script (Python cross-platform runner)
Checks that all required local CLI tools are installed and operational.
"""

import os
import re
import shutil
import subprocess
import sys

# ANSI Colors
COLOR_RESET = "\033[0m"
COLOR_GREEN = "\033[1;32m"
COLOR_RED = "\033[1;31m"
COLOR_YELLOW = "\033[1;33m"
COLOR_CYAN = "\033[1;36m"
COLOR_BOLD = "\033[1m"

# Reconfigure stdout for UTF-8 on Windows if needed
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

def print_header():
    print(f"{COLOR_CYAN}{COLOR_BOLD}===================================================={COLOR_RESET}")
    print(f"{COLOR_CYAN}{COLOR_BOLD}   InfraDriftAgent Environment Doctor (Task 0.5)    {COLOR_RESET}")
    print(f"{COLOR_CYAN}{COLOR_BOLD}===================================================={COLOR_RESET}\n")

def run_cmd(cmd):
    try:
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=10)
        return res.stdout.strip()
    except Exception:
        return None

def check_python312():
    # 1. python3.12 binary
    if shutil.which("python3.12"):
        out = run_cmd(["python3.12", "--version"])
        if out:
            return True, "python3.12", out.splitlines()[0]

    # 2. Windows py launcher with -3.12
    if shutil.which("py"):
        out = run_cmd(["py", "-3.12", "--version"])
        if out and "Python 3.12" in out:
            return True, "python3.12", f"{out.splitlines()[0]} (via py -3.12)"

    # 3. Check default python3 / python
    for py_bin in ["python3", "python"]:
        if shutil.which(py_bin):
            out = run_cmd([py_bin, "-c", "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')"])
            if out and out.startswith("3.12"):
                return True, "python3.12", f"Python {out} (via {py_bin})"

    # Detected other python?
    detected = None
    for py_bin in ["python3", "python", "py"]:
        if shutil.which(py_bin):
            out = run_cmd([py_bin, "--version"])
            if out:
                detected = out.splitlines()[0]
                break

    if detected:
        return False, "python3.12", f"Found {detected}, but Python 3.12 is required."
    return False, "python3.12", "Python 3.12 not found. Install via pyenv, winget, or python.org."

def check_docker():
    if shutil.which("docker"):
        out = run_cmd(["docker", "--version"])
        if out:
            # First line
            first = [l for l in out.splitlines() if "Docker version" in l or "version" in l.lower()]
            ver = first[0] if first else out.splitlines()[0]
            return True, "docker", ver
    return False, "docker", "Docker is not installed or not in PATH."

def check_kind():
    if shutil.which("kind"):
        out = run_cmd(["kind", "--version"])
        if out:
            return True, "kind", out.splitlines()[0]
    return False, "kind", "kind is not installed. Install via: winget install Kubernetes.kind / brew install kind"

def check_kubectl():
    if shutil.which("kubectl"):
        out = run_cmd(["kubectl", "version", "--client"])
        if out:
            for line in out.splitlines():
                if "client version" in line.lower():
                    # Extract version token like v1.34.1
                    match = re.search(r"v\d+\.\d+\.\d+", line)
                    if match:
                        return True, "kubectl", f"Client Version: {match.group(0)}"
                    return True, "kubectl", line.strip()
            return True, "kubectl", out.splitlines()[-1].strip()
    return False, "kubectl", "kubectl is not installed. Install via Docker Desktop, winget, or brew."

def check_helm():
    if shutil.which("helm"):
        out = run_cmd(["helm", "version", "--short"])
        if out:
            return True, "helm", out.splitlines()[0]
    return False, "helm", "helm is not installed. Install via: winget install Helm.Helm / brew install helm"

def check_opentofu():
    for bin_name in ["opentofu", "tofu"]:
        if shutil.which(bin_name):
            out = run_cmd([bin_name, "--version"])
            if out:
                return True, "opentofu", out.splitlines()[0]
    return False, "opentofu", "opentofu is not installed. Install via: winget install OpenTofu.Tofu / brew install opentofu"

def check_conftest():
    if shutil.which("conftest"):
        out = run_cmd(["conftest", "--version"])
        if out:
            return True, "conftest", out.splitlines()[0]
    return False, "conftest", "conftest is not installed. Install via: brew install conftest / https://github.com/open-policy-agent/conftest/releases"

def check_kubeconform():
    if shutil.which("kubeconform"):
        out = run_cmd(["kubeconform", "-v"])
        if out:
            return True, "kubeconform", out.splitlines()[0]
    return False, "kubeconform", "kubeconform is not installed. Install via: winget install YannHamon.kubeconform / brew install kubeconform"

def check_actionlint():
    if shutil.which("actionlint"):
        out = run_cmd(["actionlint", "--version"])
        if out:
            return True, "actionlint", out.splitlines()[0]
    return False, "actionlint", "actionlint is not installed. Install via: winget install rhysd.actionlint / brew install actionlint"

def check_yamllint():
    if shutil.which("yamllint"):
        out = run_cmd(["yamllint", "--version"])
        if out:
            return True, "yamllint", out.splitlines()[0]
    # Check via python module
    for py_bin in ["py", "python3", "python"]:
        if shutil.which(py_bin):
            out = run_cmd([py_bin, "-m", "yamllint", "--version"])
            if out and "yamllint" in out.lower():
                return True, "yamllint", f"{out.splitlines()[0]} (via {py_bin} -m yamllint)"
    return False, "yamllint", "yamllint is not installed. Install via: pip install yamllint / brew install yamllint"

def check_gh():
    if shutil.which("gh"):
        out = run_cmd(["gh", "--version"])
        if out:
            return True, "gh", out.splitlines()[0]
    return False, "gh", "gh is not installed. Install via: winget install GitHub.cli / brew install gh"

def check_cosign():
    if shutil.which("cosign"):
        out = run_cmd(["cosign", "version"])
        if out:
            for line in out.splitlines():
                if "gitversion" in line.lower():
                    return True, "cosign", line.strip()
            return True, "cosign", out.splitlines()[0]
    return False, "cosign", "cosign is not installed. Install via: winget install Sigstore.Cosign / brew install cosign"

CHECKS = [
    ("python3.12", check_python312),
    ("docker", check_docker),
    ("kind", check_kind),
    ("kubectl", check_kubectl),
    ("helm", check_helm),
    ("opentofu", check_opentofu),
    ("conftest", check_conftest),
    ("kubeconform", check_kubeconform),
    ("actionlint", check_actionlint),
    ("yamllint", check_yamllint),
    ("gh", check_gh),
    ("cosign", check_cosign),
]

def main():
    print_header()
    passed = 0
    missing = 0

    for name, checker in CHECKS:
        ok, tool, detail = checker()
        if ok:
            passed += 1
            print(f"  {COLOR_GREEN}[OK]     {tool:<14}{COLOR_RESET} {detail}")
        else:
            missing += 1
            print(f"  {COLOR_RED}[MISSING] {tool:<14}{COLOR_RESET} {detail}")

    total = passed + missing
    print(f"\n{COLOR_CYAN}----------------------------------------------------{COLOR_RESET}")
    print(f"Summary: {COLOR_GREEN}{passed} passed{COLOR_RESET}, {COLOR_RED}{missing} missing{COLOR_RESET} (Total: {total})")
    print(f"{COLOR_CYAN}----------------------------------------------------{COLOR_RESET}")

    if missing == 0:
        print(f"{COLOR_GREEN}{COLOR_BOLD}[+] All required CLI tools are installed!{COLOR_RESET}")
        sys.exit(0)
    else:
        print(f"{COLOR_YELLOW}{COLOR_BOLD}[!] Some required tools are missing. Please install them using the hints above.{COLOR_RESET}")
        sys.exit(1)

if __name__ == "__main__":
    main()
