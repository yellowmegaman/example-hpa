# GKE hpa test [![Build Status](https://cloud.drone.io/api/badges/yellowmegaman/example-hpa/status.svg)](https://cloud.drone.io/yellowmegaman/example-hpa)

#### Prerequisites:
1) Didn't use ssl certs
2) Used this for webserver https://gist.github.com/enricofoltran/10b4a980cd07cb02836f70a4ab3e72d7 but basicall even nginx will do
3) Used nginx-ingress-controller
4) Used prometheus and stackdriver
5) Used packer/drone.io for CD

#### Steps to launch:

1) apply k8s.tf via terraform. This will create a cluster with nodepool, static ip and two dns records. In this example thoose are:
 - hpa.oktanium.im
 - hpa-grafana.oktanium.im
 
2) create namespace's moonitoring custom-metrics ingress-nginx
3) set ip from terraform in cloud-generic.yaml for ingress-nginx
4) apply -R -f custom-metrics-stackdriver - this will setup custom-metrics server, which will give us ability to act upon them.
5) apply -R -f nginx-ingress-controller - this will setup nginx ingress controller with prometheus-to-sd sidecar. This sidecar will gather metrics from /metrics endpoing and route them to stackdriver custom-metrics. Could have used prometheus adapter, but this worked out of the box.
5) k apply -R -f prometheus - this will setup 1 instance of prometheus and grafana. Also some clusterroles and clusterrolebindings for proper access, ingress for grafana too. This will also auto-provision our dashboard to watch example-hpa app.
6) k apply -R -f example-hpa - this will add HorizontalPodAutoscaler and our app to k8s. It will scale example-hpa app if rps is higher than 1/s.  With minium of 1 and max of 5 replicas.

7) Now you start sending requests to http://hpa.oktanium.im and check dashboard.

![image](https://user-images.githubusercontent.com/3943191/57987731-5c0fe100-7a8e-11e9-94e2-44dfb555bf60.png)



P.S. GKE 1.12 v2beta1 HorizontalPodAutoscaler cool down period can't be configured (AFAIK), so replicas will dissappear after several minutes.
