package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var output string

var listCmd = &cobra.Command{
	Use:    "list",
	Short:  "List resources",
	Long:   `List resources of the specified resource type. For example: list clusters`,
	DisableAutoGenTag: true,
	Args:    cobra.MatchAll(cobra.ExactArgs(1), cobra.OnlyValidArgs),
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("list command requires 1 valid resource parameter")
	},
}

func init() {
	rootCmd.AddCommand(listCmd)
	clustersCmd.Flags().StringVarP(&output, "output", "o", "", "output format for full details")
}


var clustersCmd = &cobra.Command{
	Use:     "clusters",
	Aliases: []string{"cluster"},
	Short:   "List available clusters",
	Long: `List available clusters`,
	Run: func(cmd *cobra.Command, args []string) {
		if output != "" {
			clusterConfigToStdout(clustersList, output)
		} else {
			for _, clusters := range clustersList {
				if !clusters.Hidden || viper.Get("DefaultShowHidden") == "true" {
					fmt.Println(clusters.ClusterName)
				}
			}
		}
	},
}

func init() {
	listCmd.AddCommand(clustersCmd)
}