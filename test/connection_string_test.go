package test

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func TestConnectionStrings(t *testing.T) {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.

	base_connection_string, project_id := CreateMongoDbCluster(t)
	fmt.Println("base connection string: ", base_connection_string)

	base_connection_address := base_connection_string[14:len(base_connection_string)]
	fmt.Println("base connection address: ", base_connection_address)

	path, err := os.Getwd()
	if err != nil {
		log.Println(err)
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../modules/mongodb_atlas_service_connections",
		Vars: map[string]interface{}{
			"project_id": project_id,
			// hacky way of getting the example that was sent in the gist into go...
			"service_configuration": []map[string]interface{}{
				{"serviceName": "possums-data-store",
					"mongoCluster":    base_connection_address,
					"mongoDatabase":   "marsupials-dev",
					"mongoCollection": []string{"possums"}},
				{"serviceName": "numbats-data-store",
					"mongoCluster":    base_connection_address,
					"mongoDatabase":   "marsupials-dev",
					"mongoCollection": []string{"numbats"}},
				{"serviceName": "marsupials-data-store",
					"mongoCluster":    base_connection_address,
					"mongoDatabase":   "marsupials-prod",
					"mongoCollection": []string{"numbats", "possums"}},
			},
		},
		VarFiles: []string{
			// fmt.Sprintf("%v/example_services.tfvars", path),
			fmt.Sprintf("%v/private.tfvars", path),
		},
	})

	retryTime, _ := time.ParseDuration("30s")

	terraform.InitAndApply(t, terraformOptions)

	// The passwords are not immediately available after creating the accounts - we must wait and retry
	retry.DoWithRetryableErrors(t, "Attempting to connect to database using connection string",
		map[string]string{"connection": "unable to authenticate"}, 10, retryTime, AttemptToUseConnectionStrings)

	// comment out to delete after running! (useful when testing)
	// Clean up resources with "terraform destroy" at the end of the test.
	terraform.Destroy(t, terraformOptions)

	// Clean up resources with "terraform destroy" at the end of the test.
	clusterTerraformOptions := clusterTerraformOptions(t)
	terraform.Destroy(t, clusterTerraformOptions)
}

func CreateMongoDbCluster(t *testing.T) (string, string) {

	terraformOptions := clusterTerraformOptions(t)
	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	return terraform.Output(t, terraformOptions, "base_connection_string"),
		terraform.Output(t, terraformOptions, "project_id")
}

func clusterTerraformOptions(t *testing.T) *terraform.Options {
	return terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "modules/mongodb_atlas_cluster",
		VarFiles: []string{
			"main.tfvars",
			"private.tfvars",
		},
	})
}

func AttemptToUseConnectionStrings() (string, error) {
	byt, err := ioutil.ReadFile("../modules/mongodb_atlas_service_connections/terraform.tfstate")
	if err != nil {
		fmt.Print(err)
	}

	var dat map[string]interface{}
	if err := json.Unmarshal(byt, &dat); err != nil {
		panic(err)
	}

	connectionStringOutputs := dat["outputs"].(map[string]interface{})["test"].(map[string]interface{})["value"].(map[string]interface{})

	// get array of keys
	for k1 := range connectionStringOutputs {
		for k2, connectionString := range connectionStringOutputs[k1].(map[string]interface{})["connections"].(map[string]interface{}) {
			fmt.Println(k2, connectionString)
			_, err = ConnectToMongoDb(connectionString.(string))
		}
	}
	return "All connections passed", err
}

func ConnectToMongoDb(uri string) (string, error) {
	// var collection *mongo.Collection
	var ctx = context.TODO()

	clientOptions := options.Client().ApplyURI(uri)
	client, err := mongo.Connect(ctx, clientOptions)
	if err != nil {
		log.Fatal(err)
		return "failed", err
	}

	err = client.Ping(ctx, nil)
	if err != nil {
		log.Fatal(err)
		return "failed", err
	}
	return "succeeded", err
}
