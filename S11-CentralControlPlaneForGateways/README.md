# Central Control Plane for Gateways

### Installation Prerequisites

- Kubernetes Cluster
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- Docker Registry account (Dockerhub, Amazon, GCR, Quay.io)
- [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/)


#### 1. Install apictl in local machine

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

  
#### 2. Install API Operator in Kubernetes

- Execute the following command to install API Operator interactively and configure repository to push the built managed API image.
- Select "Docker Hub" as the repository type.
- Enter repository name of your Docker Hub account (usually it is the username as well).
  - Supports both `jennifer` and `docker.io/jennifer` (backward compatibility) as repository name.
- Enter username and the password.
- Confirm configuration are correct with entering "Y".

    ```sh
    apictl install api-operator -f k8s-api-operator-1.2.2/api-operator/controller-artifacts/

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
   

#### 3. Install API Manager in Kubernetes

- Deploy API Manager

Execute this command when the MySQL pod is ready.

    kubectl apply -f api-portal/
    

#### 4: Add /etc/host entries in the machine to access API Manager and gateways

- Retrieve the IP addresses from the following command.  

    ```
    kubectl get ing -n wso2
    Output:
    NAME                      HOSTS              ADDRESS     PORTS     AGE
	wso2am-gw-ingress         gateway.wso2.com   localhost   80, 443   4m39s
	wso2am-pubstore-ingress   apis.wso2.com      localhost   80, 443   4m40s
    ```

- Add /etc/hosts entry with the external IP address as below. The hostname mgw.wso2.com is used for accessing the microgateways

    ```
    localhost apis.wso2.com  gateway.wso2.com  mgw.wso2.com
    ``` 

- Access URLs

    ```
    https://apis.wso2.com/publisher
    https://apis.wso2.com/devportal
    https://apis.wso2.com/admin
    https://gateway.wso2.com/
    https://mgw.wso2.com/
    ``` 


#### 5. Deploy microservices and API Microgateway

- Deploy microservices

    ```
    apictl apply -f microservices.yaml
    ```
    
- Initialize the project, deploy and configure API Gateway
  
  ```
  apictl init online-store-api --oas=./swagger.yaml
  apictl add api -n online-store-api -f online-store-api/ 
  ```


#### 6. Create a label in API Manager using the admin portal - https://apis.wso2.com/admin

- Create a label as follows.

|  Label        | Description      |   Gateway Host            |
| :-----------: |:----------------:|:-------------------------:|
| microgateway  | Microgateway     | https://mgw.wso2.com |


#### 7. Import the API in API Manager
    
- Add the environment as dev and import the API
    
    ```
    apictl add-env -e k8s \
            --apim https://apis.wso2.com \
            --token https://apis.wso2.com/oauth2/token

    apictl login k8s -k

    apictl import-api -f online-store-api/ -e k8s -k
    ```


#### 8. Publish the API

- Login to the API Publisher
- Select the microgateway label from the environment section
- Productize the API
- Publish the API


#### 9. Access the API

- Login to developer portal.
- Subscribe to the API.
- Generate a JWT access token.
- Access the API using the Swagger UI.







