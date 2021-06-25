# Deploy ELK with Filebeat

This demo deploys ELK stack and deploy filebeat as a daemon set.  

### Installation Prerequisites

- Kubernetes Cluster (v1.19.7)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- Helm

#### 1. Deploy NFS Server Provisioner

- Elastic Search needs a storage for processed data

```
helm repo add wso2 https://helm.wso2.com

helm install my-nfs-server-provisioner wso2/nfs-server-provisioner --version 1.1.0
```

#### 2. Deploy ELK Stack with Filebeat

```
kubectl apply -f elk.yaml
```

#### 3. Deploy the application

```
kubectl apply -f pod.yaml
```

#### 4. Access the Kibana dashboard

```
kubectl port-forward svc/kibana 5601
```

```
http://localhost:5601
```

#### 5. Create an index in Kibana

![Alt text](images/index_1.png?raw=true "Create Index")

![Alt text](images/index_2.png?raw=true "Create Index")

#### 6. Check Results

![Alt text](images/dashboard.png?raw=true "Dashboard")


