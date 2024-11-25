package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
)

var getCmd = &cobra.Command{
	Use:               "get",
	Short:             "Get vsctl configuration values",
	Long:              `Write vsctl configuration values to stdout`,
	DisableAutoGenTag: true,
	Args:              cobra.MatchAll(cobra.ExactArgs(1), cobra.OnlyValidArgs),
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Get command requires 1 valid argument")
	},
}

func init() {
	rootCmd.AddCommand(getCmd)
}
