import ballerina/http;
import ballerina/openapi;

type HealthData record {|
    string user_id;
    HealthStat health_data;
|};

type HealthStat record {|
    string activity_level;
    string sleep_duration;
    int heart_rate;
    string steps;
    string blood_pressure;
|};

@openapi:ServiceInfo {
    title: "Health Data Analysis Service",
    'version: "0.1.0"
}
service / on new http:Listener(9090) {

    // This function responds with the health data of the user
    resource function post health\-data\-analysis(@http:Payload HealthData healthdata) returns HealthData|error {

        return healthdata;
    }
}



