package cmd

import (
	"fmt"
	"os"
	homedir "github.com/mitchellh/go-homedir"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var cfgFile string
var Version = "snapshot"

var rootCmd = &cobra.Command{
	Use:   "epectl",
	Short: "epetech engineering platform control plane cli",
	Long:  `cli for use with example engineering platform.`,
  Run: func(cmd *cobra.Command, args []string) {
		exitOnError(cmd.Help())
  },
}

func Execute() {
  exitOnError(rootCmd.Execute())
}

func init() {
	cobra.OnInitialize(initConfig)

	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", ConfigFileDefaultLocationMsg)
}

// initConfig sets the config values based on the following order of precedent:
// ENV variables
// Config file definitions
// Default values from settings.go

func initConfig() {

	viper.SetDefault("LoginClientID", LoginClientId)
	viper.SetDefault("LoginScope", LoginScope)
	viper.SetDefault("LoginAudience", LoginAudience)
	viper.SetDefault("IdpIssuerUrl", IdpIssuerUrl)

	viper.SetDefault("DefaultShowHidden", DefaultShowHidden)
	viper.SetDefault("DefaultCluster", DefaultCluster)

	viper.SetEnvPrefix(ConfigEnvDefault)
	
	if cfgFile != "" {
		// Use config file from the flag if specified.
		viper.SetConfigFile(cfgFile)
	} else {
		viper.AddConfigPath(defaultConfigLocation())
		viper.SetConfigName(ConfigFileDefaultName)
	}

	// If a config file is found, read it in, else write a blank.
	if err := viper.ReadInConfig(); err != nil {
    configFileLocation := defaultConfigLocation()
		configFilePath := configFileLocation + "/" + ConfigFileDefaultName + "." + ConfigFileDefaultType

		exitOnError(os.MkdirAll(configFileLocation, 0700))
		fmt.Println("created " + configFilePath)
		emptyFile, err := os.Create(configFilePath) // #nosec G304
		exitOnError(err)
		emptyFile.Close() // #nosec G104
	}
	viper.WriteConfig() //nolint:errcheck
	viper.AutomaticEnv()
}

func defaultConfigLocation() string {
	home, err := homedir.Dir()
	exitOnError(err)
	return home + ConfigFileDefaultLocation
}
