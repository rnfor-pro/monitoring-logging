# jenkins-infra-iac

### How to connect to my ec2 server created by terraform?
- As usual go to aws and copy the public ip address then enter it on your browser ($public_ip:8080)

## PLEASE MAKE SURE YOU CREAT YOUR OWN KEY PAIR DO NOT USE 'devtf-key'

# How to use this project?
1. From your wsl, run:
   `git clone https://github.com/etechConsultingDevops/jenkins-infra-iac`
2. `cd jenkins-infra-iac`
3. Run:
   `terraform init`
   `terraform fmt`
   `terraform validate`
   `terraform plan`
   `terraform apply -auto-approve`

4. Once the code complete executing, copy the `public_dns` as output and paste on your browser adding `:8080` to access your jenkins server landing page
