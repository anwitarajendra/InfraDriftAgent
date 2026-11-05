# ==============================================================================
# InfraDriftAgent Makefile
# ==============================================================================

.DEFAULT_GOAL := doctor

.PHONY: help doctor

help:
	@echo "Available commands:"
	@echo "  make doctor   - Check required local CLI tools (Task 0.5)"

doctor:
	@if [ -f scripts/doctor.sh ] && command -v bash >/dev/null 2>&1; then \
		bash scripts/doctor.sh; \
	elif command -v python3 >/dev/null 2>&1; then \
		python3 scripts/doctor.py; \
	elif command -v python >/dev/null 2>&1; then \
		python scripts/doctor.py; \
	elif command -v py >/dev/null 2>&1; then \
		py scripts/doctor.py; \
	else \
		bash scripts/doctor.sh; \
	fi

