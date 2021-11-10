# WSO2 API Manager v4 with Hashicorp Vault

This demo configures WSO2 API Manager v4.0.0 with Hashicorp Vault

### Installation Prerequisites

- WSO2 API Manager v4.0.0
- [Hashicorp Vault CLI](https://www.vaultproject.io/downloads) - Vault version v1.7.3

#### 1. Setting up Vault

- Start the vault (Using in dev mode)

```
vault server -dev
```

![Alt text](images/server_start.png?raw=true "Server in Dev Mode")

#### 2. Export Vault end point and token

```
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN=s.4nlhLISNswmVjnywVRvM9Vp4
```

#### 3. Create a new KV engine and add new secrets

```
vault secrets enable -path=wso2am -version=2 kv
vault kv put wso2am/keystore_password value=wso2carbon
vault kv put wso2am/admin_password value=admin
```

List down secrets
```
vault kv get -field=value wso2am/keystore_password
```

![Alt text](images/commands.png?raw=true "Commands")

#### 4. Configure API Manager

- Hashicorp Vault implementation can be found [here](https://github.com/wso2-extensions/carbon-securevault-hashicorp). You can build for latest jar or use the jars in jars folder.

- Copy vault-java-driver-5.1.0.jar to `<APIM_HOME>/repository/components/lib/`

- Copy org.wso2.carbon.securevault.hashicorp-1.0.jar to `<APIM_HOME>/repository/components/dropins/`

- Create/Update APIM_HOME/repository/conf/security/secret-conf.properties file and set following configurations.

```
keystore.identity.location=repository/resources/security/wso2carbon.jks
keystore.identity.type=JKS
keystore.identity.store.password=identity.store.password
keystore.identity.store.secretProvider=org.wso2.carbon.securevault.DefaultSecretCallbackHandler
keystore.identity.key.password=identity.key.password
keystore.identity.key.secretProvider=org.wso2.carbon.securevault.DefaultSecretCallbackHandler
carbon.secretProvider=org.wso2.securevault.secret.handler.SecretManagerSecretCallbackHandler

secVault.enabled=true
secretRepositories=vault
secretRepositories.vault.provider=org.wso2.carbon.securevault.hashicorp.repository.HashiCorpSecretRepositoryProvider
secretRepositories.vault.properties.address=http://127.0.0.1:8200
secretRepositories.vault.properties.namespace=ns1
secretRepositories.vault.properties.enginePath=wso2am
secretRepositories.vault.properties.engineVersion=2
```

**Note:** In production, you should always use the vault address with TLS enabled.

- Add following lines to the `<APIM_HOME>/repository/conf/log4j2.properties` file

    ```
    logger.org-wso2-carbon-securevault-hashicorp.name=org.wso2.carbon.securevault.hashicorp
    logger.org-wso2-carbon-securevault-hashicorp.level=INFO
    logger.org-wso2-carbon-securevault-hashicorp.additivity=false
    logger.org-wso2-carbon-securevault-hashicorp.appenderRef.CARBON_CONSOLE.ref = CARBON_CONSOLE
    ```

    Then append `org-wso2-carbon-securevault-hashicorp` to the `loggers` list in the same file as follows.
    ```
    loggers = AUDIT_LOG, trace-messages, ... ,org-wso2-carbon-securevault-hashicorp
    ```

- Update passwords with their aliases

1. Open the `deployment.toml` file in the `<APIM_HOME>/repository/conf/` directory and add
   the `[secrets]` configuration section **at the bottom of the file** as shown below.
   Give an alias for the passwords and put the value as blank (`""`).

    ```toml
    [secrets]
    admin_password = ""
    keystore_password = ""
    ```
   
2. Add the encrypted password alias to the relevant sections in the `deployment.toml`
   file by using a place holder: `$secret{alias}`. For example:

    ```toml
    [super_admin]
    username="admin"
    password="$secret{admin_password}"
    
    [keystore.primary]
    file_name = "wso2carbon.jks"
    password = "$secret{keystore_password}" 
    ```

- Start the Server

1. Provide the `VAULT_TOKEN` to the prompted message in the console or by creating a new file in the `<APIM_HOME>` directory. 
The file should be named according to your Operating System.

    ```
    For Linux   : The file name should be hashicorpRootToken-tmp.
    For Windows : The file name should be hashicorpRootToken-tmp.txt.
    ```
    When you add "tmp" to the file name, note that this will automatically get deleted from the file system after server
    starts. Alternatively, if you want to retain the password file after the server starts, the file should be named as follows:
    ```
    For Linux   : The file name should be hashicorpRootToken-persist.
    For Windows : The file name should be hashicorpRootToken-persist.txt.
    ```
   
2. Start the WSO2 APIM Server and enter the keystore password at the startup when prompted.
   ```
   [Enter KeyStore and Private Key Password :] wso2carbon
   ```