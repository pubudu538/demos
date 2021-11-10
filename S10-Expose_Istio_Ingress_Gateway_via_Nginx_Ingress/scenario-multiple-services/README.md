## Deploying the multiple services scenario

![Alt text](multiple-services.png?raw=true "Multiple Services Approach")

#### 1: Deploy microservices

    apictl apply -f microservices.yaml

#### 2: Add an API for the microservices

    apictl add api -n online-store-api-sc --from-file=./swagger.yaml --override

#### 3: Add Gateway for Istio (Optional)

    apictl apply -f mg-gateway.yaml 

#### 4: Create a microgateway label by logging into the admin portal (https://apis.wso2.com/admin)

- Click on the Gateways menu from the left side menu in the admin portal.

- Create a label in API Manager using the admin portal
    |  Label       | Description          |   Gateway Host        |
    | :----------: |:--------------------:|:---------------------:|
    | microgateway | Microgateway for K8s | https://mg.wso2.com   |


#### 5: Import the Swagger definition to API Manager

- Initialize an API project with the swagger definition.

    ```sh
    apictl init online-store-api-sc \
              --oas=./swagger.yaml \
              --initial-state=PUBLISHED
    ```

- Edit the `online-store-api-sc/Meta-information/api.yaml` with adding `gatewayLabels` as follows.
    ```yaml
    gatewayLabels:
      - name: microgateway
    ```

- Import the API to API Manager
    ```sh
    apictl add-env \
            -e dev \
            --apim https://apis.wso2.com \
            --token https://apis.wso2.com/oauth2/token

    apictl login dev -k
  
    apictl import-api -f online-store-api-sc/ -e dev -k 
    ```

#### 6: Try out in Dev Portal

- Select the API in [Dev Portal](https://apis.wso2.com/devportal/apis)
- Subscribe to an Application and generate an access token.
- Go to `Try Out` tab and select the gateway as `microgateway`.
- Try out API.