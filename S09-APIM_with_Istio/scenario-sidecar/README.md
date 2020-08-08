## Deploying the sidecar scenario


#### 1: Enable Istio sidecar injection

    apictl label namespace default istio-injection=enabled 

#### 2: Deploy the inventory service target endpoint

    apictl apply -f inventory-sidecar.yaml

#### 3: Add an API for the inventory service

    apictl add api -n inventory-sc --from-file=swagger.yaml --override

#### 4: Create a microgateway label by logging into the admin portal (https://apis.wso2.com/admin)

- Click on the Gateways menu from the left side menu in the admin portal.

- Create a label in API Manager using the admin portal
    |  Label       | Description          |   Gateway Host        |
    | :----------: |:--------------------:|:---------------------:|
    | microgateway | Microgateway for K8s | https://mg.wso2.com   |

#### 5: Update the Swagger definition

- Open the Swagger definition and comment the following line

    ```
    x-wso2-production-endpoints: inventory-sidecar
    ```

#### 6: Import the Swagger definition to API Manager

- Initialize an API project with the swagger definition.

    ```sh
    apictl init inventory-sc \
              --oas=./swagger.yaml \
              --initial-state=PUBLISHED
    ```

- Edit the `inventory-sc/Meta-information/api.yaml` with adding `gatewayLabels` as follows.
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
  
    apictl import-api -f inventory-sc/ -e dev -k 
    ```

#### 7: Try out in Dev Portal

- Select the API in [Dev Portal](https://apis.wso2.com/devportal/apis)
- Subscribe to an Application and generate an access token.
- Go to `Try Out` tab and select the gateway as `microgateway`.
- Try out API.