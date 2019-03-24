## Drone CI
The CI has:
- quick scaling -> containers
- dedicated agents:
    - one agent for infrastructure (build docker images, deploy frontend on s3, etc...)
    - one agent per kubernetes cluster
    