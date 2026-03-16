# Production Migration Notes

This file exists to stop the local build from being mistaken for a production design.

## Local-to-production gaps
- identity and access control
- TLS and reverse proxy
- secret management
- backup and recovery
- observability and alerting
- connector governance
- patching and update process
- internet exposure controls
- multi-user and administrative boundaries

## Rule
Do not claim production readiness until each gap has been addressed explicitly and documented separately.
