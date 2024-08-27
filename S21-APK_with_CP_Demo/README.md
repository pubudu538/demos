# APK_Demo

The AI-Powered Health and Wellness Coach App is a mobile application that delivers pertinent health-related data to users, offering customized coaching recommendations. This solution is composed of two microservices designed to enhance the user experience by providing tailored guidance on their well-being journey.

[<img src="ai_health_app.png" width="250"/>](ai_health_app.png)

This demo has the following outline.
- Install WSO2 APK 1.1.0, WSO2 API Manager v4.3.0 and WSO2 APK Agent.
- Deploy backend services
- Create and Deploy APIs in APK

### Installation Prerequisites

- Kubernetes
- Helm

### Install WSO2 APK with WSO2 API Manager Control Plane

- Follow https://apk.docs.wso2.com/en/latest/get-started/quick-start-guide-with-cp/ and install APK, APIM CP and APK Agent.

- Install Tracing Components and enable Tracing in APK

   ```
   kubectl apply -f tracing.yaml
   ```


- Install Prometheus/Grafana and enable metrics in APK

   ```
   kubectl create ns prometheus
   kubectl apply -f prometheus.yaml -n prometheus
   ```

   Note: Use the following command to get the generated credentials for Grafana.
   ```
   kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
   ```

- Configure Choreo Analytics 

   ```
   kubectl create secret generic choreo-analytics-secret --from-literal=authToken='TOKEN-REPLACE-ME' --from-literal=authURL='https://analytics-event-auth.choreo.dev/auth/v1' -n apk
   ```

   Note: Use the following command to use updated values.yaml for APK.

   ```
   helm install apk wso2apk/apk-helm --version 1.1.0 -f /Users/pubudug/Documents/wso2/sources/demos/S19-APK_Demo/apk-values.yaml -n apk

   helm upgrade apk wso2apk/apk-helm --version 1.1.0 -f /Users/pubudug/Documents/wso2/sources/demos/S19-APK_Demo/apk-values.yaml -n apk --no-hooks
   ```

- Verify Installation

   ```
   kubectl get pods -w
   ```

- Add /etc/hosts entries.

   ```
   127.0.0.1	api.am.wso2.com
   127.0.0.1	am.wso2.com
   127.0.0.1	idp.am.wso2.com
   127.0.0.1	default.gw.wso2.com
   127.0.0.1	carbon.super.gw.wso2.com
   ```

   Note: For more information please refer [https://apk.docs.wso2.com/en/latest/get-started/quick-start-guide-with-cp/](https://apk.docs.wso2.com/en/latest/get-started/quick-start-guide-with-cp/)

### Deploy Backend Services

```
kubectl apply -f microservices.yaml
```

### Deploy Health Data API using apk-conf

- Generate APK configuration file from the OpenAPI definition

   ```
   curl -k --location 'https://api.am.wso2.com:9095/api/configurator/1.1.0/apis/generate-configuration' \
   --header 'Host: api.am.wso2.com' \
   --form 'definition=@"/Users/pubudug/Documents/wso2/sources/demos/S19-APK_Demo/health_data_microservice/openapi.yaml"'
   ```

- Generate Kubernetes CRs for the API

   ```
   curl --location 'https://api.am.wso2.com:9095/api/configurator/1.1.0/apis/generate-k8s-resources?organization=carbon.super' \
   --header 'Content-Type: multipart/form-data' \
   --header 'Accept: application/zip' \
   --form 'apkConfiguration=@"/Users/pubudug/Documents/wso2/sources/demos/S19-APK_Demo/health_data_microservice/health-service.apk-conf"' \
   --form 'definitionFile=@"/Users/pubudug/Documents/wso2/sources/demos/S19-APK_Demo/health_data_microservice/openapi.yaml"' \
   -k --output ./api-crds.zip
   ```

- Deploy the API in APK

   ```
   kubectl apply -f /Users/pubudug/Documents/wso2/sources/demos/S19-APK_Demo/kubernetes-crs/ -n apk
   ```

- List the API

   ```
   kubectl get apis
   ```

- Invoke the API

   - Login to the Publisher Console (https://am.wso2.com/publisher) of the WSO2 API Manager.
   - Publish the API to the Developer portal after productizing the API.
   - Login to the Developer Portal (https://am.wso2.com/devportal) of the WSO2 API Manager.
   - Create an application and subscribe to the API.
   - Invoke the API.

   ```
   curl -k --location 'https://carbon.super.gw.wso2.com:9095/SGVhbHRoIERhdGEgQW5hbHlzaXMgU2VydmljZTAuMS4w/0.1.0/health-data-analysis' \
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

















