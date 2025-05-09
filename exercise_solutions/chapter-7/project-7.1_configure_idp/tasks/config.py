"""global values for configure_auth0 scripts"""
import os

DOMAIN = os.environ.get('DOMAIN')
TENANT = os.environ.get('TENANT')
BASIC_AUTH = os.environ.get('BASIC_AUTH')
MANAGEMENT_API_CLIENT_ID = os.environ.get('MANAGEMENT_API_CLIENT_ID')
MANAGEMENT_API_CLIENT_SECRET = os.environ.get('MANAGEMENT_API_CLIENT_SECRET')
MANAGEMENT_API_URL = f"https://{DOMAIN}/api/v2/"
RETRIES = 10
