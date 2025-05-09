"""create and update commands"""
# pylint: disable=import-error
from auth0.exceptions import Auth0Error
from payload import format_connection_payload

def create_auth0_connection(auth0, custom_connection, client_ids):
    """create or patch social connection"""
    connection_body = format_connection_payload(custom_connection)
    connection_body['enabled_clients'] = client_ids
    existing = auth0.connections.all()
    connection_id = ""

    # patch if already exists
    for connection in existing:
        if connection['name'] == custom_connection:
            print(f"updating {custom_connection}")
            connection_id = connection['id']
            patch_connection(auth0, connection_id, connection_body)

    # post to create new
    if connection_id == "":
        print(f"creating {custom_connection}")
        connection_body['name'] = custom_connection
        connection_body['strategy'] = custom_connection
        _result = post_connection(auth0, connection_body)

def patch_connection(auth0, connection_id, connection_body):
    """update existing connection"""
    try:
        _result = auth0.connections.update(connection_id, connection_body)
    except Auth0Error as err:
        print(err)

def post_connection(auth0, connection_body):
    """create new connection"""
    try:
        result = auth0.connections.create(connection_body)
    except Auth0Error as err:
        print(err)
    return result
