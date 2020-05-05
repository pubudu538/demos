# Promote_API_from_Private_to_Public_Istio

In this scenario, 

1. We deploy microservices in Istio
2. Expose an API for the microservices as a Private API
3. Import the API as a Private API in API Manager
4. Promote API as a Public API
5. Change routing to expose as a Public API 
6. Re-import the API to deploy as a Public API

### Installation Prerequisites

- Kubernetes Cluster
- Istio 1.5.1
- API Operator v1.1.0
- Apictl (Set mode to Kubernetes, apictl set --mode k8s)
- WSO2 API Manager 3.1.0 in K8s or outside

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
  apictl apply -f internal/gateway-virtualservice-internal.yaml
  ```


#### 3. Create 2 labels in API Manager using the admin portal

- Create two labels as follows.

|  Label   | Description      |   Gateway Host            |
| :------: |:----------------:|:-------------------------:|
| internal | internal gateway | https://internal.wso2.com |
| external | external gateway | https://external.wso2.com |


#### 4. Create roles and users using the carbon console

- Add the user and role as follows using the carbon console

|  User     | Role      |   
| :------:  |:---------:|
| developer | developer | 

- Add role mappings as follows using the admin console

|  Role               |  Mapped Role                  |   
| :------:            |:---------:                    |
| Internal/subscriber | Internal/subscriber,developer | 
| Internal/creator	  | Internal/creator,developer	  |
| Internal/publisher  | Internal/publisher,developer  |

- Sign up with an external user called John.

#### 5. Deploy API in API Manager as a private API
    
- Update/modify api.yaml with the following information
    
    ```
    visibility: restricted
    visibleRoles: developer
    gatewayLabels:
      -
        name: internal
        accessUrls:
          - https://internal.wso2.com
    ```

- Add the environment as dev and import the API
    
    ```
    apictl add-env -e dev --apim https://apis.apim.com:9443 --token https://km.apim.com:9443/oauth2/token    
    apictl import-api -f online-store-api/ -e dev -k
    ```
    
#### 6. Access the API in the internal gateway

- Login to developer portal with the developer user.
- Generate a JWT access token.
- Access the API as follows.

    ```
    curl -H "Host:internal.wso2.com" http://<ISTIO_INGRESS_GATEWAY_IP>/store/v1.0.0/products -H "Authorization:Bearer $TOKEN" 
    ```
    
    **Note:** Use the following command to get the Ingress Gateway IP address. 
    ```
    apictl get svc istio-ingressgateway -n istio-system
    ```

#### 7. Promote API Microgateway as a Public Gateway

    apictl apply -f external/gateway-virtualservice-external.yaml

#### 8. Promote the API as a public API.

- Update the api.yaml as follows.

    ```
    visibility: public
    gatewayLabels:
      -
        name: external
        accessUrls:
          - https://external.wso2.com
    ```

- Re-import the API with update flag

    ```
    apictl import-api -f online-store-api/ -e dev --update -k
    ```

#### 9. Access the API in the external gateway

- Login to developer portal with the John user.
- Generate a JWT access token.
- Access the API as follows.

    ```
    curl -H "Host:external.wso2.com" http://<ISTIO_INGRESS_GATEWAY_IP>/store/v1.0.0/products -H "Authorization:Bearer $TOKEN"  
    ```
