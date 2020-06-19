# Istio_Demo_With_API_Manager

In this scenario, 

1. We deploy microservices in Istio
2. Expose an API for the microservices
3. Import the API into API Manager
4. Generate an access token from the Devportal and access the API from Devportal

### Installation Prerequisites

- Kubernetes Cluster
- Istio 1.5.1 (istioctl manifest apply --set profile=demo)
- [API Operator v1.1.0](https://github.com/wso2/k8s-api-operator/tree/v1.1.0)
- Apictl (Set mode to Kubernetes, apictl set --mode k8s)
- Follow the [readme](certs/README.md) for TLS cert configure 
- Run WSO2 API Manager 3.1.0 locally

#### 1. Update the default security of API Operator

    apictl apply -f api-operator/default-security-api-operator.yaml
    
#### 2. Deploy microservices and API Microgateway

- Deploy microservices

    ```
    apictl apply -f microservices.yaml
    ```
    
- Initialize the project, deploy and configure API Gateway
  
  ```
  apictl init online-store-api --oas=./swagger.yaml --initial-state=PUBLISHED
  apictl add api -n online-store-api -f online-store-api/ --namespace=micro
  apictl apply -f gateway-virtualservice-internal.yaml
  ```

#### 3. Create 2 labels in API Manager using the admin portal

- Create two labels as follows.

|  Label   | Description      |   Gateway Host            |
| :------: |:----------------:|:-------------------------:|
| internal | internal gateway | https://internal.wso2.com |


#### 4. Deploy API in API Manager as a private API
    
- Update/modify api.yaml with the following information
    
    ```
    gatewayLabels:
      -
        name: internal
        accessUrls:
          - https://internal.wso2.com
    ```

- Add the environment as dev and import the API
    
    ```
    apictl add-env -e dev --apim https://localhost:9443 --token https://localhost:9443/oauth2/token    
    apictl import-api -f online-store-api/ -e dev -k
    ```
    
#### 5. Access the API in the internal gateway

- Login to developer portal with the developer user.
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
    - Access the API
        ```
        curl https://internal.wso2.com/store/v1.0.0/products -H "Authorization:Bearer $TOKEN" -k
        ```
     
    Alternative approach without adding an /etc/host entry as follows.
    ```
    curl -v -HHost:internal.wso2.com --resolve internal.wso2.com:34.87.12.17:443 https://internal.wso2.com/store/v1.0.0/products -H "Authorization:Bearer $TOKEN" -k
    ```