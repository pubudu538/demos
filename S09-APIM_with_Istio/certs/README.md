openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 \
        -subj '/O=wso2 Inc./CN=*.wso2.com' \
        -keyout wso2.com.key \
        -out wso2.com.crt
        
openssl req -out mg.wso2.com.csr -newkey rsa:2048 -nodes \
        -keyout mg.wso2.com.key \
        -subj "/CN=mg.wso2.com/O=wso2 organization"


openssl x509 -req -days 365 -set_serial 0 -in mg.wso2.com.csr \
        -CAkey wso2.com.key \
        -CA wso2.com.crt \
        -out mg.wso2.com.crt

apictl create secret tls mg-wso2-credential \
        --key mg.wso2.com.key \
        --cert mg.wso2.com.crt \
        -n istio-system