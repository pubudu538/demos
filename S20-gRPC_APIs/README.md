# gRPC APIs with WSO2 API Microgateway v3.2.0

This demo has the following outline.
- Install WSO2 APK
- Deploy backend services
- Create and Deploy APIs in APK

### Installation Prerequisites

- Download and configure WSO2 API Microgateway and the toolkit
- Java
- Maven

### Run the gRPC server

- Setup gRPC backend service

   ```
   git clone https://github.com/pubudu538/HelloworldGrpcImpl.git
   cd HelloworldGrpcImpl
   mvn clean install
   ```

- Run gRPC Server

   ```
   java -jar serverImpl/target/serverImpl-1.0-SNAPSHOT.jar 9088
   ```

### Setup the API Microgateway Project using the Microgateway toolkit


- Setup the toolkit as explained in [https://mg.docs.wso2.com/en/latest/install-and-setup/install-on-vm/#microgateway-toolkit](https://mg.docs.wso2.com/en/latest/install-and-setup/install-on-vm/#microgateway-toolkit)

- Create a new Project using the toolkit (Navigate to wso2am-micro-gw-toolkit-macos-3.2.0/bin)

   ```
   ./micro-gw init grpcapi
   ```

- Add wso2_hello_world.proto definition file by creating a folder called `HelloWorld` under grpc_definitions folder inside the grpcapi project.

   ```
   grpcapi
   ├── api_definitions
   ├── conf
   ├── extensions
   ├── grpc_definitions
   │   └── HelloWorld
   │       └── wso2_hello_world.proto
   ├── interceptors
   ├── lib
   └── policies.yaml
   ```

- Update policies.yaml by adding 3PerMin under resourcePolicies.

   ```
   - 3PerMin:
     count: 3
     unitTime: 1
     timeUnit: min
   ```

- Build the project 

   ```
   ./micro-gw build grpcapi
   ```

   This generates the grpcapi.jar file for the project. Use the given jar file path in the next step.

### Run the API Microgateway

- Run the API Microgateway(Navigate to wso2am-micro-gw-macos-3.2.9/bin)

   ```
   ./gateway wso2am-micro-gw-toolkit-macos-3.2.0/bin/grpcapi/target/grpcapi.jar
   ```

### Access the gRPC API using the gRPC client

- Generate an access token for API invocation

   ```
   curl -X get "https://localhost:9095/apikey" -H "Authorization:Basic YWRtaW46YWRtaW4=" -k
   ```

- Use the gRPC client in HelloworldGrpcImpl 

   ```
   cd HelloworldGrpcImpl
   ```

- Access the API

   - HTTP

      ```
      java -jar clientImpl/target/clientImpl-1.0-SNAPSHOT.jar <Input Message> <Access Token> <HTTP/S Port of the API Gateway>

      java -jar clientImpl/target/clientImpl-1.0-SNAPSHOT.jar World <Access Token> 9090
      ```

   - HTTPS

      ```
      java -jar clientImpl/target/clientImpl-1.0-SNAPSHOT.jar World <Access Token> 9095 ./api-microgateway.pem
      ```

### Generate Docker, Kubernetes artifacts for the API Microgateway project

- Set Docker Host(Optional)

   ```
   export DOCKER_HOST=unix:///Users/pubudug/.rd/docker.sock
   ```

- Build the project with a deployment toml.

   ```
   ./micro-gw build grpcapi --deployment-config deployment.toml
   ```
