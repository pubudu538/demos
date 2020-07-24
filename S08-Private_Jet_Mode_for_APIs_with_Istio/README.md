# Private Jet mode for APIs with Istio

In this scenario, 

1. We deploy microservices in Istio
2. Expose an API for the microservices as a managed API
3. Import the API to the API Publisher
4. Publish the API after selecting the relevant microgateway label
5. Access the API from the Swagger UI in Devportal
6. Create an API in the API Publisher
7. Publish the API in Private Jet Mode
8. Access the API from the Swagger UI in Devportal

### Installation Prerequisites

- Kubernetes Cluster
- Istio 1.6.5
- API Operator v1.2.0-alpha (apictl install api-operator -f k8s-api-operator-1.2.0-alpha/api-operator/controller-artifacts/)
- Apictl (Set mode to Kubernetes, apictl set --mode k8s)
- WSO2 API Manager 3.2.0 run locally
- Follow the [readme](certs/README.md) for TLS cert configure 

#### 1. Update the default security of API Operator

    apictl apply -f api-operator/ -f api-manager/
    apictl apply -f gateway-virtualservice-internal.yaml
    
#### 2. Deploy microservices and API Microgateway

- Deploy microservices

    ```
    apictl apply -f microservices.yaml
    ```
    
- Initialize the project, deploy and configure API Gateway
  
  ```
  apictl init online-store-api --oas=./swagger.yaml
  apictl add api -n online-store-api -f online-store-api/ --namespace=micro
  ```

#### 3. Create a label in API Manager using the admin portal

- Create the label as follows.

|  Label   | Description      |   Gateway Host            |
| :------: |:----------------:|:-------------------------:|
| internal | internal gateway | https://internal.wso2.com |


#### 4. Import the API

- Add the environment as dev and import the API
    
    ```
    apictl add-env -e dev --apim https://localhost:9443 --token https://localhost:9443/oauth2/token    
    apictl import-api -f online-store-api/ -e dev -k
    ```
    
#### 5. Access the API in the internal gateway

- Login to developer portal.
- Generate a JWT access token.
- Access the API as follows.

    - Use the following command to get the Ingress Gateway IP address. 
        ```
        apictl get svc istio-ingressgateway -n istio-system
        ```
    - Add an /etc/host entry as follows
        ```
        <IP>  internal.wso2.com external.wso2.com 
        ```
    - Access the API via the Swagger UI or using the curl
        ```
        curl -v https://internal.wso2.com/store/v1.0.0/products -H "Authorization:Bearer $TOKEN" -k
        ```
     

### Private Jet Mode for APIs


#### 1. Configure K8s Cluster 

kubectl create serviceaccount private-jet -n micro


cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: clusterrole-privatejet
rules:
- apiGroups: ["","apiextensions.k8s.io","wso2.com"]
  resources: ["configmaps","customresourcedefinitions","apis"]
  verbs: ["get", "post", "create", "delete", "put", "list","update"]
EOF


cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
 name: clusterrolebinding-privatejet
subjects:
- kind: ServiceAccount
  name: private-jet
  apiGroup: ""
  namespace: micro
roleRef:
  kind: ClusterRole
  name: clusterrole-privatejet
  apiGroup: rbac.authorization.k8s.io
EOF


#### 2. Configure API Manager for Private Jet mode

- Add the following to the deployment.toml

        ```
        [[ContainerMgtClusterConfig]]
        type = "Kubernetes"
        clusterName = "gke-cluster"
        displayName = "GKE K8s Cluster"
        properties.Replicas = 1
        properties.AccessURL = "https://internal.wso2.com"
        properties.MasterURL = "<MASTER_URL>"
        properties.SAToken = "SA_TOKEN"
        properties.Namespace = "micro"
        ```


#### 3. Deploy an API in API Publisher

- Create an API as follows.

        ```
        API Name: product-api
        Context: /product
        Version: v1
        Resources: /products, /products/{productid}
        ```

- Select the K8s environment and publish the API.

#### 4. Access the API

- Login to developer portal.
- Generate a JWT access token.
- Access the API using the Swagger UI.


