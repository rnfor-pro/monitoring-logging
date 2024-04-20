# Setting up AWS EKS (Hosted Kubernetes) Etech Consulting SOP

See https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html for full guide


## Download kubectl
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin
```

## Download the aws-iam-authenticator
```
wget https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64
chmod +x heptio-authenticator-aws_0.3.0_linux_amd64
sudo mv heptio-authenticator-aws_0.3.0_linux_amd64 /usr/local/bin/heptio-authenticator-aws
```

## Modify providers.tf

Choose your region. EKS is not available in every region, use the Region Table to check whether your region is supported: https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/

Make changes in providers.tf accordingly (region, optionally profile)

## Terraform apply
```
terraform init
terraform plan
terraform apply
```

## Configure kubectl
```
terraform output kubeconfig # save output in ~/.kube/config
sudo chown -R $USER ~/.kube/config
aws eks --region <region> update-kubeconfig --name terraform-eks-demo
```

## Configure config-map-auth-aws
```
terraform output config-map-aws-auth # save output in config-map-aws-auth.yaml
kubectl apply -f config-map-aws-auth.yaml
```

## See nodes coming up
```
kubectl get nodes
```

## Destroy
Make sure all the resources created by Kubernetes are removed (LoadBalancers, Security groups), and issue:
```
terraform destroy
```
## How do i get IAM permissions to see cluster resources?
After you login via your aws console, note down the arn of the iam user from IAM services

Run:
```
kubectl edit cm aws-auth -n kube-system
```
Add the following line carefully:
```
  mapUsers: |
    - userarn: arn:aws:iam::[account_id]:$iamuser
      username: $iamuser
      groups:
        - system:masters
 ```

[Install helm and argoCD steps](https://github.com/rnfor-pro/monitoring-logging/tree/main#:~:text=steps%20here-,Install%20helm%20here,-ArgoCD)
