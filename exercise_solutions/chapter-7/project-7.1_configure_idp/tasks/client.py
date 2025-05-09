"""client functions"""
# pylint: disable=import-error
import json
from auth0.exceptions import Auth0Error
from payload import format_client_payload

def create_auth0_client(auth0, custom_client):
    """create or patch social connection"""
    client_body = format_client_payload(custom_client)
    existing = auth0.clients.all()
    client_id = ""
    client_credentials = {}

    # patch is already exists
    for client in existing:
        if client['name'] == custom_client:
            print(f"updating {custom_client}")
            client_id = client['client_id']
            patch_client(auth0, client_id, client_body)

    # post to create new
    if client_id == "":
        print(f"creating {custom_client}")
        result = post_client(auth0, client_body)
        # write resulting credentials to file that can be used to store in 1password
        client_id = result['client_id']
        client_credentials['client_id']=result['client_id']
        client_credentials['client_secret']=result['client_secret']
        with open(f"{custom_client}-client_credentials.json", "w", encoding='UTF-8') as outfile:
            outfile.write(json.dumps(client_credentials, indent=4))

    return client_id

def post_client(auth0, client_body):
    """create new application client"""
    try:
        result = auth0.clients.create(client_body)
    except Auth0Error as err:
        print(err)
    return result

def patch_client(auth0, client_id, client_body):
    """update existing client"""
    try:
        _result = auth0.clients.update(client_id, client_body)
    except Auth0Error as err:
        print(err)
