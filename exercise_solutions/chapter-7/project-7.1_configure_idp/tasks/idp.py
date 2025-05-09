"""entrypoint for auth0 cli tenant configuration"""
# pylint: disable=import-error,unused-argument
from invoke import task
from auth0.management import Auth0
from config import DOMAIN, TENANT, BASIC_AUTH
from authentication import get_admin_access_token
from client import create_auth0_client
from connection import create_auth0_connection
from action import create_auth0_action

@task
def install(ctx):
    """install all epetech auth0 customizations"""
    auth0 = Auth0(DOMAIN, get_admin_access_token())
    client_id = create_auth0_client(auth0, TENANT)
    basic_client_id = create_auth0_client(auth0, BASIC_AUTH)
    create_auth0_connection(auth0, "github", [client_id, basic_client_id])
    create_auth0_action(auth0, "set-claims-as-github-teams")

@task
def install_client(ctx):
    """install only epetechctl application client"""
    auth0 = Auth0(DOMAIN, get_admin_access_token())
    client_id = create_auth0_client(auth0, TENANT)
    print(client_id)

@task
def install_connection(ctx, client_id):
    """install only github social connection"""
    auth0 = Auth0(DOMAIN, get_admin_access_token())
    create_auth0_connection(auth0, "github", client_id)

@task
def install_action(ctx):
    """install only action and trigger"""
    auth0 = Auth0(DOMAIN, get_admin_access_token())
    create_auth0_action(auth0, "set-claims-as-github-teams")
