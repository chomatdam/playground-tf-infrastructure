# AWS infrastructure
This project is aimed to have a production-grade kubernetes cluster based on EKS anywhere we would have to deploy a new cluster.

- Run **./initialize.sh** to install helm and authorize nodes to join the cluster

### Add a new IAM user to the cluster
```
kubectl edit -n kube-system configmap/aws-auth
  mapUsers: |
    - userarn: arn:aws:iam::743683729036:user/${IAM_USERNAME}
      username: ${IAM_USERNAME}
      groups:
        - system:masters
```
