# Deploy Netflix Clone on Cloud using Jenkins - DevSecOps Project!



DevSecOps Pipeline Solution built using Jenkins as the CI tool. With Sonarqube, OWASP, and Trivy for security and vulnerability detection. Docker was used in containerizing the App, while ArgoCD enabled Continuous Deployment to AWS EKS. Helm made managing the Kubernetes applications a breeze. With the power of Prometheus and Grafana, we gained valuable insights into the application’s performance, cluster health, and pipeline metrics.

- Setting up your environment
  - jenkins and prometheus servers using terraform [here](https://github.com/rnfor-pro/monitoring-logging/blob/main/README.md)
  - EKS [here](https://github.com/rnfor-pro/monitoring-logging/blob/main/kube-EKS/README.md)


This project is a Continuous Intergration, Iontinuous Delivery, Continuous Security, Continuous Monitoring and Continuous feedbackset-up. 

- config
  - SonarQube

    ```docker run -d --name sonar -p 9000:9000 sonarqube:lts-community```
  - Prometheus
``` 
sudo vi /etc/systemd/system/prometheus.service

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

```
sudo systemctl enable prometheus
sudo systemctl start prometheus

sudo systemctl status prometheus
```

- Node Exporter

```
sudo vi /etc/systemd/system/node_exporter.service

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

```
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter
```

- Entry for node_exporter in prometheus

```
sudo vim /etc/prometheus/prometheus.yml
```

```
- job_name: node_export
    static_configs:
      - targets: ["localhost:9100"]
```

- Entry for Jenkins
```
sudo vim /etc/prometheus/prometheus.yml
```  

```
- job_name: 'jenkins'
    metrics_path: '/prometheus'
    static_configs:
      - targets: ['<jenkins-ip>:8080']
``` 

Install helm [here](https://helm.sh/docs/intro/install/)




