# OpenClaw Architecture and Trust-Boundary Notes

Use this file after the runtime is stable enough to observe real component behavior.

## Components
- Windows workstation
- Ubuntu WSL operator workspace
- dedicated Ubuntu target VM
- Docker runtime inside the VM
- OpenClaw application
- model provider endpoints
- persistent storage
- optional connectors

## Trust boundaries
- workstation to WSL operator environment
- workstation to target VM
- VM to container runtime
- application to external provider
- user prompts to model-processing pipeline
- application state to persistent storage

## Questions to answer
- Where do secrets exist and where do they live?
- What data leaves the local environment?
- What actions can the assistant trigger?
- What persistence remains after restart?
- What controls would be required before public exposure?
- Which privacy assumptions turned out weaker than expected during real deployment?
