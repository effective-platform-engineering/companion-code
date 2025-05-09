package clients

import (
  "encoding/json"
	"io"
	"fmt"
	"github.com/epetech/epectl/clients/models"
	"net/http"
	"log"
	"strings"
	"time"

	"github.com/spf13/viper"
	"github.com/tidwall/gjson"
)

func RequestDeviceCode() models.DeviceCode {
	deviceCodeUrl := viper.GetString("IdpIssuerUrl") + "oauth/device/code"
	payload := strings.NewReader(fmt.Sprintf("client_id=%s&scope=%s&audience=%s",
		viper.Get("LoginClientId").(string),
		viper.Get("LoginScope").(string),
		viper.Get("LoginAudience").(string)),
	)

	body, statusCode := submitPostRequest(deviceCodeUrl, payload)
	if statusCode != http.StatusOK {
		log.Fatalf("Status: %d\n%s: %s\n", statusCode, gjson.Get(string(body), "error"), gjson.Get(string(body), "error_description"))
	}

	var deviceCode models.DeviceCode
	json.Unmarshal(body, &deviceCode) //nolint:errcheck

	return deviceCode
}

func Authenticate(deviceCode models.DeviceCode) {

	for {
		body, statusCode := poll(deviceCode.DeviceCode)

		if statusCode == "200 OK" {
			fmt.Println("authentication successful")

			var authorizationResponse models.AuthorizationResponse
			json.Unmarshal(body, &authorizationResponse) //nolint:errcheck

			viper.Set("AccessToken", authorizationResponse.AccessToken)
			viper.Set("RefreshToken", authorizationResponse.RefreshToken)
			viper.Set("IdToken", authorizationResponse.IdToken)
			viper.Set("ExpiresIn", authorizationResponse.ExpiresIn)
			viper.WriteConfig() //nolint:errcheck

			return
		} else {
			var authorizationPollResponse models.AuthorizationPollResponse
			json.Unmarshal(body, &authorizationPollResponse) //nolint:errcheck

			switch authorizationPollResponse.Error {
      case "authorization_pending":
        fmt.Println("waiting...")
        time.Sleep(time.Duration(deviceCode.Interval) * time.Second)
      case "expired_token":
        log.Fatal(authorizationPollResponse.ErrorDescription)
      case "access_denied":
        log.Fatal(authorizationPollResponse.ErrorDescription)
      default:
        log.Fatal(authorizationPollResponse.ErrorDescription)
      }
		}
	}
}

func poll(deviceCode string) ([]byte, string) {
	authenticationUrl := viper.GetString("IdpIssuerUrl") + "oauth/token"
	payload := strings.NewReader(fmt.Sprintf("client_id=%s&grant_type=urn:ietf:params:oauth:grant-type:device_code&device_code=%s",
		viper.Get("LoginClientId").(string),
		deviceCode))

	req, _ := http.NewRequest("POST", authenticationUrl, payload)
	req.Header.Add("content-type", "application/x-www-form-urlencoded")
	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close() //nolint:govet

	body, _ := io.ReadAll(res.Body)
	return body, res.Status
}

func submitPostRequest(url string, payload *strings.Reader) ([]byte, int) {
	req, _ := http.NewRequest("POST", url, payload)
	req.Header.Add("content-type", "application/x-www-form-urlencoded")
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Fatal(err)
	}
	defer res.Body.Close()

	body, _ := io.ReadAll(res.Body)
	return body, res.StatusCode
}
