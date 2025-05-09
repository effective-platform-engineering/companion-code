{
  "name": "set-claims-as-github-teams",
  "supported_triggers": [
    {
      "id": "post-login",
      "version": "v3"
    }
  ],
  "code": "$ACTION_CODE",
  "dependencies": [
    {
      "name": "axios",
      "version": "1.4.0"
    },
    {
        "name": "auth0",
        "version": "3.6.0"
    }
  ],
  "runtime": "node18-actions",
  "secrets": [
    {
      "name": "MANAGEMENT_API_CLIENT_ID",
      "value": "$MANAGEMENT_API_CLIENT_ID"
    },
    {
      "name": "MANAGEMENT_API_CLIENT_SECRET",
      "value": "$MANAGEMENT_API_CLIENT_SECRET"
    }
  ]
}