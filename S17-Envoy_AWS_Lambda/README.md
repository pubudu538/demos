# Envoy - AWS Lambda Filter

This guide helps you to deploy Enovy proxy with AWS Lambda filter.

### Installation Prerequisites

- Docker
- Docker Compose

### Create an AWS Lambda Function

- Create an AWS Lambda function from the UI or any other way. You don't need to do any other advanced configuration. 

### Get Access Credentials to the AWS Lambda Function

- Go to the IAM section in AWS Console
- Create a new policy with the following policy definition. 

   ```
   {
      "Version": "2012-10-17",
      "Statement": [
         {
               "Sid": "test123",
               "Effect": "Allow",
               "Action": [
                  "lambda:InvokeAsync",
                  "lambda:InvokeFunction"
               ],
               "Resource": [
                  "*"
               ]
         }
      ]
   }
   ```

- Create a new user and attach the policy as follows.

   ![Alt text](add_user.png?raw=true "Add User")

   ![Alt text](attach_policy.png?raw=true "Attach Policy")

- Copy the Access Key and Secret Key shown at the final step.

### Start Envoy

- Replace the ARN value of the Lambda function in envoy.yaml. Also change the region details accordingly in the envoy.yaml.
- Replace the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY values in the docker-compose.yaml
- Start the containers as follows.

   ```
   docker-compose up --detach
   ```

### Send a Reqest to AWS Lambda

   ```
   curl http://localhost:9000/
   ```
