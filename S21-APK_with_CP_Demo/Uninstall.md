# Uninstall

```
helm uninstall apk
k delete crd applicationmappings.cp.wso2.com applications.cp.wso2.com backendjwts.dp.wso2.com backends.dp.wso2.com gqlroutes.dp.wso2.com interceptorservices.dp.wso2.com
k delete crd ratelimitpolicies.dp.wso2.com scopes.dp.wso2.com subscriptions.cp.wso2.com
k delete MutatingWebhookConfiguration apk-wso2-apk-mutating-webhook-configuration
k delete ValidatingWebhookConfiguration apk-wso2-apk-validating-webhook-configuration


helm install apk wso2apk/apk-helm --version 1.1.0 -f /Users/pubudug/Documents/wso2/sources/demos/S19-APK_Demo/apk-values.yaml -n apk

Update Gateway IPs for /etc/hosts
Restart APK Agent
```
