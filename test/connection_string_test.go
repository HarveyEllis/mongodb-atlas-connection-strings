package test

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func TestConnectionStrings(t *testing.T) {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.

}


func CreateMongoDbCluster() {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../modules/mongodb_atlas_service_connections",
		VarFiles: []string{
			fmt.Sprintf("%v/example.tfvars", VarfileLocation()),
			fmt.Sprintf("%v/private.tfvars", VarfileLocation()),
		},
	})
}

func AttemptConnectionsToC
	byt, err := ioutil.ReadFile("live/mongo_user_test/terraform.tfstate")
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
			ConnectToMongoDb(connectionString.(string))
			// connectionStringOutputs[k1].(map[string]interface{})["connections"].(map[string]interface{})
		}
		// fmt.Println(connectionStringOutputs[k1])

	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../modules/mongodb_atlas_service_connections",
		VarFiles: []string{
			fmt.Sprintf("%v/example.tfvars", VarfileLocation()),
			fmt.Sprintf("%v/private.tfvars", VarfileLocation()),
		},
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	// defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables and check they have the expected values.
	output := terraform.Output(t, terraformOptions, "hello_world")
	assert.Equal(t, "Hello, World!", output)

}

var collection *mongo.Collection
var ctx = context.TODO()

func ConnectToMongoDb(url string) {
	clientOptions := options.Client().ApplyURI(url)
	client, err := mongo.Connect(ctx, clientOptions)
	if err != nil {
		log.Fatal(err)
	}

	err = client.Ping(ctx, nil)
	if err != nil {
		log.Fatal(err)
	}
}

func VarfileLocation() string {
	path, err := os.Getwd()
	if err != nil {
		log.Println(err)
	}
	varfile_location := fmt.Sprintf("%v/live/mongo_user_test", path)
	fmt.Println("Varfile location is: ", varfile_location)

	return varfile_location
}

type ClusterValue struct {
	Cluster string `json:"cluster"`
}

type SomeDataStore struct {
	Name interface{} `json:"data"`
	// `json:"marsupial-data-store_animals-mongo_marsupials-prod"`
}

type OutputValue struct {
	Value SomeDataStore `json:"value"`
}

type TerraformState struct {
	Outputs OutputValue `json:"outputs"`
}

// type TerraformState struct {
// 	Outputs TerraformOutputs
// }

// type TerraformOutputs struct {
// 	Value ClusterValue `json:"value"`
// }

// type ClusterValue struct {
// 	cluster string
// }
