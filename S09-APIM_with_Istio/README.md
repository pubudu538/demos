# APIM with Istio

### Installation Prerequisites

- Kubernetes Cluster
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- Docker Registry account (Dockerhub, Amazon, GCR, Quay.io)


#### 1. Install Istio to Kubernetes Cluster

- Download Istio 1.6.7

    ```
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.6.7 sh -
    ```

- Deploy Istio in K8s

    ```
    cd istio-1.6.7/bin
    ./istioctl install --set profile=demo
    ```

#### 2. Install apictl in local machine

- Download relevant binary file from [here](./packs/apictl/)

- Extract the API controller distribution and navigate inside the extracted folder using the command-line tool

- Add the location of the extracted folder to your system's $PATH variable to be able to access the executable from anywhere.

    ```
    export PATH=$PATH:/home/pubudu/Documents/apictl
    ```

- You can find available operations using the below command.

    ```
    apictl --help
    ```
   
#### 3. Install API Operator in Kubernetes

- Execute the following command to install API Operator interactively and configure repository to push the built managed API image.
- Select "Docker Hub" as the repository type.
- Enter repository name of your Docker Hub account (usually it is the username as well).
  - Supports both `jennifer` and `docker.io/jennifer` (backward compatibility) as repository name.
- Enter username and the password.
- Confirm configuration are correct with entering "Y".

    ```sh
    apictl install api-operator -f packs/k8s-api-operator-1.2.0-beta/api-operator/controller-artifacts/

    Choose registry type:
    1: Docker Hub
    2: Amazon ECR
    3: GCR
    4: HTTP Private Registry
    5: HTTPS Private Registry
    6: Quay.io
    Choose a number: 1: 1
    Enter repository name: jennifer
    Enter username: jennifer
    Enter password: *******
    
    Repository: jennifer
    Username  : jennifer
    Confirm configurations: Y: Y
    ```
    
    Output:
    ```sh
    customresourcedefinition.apiextensions.k8s.io/apis.wso2.com created
    customresourcedefinition.apiextensions.k8s.io/ratelimitings.wso2.com created
    ...
    
    namespace/wso2-system created
    deployment.apps/api-operator created
    ...
    
    [Setting to K8s Mode]
    ```
    
#### 4. Install API Manager in Kubernetes

- Create a namespace called wso2 and deploy MySQL

    ```
    apictl apply -f api-manager/wso2-namespace.yaml
    apictl apply -f api-manager/mysql/
    ```

- Deploy API Manager

Execute this command when the MySQL pod is ready.

    apictl apply -f api-manager/api-portal/
    

#### 5: Add /etc/host entries in the machine to access API Manager and gateways

- Retrieve the IP address of the Ingress gateway

- Use EXTERNAL-IP as the \<ingress_gateway_host> based on the output of the following command.  

    ```
    apictl get svc istio-ingressgateway -n istio-system
    Output:
    NAME                   TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                                                                                                                                      AGE
    istio-ingressgateway   LoadBalancer   10.0.32.249   34.67.171.126   15020:30939/TCP,80:30104/TCP,443:31782/TCP,15029:30155/TCP,15030:32662/TCP,15031:31360/TCP,15032:32485/TCP,31400:31905/TCP,15443:32303/TCP   13h
    ```

- Add /etc/hosts entry with the external IP address as below.

    ```
    EXTERNAL-IP apis.wso2.com  gateway.wso2.com  mg.wso2.com
    ``` 

- Access URLs

    ```
    https://apis.wso2.com/publisher
    https://apis.wso2.com/devportal
    https://apis.wso2.com/admin
    ``` 

#### 6: Deploy certs for the Microgateway

- Execute following command to deploy the certs

    ```
    apictl create secret tls mg-wso2-credential \
        --key certs/mg.wso2.com.key \
        --cert certs/mg.wso2.com.crt \
        -n istio-system
    ``` 

#### 7: Try out the sidecar [scenario](./scenario-sidecar)

