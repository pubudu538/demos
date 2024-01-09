import ballerina/http;
import ballerina/openapi;

type WellnessData record {|
    string user_id;
    WellnessRecommendations wellness_recommendations;
|};

type WellnessRecommendations record {|
    PhysicalWellness physical_wellness;
    MentalWellness mental_wellness;
|};

type PhysicalWellness record {|
    string exercise;
    string nutrition;
|};

type MentalWellness record {|
    MindfulnessExercises mindfulness_exercises;
    string stress_management;
|};

type MindfulnessExercises record {|
    MindfulnessExercise[] mindfulness_exercises;
|};

type MindfulnessExercise record {|
    string name;
    string duration;
|};

@openapi:ServiceInfo {
    title: "Wellness Recommendation Service",
    'version: "0.1.0"
}
service / on new http:Listener(9090) {

    // This function responds with the health data of the user
    resource function get wellness\-recommendation(string user_id) returns WellnessData|error {

        WellnessData wellness_data = {wellness_recommendations: {physical_wellness: {
            exercise: "Try yoga for flexibility and relaxation.",
            nutrition: "Explore a Mediterranean diet for heart health."
        }, mental_wellness: {
            mindfulness_exercises: {
                mindfulness_exercises: [
                    {
                        name: "Deep Breathing",
                        duration: "5 minutes"
                    },
                    {
                        name: "Body Scan Meditation",
                        duration: "10 minutes"
                    }
                ]
            },
            stress_management: "Consider journaling to manage stress."
        }}, user_id: user_id};

        return wellness_data;
    }

}
