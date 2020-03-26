# API Manager on Kubernetes

### Installation Prerequisites

- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

- [Kubernetes v1.12 or above](https://Kubernetes.io/docs/setup/) 

- Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) in K8s

In this scenario, we are doing the following things.

1. Deploy API Manager v3.1.0 on wso2 namespace
2. Deploy products microservice in micro namespace
3. Access the API Manager

    ```
    kubectl get ing -n wso2
    
    Output:
    NAME                      HOSTS              ADDRESS           PORTS     AGE
    wso2am-gw-ingress         wso2apim-gateway   104.15.172.116   80, 443   27m
    wso2am-pubstore-ingress   wso2apim           104.15.172.116   80, 443   27m
    ```
    
    Add an /etc/hosts entry as follows.
    
    ```
    104.15.172.116 wso2apim wso2apim-gateway
    ```
    
    Access URLs:
    
    ```
    Publisher : https://wso2apim/publisher
    Devportal : https://wso2apim/devportal
    Gateway   : https://wso2apim-gateway
    ```

4. Create an API in publisher with the following details.

    - Endpoint  : http://products.micro 
    
    - Resources :
    ```
     i) /products
    ii) /products/{id}
    ```

5. Publish the API, subscribe to the API and generate an access token.
6. Use Swagger UI in devportal to try out the API.
