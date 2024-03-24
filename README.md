# Deploy Netflix Clone on AWS Cloud using Jenkins - DevSecOps Project!

DevSecOps Pipeline Solution built using Jenkins as the CI tool. With Sonarqube, OWASP, and Trivy for security and vulnerability detection. Docker used in containerizing the App, and ArgoCD to enabled Continuous Deployment to AWS EKS. Helm to managing the Kubernetes applications a breeze. With the power of Prometheus and Grafana, to gaine valuable insights into the application’s performance, cluster health, and pipeline metrics.

- Prerequisites

  - [AWSCLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#:~:text=Install%20or%20update%20to%20the%20latest%20version%20of%20the%20AWS%20CLI)

  - [Terraform](https://developer.hashicorp.com/terraform/install)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

[Fork the github repo](https://github.com/rnfor-pro/monitoring-logging.git) and clone it on your local machine.
```
git clone < repo_url>
```
```
cd monitoring-logging/Infrastructure
```

```
terraform init
terraform plan
terraform apply
```

Access Jenkins UI.
---

`
hostIP:8080
`
- Install all the below plugins by going to Manage Jenkins → plugins and select available plugins.
  - Docker
  - Docker commons
  - Docker pipeline
  - Docker API
  - Docker build step
  - Prometheus metrics
  - Email extension template
  - Eclipse Temurin installer
  - SonarQube scanner
  - Nodesjs
  - OWASP Dependency Check
  - Blue ocean

SonarQube
---

Run SonarQube on your Jenkins server as  a Docker Container and access its UI.

- SSH into your Jenkins server.
- Confirm docker daemon is active
```
sudo systemctl status docker
```
- Run sonarqube as a container
```
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```
- Access sonarqube on port 9000
`
<instance_public_ip>:9000
`
- Default username is admin and password is admin

Prometheus Exporter Configuration
---
Let’s finalize Prometheus installation by creating a systemd unit configuration file for Prometheus.

```
sudo vi /etc/systemd/system/prometheus.service
```
```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/data \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
``` 
This unit file is an essential part of setting up Prometheus as a systemd service. It ensures proper dependencies, restart behavior, and configuration for running Prometheus as a background service on a Linux system. The Prometheus service is configured to start after the network is online, and it will automatically restart in case of failure. The provided ExecStart command includes necessary parameters for Prometheus to operate effectively.

Next, we’ll enable and start Prometheus. Then, verify its status.
```
sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo systemctl status prometheus

```

We’ll access it through the public IP and on port 9090:
```
http://<your-server-ip>:9090
```
Node Exporter Configuration
---
Similarly, we’ll create a systemd unit configuration file for Node Exporter:

```
node_exporter --version
```
```
sudo vi /etc/systemd/system/node_exporter.service

```
```
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target


StartLimitIntervalSec=500
StartLimitBurst=5


[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter --collector.logind


[Install]
WantedBy=multi-user.target
```
Enable and start and check the status of node Exporter:
```
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter

```
`
Access node exporter on <host_ip>:9100
`

Next, we’ll need to define scraping intervals and targets for metric collection by modifying our `/etc/prometheus/prometheus.yml` file. 
We’ll first add a job for the Node Exporter. This will also add a new target for Prometheus to monitor and scrape.
```
sudo vim /etc/prometheus/prometheus.yml
```

```
- job_name: node_export
    static_configs:
      - targets: ["localhost:9100"]
```

We'll can use Promtool to check the syntax of the config. If it’s successful, we then go ahead and reload Prometheus configuration without restarting.
```
promtool check config /etc/prometheus/prometheus.yml
curl -X POST http://localhost:9090/-/reload
```


Grafana
---
We’ve already installed Grafana via the user data script. Let’s confirm its status.

```
sudo systemctl status grafana-server
```
Grafana User Interface can be accessed through the server `public IP on port 3000` by default. The default `username and password is admin`.

[Follow video for further configurations]()

Likewise, let’s integrate Jenkins with Prometheus to monitor the CI/CD pipeline. 

`Goto Manage Jenkins –> Plugins –> Available Plugins`

Entry for Jenkins
---
```
sudo vim /etc/prometheus/prometheus.yml
```  

```
- job_name: 'jenkins'
    metrics_path: '/prometheus'
    static_configs:
      - targets: ['<jenkins-ip>:8080']
``` 

```
promtool check config /etc/prometheus/prometheus.yml
```

Then, you can use a POST request to reload the config.
```
curl -X POST http://localhost:9090/-/reload
```
Check the targets section in your prometheus UI you will see Jenkins is added to it

Let’s add Dashboard for a better view in Grafana

`Click On Dashboard –> + symbol –> Import`

Dashboard
Use Id `9964` and click on load

Select the data source and click on Import
Now you will see the Detailed overview of Jenkins


Email extension template
---
`Go to your Gmail and click on your profile
Then click on Manage Your
Google Account –> click on the security tab on the left side panel you will get this page(provide mail password).
2-step verification should be enabled`.
[video]()

Eclipse Temurin installer
---
Configure Java and Nodejs in Global Tool Configuration

`Goto Manage Jenkins → Tools → Install JDK(17) and NodeJs(16)→ Click on Apply and Save`
[video]()

SonarQube scanner
---
Configure Sonar Server in Manage Jenkins
Grab the Public IP Address of your EC2 Instance, Sonarqube works on Port 9000, so `Public IP>:9000`.

Goto your Sonarqube Server. Click on Administration → Security → Users → Click on Tokens and Update Token → Give it a name → and click on Generate Token
[video]()

copy Token
`Goto Jenkins Dashboard → Manage Jenkins → Credentials → Add Secret Text. It should look like this`

Now, go to Dashboard → Manage Jenkins → System and Add like the below image.
[video]()

The Configure System option in Jenkins is used to configure different servers
Global Tool Configuration is used to configure different tools that we installed using Plugins

We will install a sonar scanner in the tools.
[video]()

In the Sonarqube Dashboard add a quality gate also

`
Administration–> Configuration–>Webhooks
`
in url section of quality gate
`
<http://jenkins-public-ip:8080>/sonarqube-webhook/
`
Let’s go to our Pipeline and add the script in our Pipeline Script on jenkins UI.
[video]()

```
pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/rnfor-pro/monitoring-logging.git'
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Netflix \
                    -Dsonar.projectKey=Netflix '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
    }
    post {
     always {
        emailext attachLog: true,
            subject: "'${currentBuild.result}'",
            body: "Project: ${env.JOB_NAME}<br/>" +
                "Build Number: ${env.BUILD_NUMBER}<br/>" +
                "URL: ${env.BUILD_URL}<br/>",
            to: 'nfor.rudolph1@gmail.com',
            attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
        }
    }
}
```

OWASP Dependency Check
---
`Goto Dashboard → Manage Jenkins → Tools → Dependency check`

Click on Apply and Save.

Now go configure → Pipeline and add this stage to your pipeline and build.

```
stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
```

Docker Image Build and Push
---
Now, goto Dashboard → Manage Jenkins → Tools → Docker installation

Add DockerHub Username and Password under Global Credentials [video]()

Add this stage to Pipeline Script and build
```
stage("Docker Build & Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker', toolName: 'docker'){
                       sh "docker build --build-arg TMDB_V3_API_KEY=xxxxxxxxxxx -t netflix ."
                       sh "docker tag netflix rudolphnfor/netflix:latest "
                       sh "docker push rudolphnfor/netflix:latest "
                    }
                }
            }
        }
        stage("TRIVY"){
            steps{
                sh "trivy image rudolphnfor/netflix:latest > trivyimage.txt"
            }
        }
```

When you log in to Dockerhub, you will see a new image is created

Now Run the container to see if the game coming up or not by adding the below stage

[here](https://github.com/rnfor-pro/monitoring-logging/blob/main/Jenkinsfile-container-build-stage)


EKS
---
 [steps here](https://github.com/rnfor-pro/monitoring-logging/blob/main/kube-EKS/README.md)

Install helm [here](https://helm.sh/docs/intro/install/)






