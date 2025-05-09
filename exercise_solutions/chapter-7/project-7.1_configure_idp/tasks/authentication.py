"""auth0 sdk authentication"""
# pylint: disable=import-error
from auth0.authentication import GetToken
from config import DOMAIN, MANAGEMENT_API_CLIENT_ID, MANAGEMENT_API_CLIENT_SECRET, MANAGEMENT_API_URL
import requests

def get_admin_access_token():
    """fetch Auth0 domain management api token"""
    access_token = ""
    try:
        token_base = GetToken(DOMAIN, MANAGEMENT_API_CLIENT_ID, MANAGEMENT_API_CLIENT_SECRET)
        token = token_base.client_credentials(MANAGEMENT_API_URL)
        access_token=token['access_token']
    except requests.exceptions.RequestException as err:
        print(f"Error aquiring Management API access token: {err}")

    return access_token
