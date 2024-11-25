package cmd

type ClusterConfig struct {
	ClusterName 										string `yaml:"clusterName" json:"clusterName"`
	Hidden 													bool   `yaml:"hidden" json:"hidden"`
	ClusterEndpoint 								string `yaml:"clusterEndpoint" json:"clusterEndpoint"`
	Base64CertificateAuthorityData  string `yaml:"base64CertificateAuthorityData" json:"base64CertificateAuthorityData"`
	EfsCSIStorageID                 string `yaml:"efsCSIStorageID" json:"efsCSIStorageID"`
}

var ( 
	clustersList = []ClusterConfig{ 
		{
			ClusterName: "sbx-i01-aws-us-east-1",
			Hidden: true,
			ClusterEndpoint: "{{ op://my-vault/sbx-i01-aws-us-east-1/cluster-url }}",  
			Base64CertificateAuthorityData: "{{ op://my-vault/sbx-i01-aws-us-east-1/base64-certificate-authority-data }}",
			EfsCSIStorageID: "{{ op://my-vault/sbx-i01-aws-us-east-1/eks-efs-csi-storage-id }}",
		},
		{
			ClusterName: "prod-i01-aws-us-east-2",
			Hidden: false,
			ClusterEndpoint: "{{ op://my-vault/prod-i01-aws-us-east-2/cluster-url }}",
			Base64CertificateAuthorityData: "{{ op://my-vault/prod-i01-aws-us-east-2/base64-certificate-authority-data }}",
			EfsCSIStorageID: "{{ op://my-vault/prod-i01-aws-us-east-2/eks-efs-csi-storage-id }}",
		},
	}
)

const (
	LoginClientId = "{{ op://my-vault/svc-auth0/vsctl-cli-client-id }}"
	LoginScope    = "openid offline_access profile email"
	LoginAudience = "https://vsctl.us.auth0.com/api/v2/"
	IdpIssuerUrl  = "https://vsctl.us.auth0.com/"

	DefaultShowHidden = false
	DefaultCluster    = "prod-i01-aws-us-east-2"

	ConfigEnvDefault             = "VSCTL"
	ConfigFileDefaultName        = "config"
	ConfigFileDefaultType        = "yaml"
	ConfigFileDefaultLocation    = "/.vsctl" // path will begin with $HOME dir
	ConfigFileDefaultLocationMsg = "config file (default is $HOME/.vsctl/config.yaml)"
)
