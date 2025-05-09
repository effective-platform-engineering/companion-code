"""action functions"""
# pylint: disable=import-error
import time
from auth0.exceptions import Auth0Error
from config import RETRIES
from payload import format_action_payloads

def create_auth0_action(auth0, custom_action):
    """create or patch action"""
    action_body, trigger_body = format_action_payloads(custom_action)
    existing = auth0.actions.get_actions()
    action_id = ""

    # patch if action already exists
    for act in existing['actions']:
        if act['name'] == custom_action:
            print(f"updating {custom_action}")
            action_id = act['id']
            patch_action(auth0, act['id'], action_body)

    # create if action does not exist
    if action_id == "":
        print(f"creating {custom_action}")
        action_id = post_action(auth0, action_body)

    bind_action_to_post_login_trigger(auth0, trigger_body)


def bind_action_to_post_login_trigger(auth0, trigger_body):
    """update trigger bindings"""
    try:
        _result = auth0.actions.update_trigger_bindings("post-login", trigger_body)
    except Auth0Error as err:
        print(err)

def patch_action(auth0, action_id, action_body):
    """update existing action"""
    try:
        _result = auth0.actions.update_action(action_id, action_body)
    except Auth0Error as err:
        print(err)
    set_deployed(auth0, action_id)

def post_action(auth0, action_body):
    """create new action"""
    try:
        result = auth0.actions.create_action(action_body)
    except Auth0Error as err:
        print(err)
    set_deployed(auth0, result['id'])
    return result['id']

def set_deployed(auth0, action_id):
    """set action as deployed"""
    # it takes a few seconds for new/updated action to become 'built'; deploy too soon results in 400
    for _x in range(RETRIES):
        try:
            result = auth0.actions.get_action(action_id)
        except Auth0Error as err:
            print(err)
        time.sleep(2)
        print(result['status'])
        if result['status'] == "built":
            break
    try:
        result = auth0.actions.deploy_action(action_id)
    except Auth0Error as err:
        print(f"Error: Increase retries; {err}")
