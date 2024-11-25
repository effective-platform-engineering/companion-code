package cmd

import (
	"fmt"
	"log"
	"gopkg.in/yaml.v3"
	"encoding/json"
)

func clusterConfigToStdout(clusters []ClusterConfig, outputFormat string) {

	switch outputFormat {
		case "yaml":
			result, err := yaml.Marshal(clusters)
			if err != nil {
				log.Fatal(err)
			}
			fmt.Println(string(result))
		case "json":
			result, err := json.MarshalIndent(clusters, "", "  ")
			if err != nil {
				log.Fatal(err)
			}
			fmt.Println(string(result))

		default:
			exitOnError(fmt.Errorf("error: %s invalid option, only yaml and json output format supported", outputFormat))
	}
}

func exitOnError(err error) bool {
	if err != nil {
		log.Fatal(err)
	}
	return true
}