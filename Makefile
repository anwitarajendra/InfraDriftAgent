# ==============================================================================
# InfraDriftAgent Makefile
# ==============================================================================

.DEFAULT_GOAL := doctor

.PHONY: help doctor

help:
	@echo Available commands:
	@echo   make doctor   - Check required local CLI tools (Task 0.5)

doctor:
	@python scripts/doctor.py
