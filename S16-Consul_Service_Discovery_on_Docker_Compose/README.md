# Consul Service Discovery on Docker Compose

This guide helps you to deploy Consul on Docker Compose for service discovery.

### Installation Prerequisites

- Docker

### Generate certs (Optional)

- Download and install Consul command line tool. Execute the following for creating certs.

   ```
   consul tls ca create
   consul tls cert create -server -dc dc1 -additional-dnsname docker.for.mac.localhost
   consul tls cert create -client 
   ```
   For more information - https://learn.hashicorp.com/tutorials/consul/tls-encryption-secure

### Start Consul

```
docker-compose up --detach
```

### Create the bootstrap token and add the agent token to all Consul agents (Server and Client)

- Generate the token
   ```
   docker exec -it consul-server1 /bin/sh
   consul acl bootstrap
   ```

   Output:
   ```
   AccessorID:       cee36808-027d-1924-e353-abbb636dabfb
   SecretID:         8d9c18f5-222c-feb3-08f4-c6bdd360eea5
   Description:      Bootstrap Token (Global Management)
   Local:            false
   Create Time:      2021-11-10 11:18:52.8983115 +0000 UTC
   Policies:
      00000000-0000-0000-0000-000000000001 - global-management
   ```

   **Note:** SecretID is the agent token. Set as follows in the server.

- Set the Agent token in Consul server 1

   ```
   export CONSUL_HTTP_TOKEN=8d9c18f5-222c-feb3-08f4-c6bdd360eea5
   consul acl set-agent-token agent "8d9c18f5-222c-feb3-08f4-c6bdd360eea5"
   consul reload -token "8d9c18f5-222c-feb3-08f4-c6bdd360eea5"
   ```

- Set the Agent token in Consul Client

   ```
   docker exec -it consul-client /bin/sh

   export CONSUL_HTTP_TOKEN=8d9c18f5-222c-feb3-08f4-c6bdd360eea5
   consul acl set-agent-token agent "8d9c18f5-222c-feb3-08f4-c6bdd360eea5"
   consul reload -token "8d9c18f5-222c-feb3-08f4-c6bdd360eea5"
   ```

### Verify Installation 

```
curl --header "X-Consul-Token: 8d9c18f5-222c-feb3-08f4-c6bdd360eea5" http://127.0.0.1:8500/v1/agent/members

curl --header "X-Consul-Token: 8d9c18f5-222c-feb3-08f4-c6bdd360eea5" https://127.0.0.1:8501/v1/agent/members -k
curl --header "X-Consul-Token: 8d9c18f5-222c-feb3-08f4-c6bdd360eea5" https://127.0.0.1:8501/v1/agent/members --cacert consul-agent-ca.pem
```

**Note:** If verify_incoming is enabled in Consul, use the following.

```
curl --key dc1-client-consul-0-key.pem --cert dc1-client-consul-0.pem --cacert consul-agent-ca.pem --header "X-Consul-Token: 8d9c18f5-222c-feb3-08f4-c6bdd360eea5" \
https://127.0.0.1:8501/v1/agent/members
```

### Deploy Sample Service

```
curl --request PUT --header "X-Consul-Token: 8d9c18f5-222c-feb3-08f4-c6bdd360eea5" --data @web.json localhost:8500/v1/catalog/register

curl --header "X-Consul-Token: 8d9c18f5-222c-feb3-08f4-c6bdd360eea5" http://localhost:8500/v1/health/service/google
```

### Access Consul UI

http://localhost:8500/ui/dc1/services

**Note:** Provide the Secret ID when logs in.


### Configure Consul with Choreo Connect for Service Discovery

- Add the following configurations in the adapter config.toml. 

```
[adapter.consul]
  enabled = true
  url = "https://docker.for.mac.localhost:8501"
  pollInterval = 5
  ACLToken = "8d9c18f5-222c-feb3-08f4-c6bdd360eea5"
  mgwServiceName = "choreo-connect"
  serviceMeshEnabled = false
  caCertFile = "/home/wso2/security/truststore/consul/consul-agent-ca.pem"
  certFile = "/home/wso2/security/truststore/consul/dc1-client-consul-0.pem"
  keyFile = "/home/wso2/security/truststore/consul/dc1-client-consul-0-key.pem"
```

- Update the docker compose file for certs.

```
  adapter:
    volumes:
      - ./certs/consul-agent-ca.pem:/home/wso2/security/truststore/consul/consul-agent-ca.pem
      - ./certs/dc1-client-consul-0.pem:/home/wso2/security/truststore/consul/dc1-client-consul-0.pem
      - ./certs/dc1-client-consul-0-key.pem:/home/wso2/security/truststore/consul/dc1-client-consul-0-key.pem
```


## References 

1. https://learn.hashicorp.com/tutorials/consul/docker-compose-datacenter
2. http://man.hubwiz.com/docset/Consul.docset/Contents/Resources/Documents/docs/guides/creating-certificates.html
3. https://github.com/hashicorp/learn-consul-docker