# APK_Demo
This demo has the following outline.
- Install WSO2 APK 
- Deploy backend services
- Create and Deploy APIs in APK

[<img src="ai_health_app.png" width="250"/>](ai_health_app.png)

### Installation Prerequisites

- Kubernetes
- Helm

### Install WSO2 APK

- Install WSO2 APK on Kubernetes

   ```
   helm repo add wso2apk https://github.com/wso2/apk/releases/download/1.0.0
   helm repo update
   helm install apk wso2apk/apk-helm --version 1.0.0
   ```

- Verify Installation

   ```
   kubectl get pods -w
   ```

- Add /etc/hosts entries.

   ```
   127.0.0.1	api.am.wso2.com
   127.0.0.1	idp.am.wso2.com
   127.0.0.1	default.gw.wso2.com
   ```

   Note: For more information please refer [https://apk.docs.wso2.com/en/latest/get-started/quick-start-guide/](https://apk.docs.wso2.com/en/latest/get-started/quick-start-guide/)

### Deploy Backend Services

```
kubectl apply -f microservices.yaml
```

### Deploy Health Data API using apk-conf

- Generate APK configuration file from the OpenAPI definition

   ```
   curl -k --location 'https://api.am.wso2.com:9095/api/configurator/1.0.0/apis/generate-configuration' \
   --header 'Host: api.am.wso2.com' \
   --form 'definition=@"/Users/pubudugunatilaka/Documents/wso2/sources/demos/S19-APK_Demo/health_data_microservice/openapi.yaml"'
   ```

- Generate an access token to invoke APIs

   ```
   curl -k --location 'https://idp.am.wso2.com:9095/oauth2/token' \
   --header 'Host: idp.am.wso2.com' \
   --header 'Authorization: Basic NDVmMWM1YzgtYTkyZS0xMWVkLWFmYTEtMDI0MmFjMTIwMDAyOjRmYmQ2MmVjLWE5MmUtMTFlZC1hZmExLTAyNDJhYzEyMDAwMg==' \
   --header 'Content-Type: application/x-www-form-urlencoded' \
   --data-urlencode 'grant_type=client_credentials'
   ```

- Deploy the API in APK

   ```
   curl -k --location 'https://api.am.wso2.com:9095/api/deployer/1.0.0/apis/deploy' \
   --header 'Host: api.am.wso2.com' \
   --header 'Authorization: bearer TOKEN' \
   --form 'apkConfiguration=@"/Users/pubudugunatilaka/Documents/wso2/sources/demos/S19-APK_Demo/health_data_microservice/health-service.apk-conf"' \
   --form 'definitionFile=@"/Users/pubudugunatilaka/Documents/wso2/sources/demos/S19-APK_Demo/health_data_microservice/openapi.yaml"'
   ```

- List the API

   ```
   kubectl get apis
   ```

- Invoke the API

   ```
   curl -k --location 'https://default.gw.wso2.com:9095/SGVhbHRoIERhdGEgQW5hbHlzaXMgU2VydmljZTAuMS4w/0.1.0/health-data-analysis' \
   --header 'Authorization: bearer TOKEN' \
   --header 'Content-Type: application/json' \
   --data '{
   "user_id": "123456",
   "health_data": {
      "activity_level": "moderate",
      "sleep_duration": "7H",
      "heart_rate": 75,
      "steps": "1000",
      "blood_pressure": "120/80mmHg"
   }
   }
   '
   ```

### Deploy Wellness Recommendation API using Kubernetes CRs

- Generate APK configuration file from the OpenAPI definition

   ```
   curl -k --location 'https://api.am.wso2.com:9095/api/configurator/1.0.0/apis/generate-configuration' \
   --header 'Host: api.am.wso2.com' \
   --form 'definition=@"/Users/pubudugunatilaka/Documents/wso2/sources/demos/S19-APK_Demo/wellness_recommendation_microservice/openapi.yaml"'
   ```

- Generate Kubernetes CRs for the API

   ```
   curl -k --location 'https://api.am.wso2.com:9095/api/configurator/1.0.0/apis/generate-k8s-resources' \
   --header 'Content-Type: multipart/form-data' \
   --header 'Accept: application/zip' \
   --form 'apkConfiguration=@"/Users/pubudugunatilaka/Documents/wso2/sources/demos/S19-APK_Demo/wellness_recommendation_microservice/wellness-rec-service.apk-conf"' \
   --form 'definitionFile=@"/Users/pubudugunatilaka/Documents/wso2/sources/demos/S19-APK_Demo/wellness_recommendation_microservice/openapi.yaml"' \
   --output ./wellness-api-crds.zip
   ```

- Deploy the API in APK

   ```
   kubectl apply -f /Users/pubudugunatilaka/Documents/wso2/sources/demos/S19-APK_Demo/kubernetes-crs/
   ```

- List the API

   ```
   kubectl get apis
   ```

- Invoke the API

   ```
   curl -k --location 'https://default.gw.wso2.com:9095/V2VsbG5lc3MgUmVjb21tZW5kYXRpb24gU2VydmljZTAuMS4w/0.1.0/wellness-recommendation?user_id=9' \
   --header 'Authorization: bearer TOKEN'
   ```
