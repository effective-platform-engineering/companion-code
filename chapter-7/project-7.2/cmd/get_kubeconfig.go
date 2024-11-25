package cmd

import (
	"fmt"
	"encoding/base64"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"k8s.io/client-go/tools/clientcmd/api"
	"k8s.io/client-go/tools/clientcmd"
)

var cluster string

var kubeconfigCmd = &cobra.Command{
	Use:               "kubeconfig",
	Short:             "Get kubeconfig",
	Long:              `Write kubeconfig file to stdout`,
	DisableAutoGenTag: true,
	Args:              cobra.MaximumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		if cluster == "" {cluster = viper.GetString("DefaultCluster")}

		kubeconfig := generateKubeConfig(cluster)
		fmt.Println(kubeconfig)
	},
}

func init() {
	getCmd.AddCommand(kubeconfigCmd)
	kubeconfigCmd.Flags().StringVarP(&cluster, "cluster", "c", "", "Generate a kubeconfig file for the given cluster")
}

func generateKubeConfig(cluster string) string {
	clusterEndpoint, base64CertificateAuthorityData := clusterValues(cluster)
	decodedCaCert, err := base64.StdEncoding.DecodeString(base64CertificateAuthorityData)
	exitOnError(err)
	user := "oidc-user@" + cluster

	config := api.NewConfig()
	config.CurrentContext = cluster
	
	config.Clusters[cluster] = &api.Cluster{
		Server:                   clusterEndpoint,
		InsecureSkipTLSVerify:    false,
		CertificateAuthorityData: decodedCaCert,
	}

	config.Contexts[cluster] = &api.Context{
		Cluster:  cluster,
		AuthInfo: user,
	}

	config.AuthInfos[user] = &api.AuthInfo{
		AuthProvider: &api.AuthProviderConfig{
			Name: "oidc",
			Config: map[string]string{
				"access-token":  viper.GetString("AccessToken"),
				"client-id":      viper.GetString("LoginClientId"),
				"id-token":  viper.GetString("IdToken"),
				"idp-issuer-url": viper.GetString("IdpIssuerUrl"),
				"refresh-token":  viper.GetString("RefreshToken"),
			},
		},
	}

	kubeconfig, err := clientcmd.Write(*config)
	exitOnError(err)

	return string(kubeconfig[:])
}

func clusterValues(cluster string) (string, string) {
	for _, c := range clustersList {
		if c.ClusterName == cluster {
			return c.ClusterEndpoint, c.Base64CertificateAuthorityData
		}
	}
	fmt.Println("Error: specified cluster not found")
	return "", ""
}