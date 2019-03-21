## Drone CI
The CI has:
- to scale quickly based on the number of builds (containers)
- being isolated from where apps are deployed (not on k8s)

ECS Fargate could be a great solution.
 https://github.com/appleboy/drone-terraform-in-aws