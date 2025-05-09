"""prepare json body for auth0 api calls"""
# pylint: disable=unused-argument,redefined-outer-name
import os
import json
from invoke import task

@task
def action(ctx):
    """print action and trigger binding api call json body to stdout"""
    action_body, trigger_body = format_action_payloads("set-claims-as-github-teams")
    print(f"'actions: '{action_body}, 'trigger: '{trigger_body}")

@task
def client(ctx):
    """print application client api call json body to stdout"""
    body = format_client_payload("epectl")
    print(body)

@task
def connection(ctx):
    """print connection api call json body to stdout"""
    body = format_connection_payload("github")
    print(body)

# ========================================================== client payload
def format_client_payload(client):
    """create or update application client"""
    template_file = f"request-body/{client}-client.json"

    with open(template_file, "r", encoding='UTF-8') as template:
        template_content = template.read()

    return json.loads(template_content)

# ========================================================== connection payload
def format_connection_payload(connection):
    """create custom connection api json body"""
    template_file = f"request-body/{connection}-social-connection.json.tpl"
    output_file = f"request-body/{connection}-social-connection.json"

    with open(template_file, "r", encoding='UTF-8') as template:
        template_content = template.read()

    # basically envsubst the listed entries
    github_client_id = os.environ.get("GITHUB_OAUTH_CLIENT_ID", "")
    github_client_secret = os.environ.get("GITHUB_OAUTH_CLIENT_SECRET", "")
    substituted_content = template_content.replace("$GITHUB_OAUTH_CLIENT_ID", github_client_id)
    substituted_content = substituted_content.replace("$GITHUB_OAUTH_CLIENT_SECRET", github_client_secret)

    # write the action trigger-binding json body
    with open(output_file, "w", encoding='UTF-8') as output:
        output.write(substituted_content)

    return json.loads(substituted_content)

# ========================================================== action payloads
def format_action_payloads(custom_action):
    """create custom_action.js and api json body files to create and bind aut0action with trigger"""
    action_body = action_api_json_body(custom_action)
    trigger_body = action_trigger_api_json_body(custom_action)

    return json.loads(action_body), json.loads(trigger_body)

def action_trigger_api_json_body(custom_action):
    """update action trigger integration"""
    # substitute action name request-body for trigger binding creation, and write result
    template_file = f"request-body/{custom_action}-trigger-binding.json.tpl"
    output_file = f"request-body/{custom_action}-trigger-binding.json"

    with open(template_file, "r", encoding='UTF-8') as template:
        template_content = template.read()

    # basically envsubst the listed entries
    substituted_content = template_content.replace("$ACTION", custom_action)

    # write the action trigger-binding json body
    with open(output_file, "w", encoding='UTF-8') as output:
        output.write(substituted_content)

    return substituted_content

def action_api_json_body(custom_action):
    """insert action string into json-body for api call"""

    action_string = package_action_js_for_json_body(custom_action)

    # substitute ENV values into request-body for action creation, and write result
    template_file = f"request-body/{custom_action}.json.tpl"
    output_file = f"request-body/{custom_action}.json"

    with open(template_file, "r", encoding='UTF-8') as template:
        template_content = template.read()

    # basically envsubst the listed entries
    api_client_id = os.environ.get("MANAGEMENT_API_CLIENT_ID", "")
    api_client_secret = os.environ.get("MANAGEMENT_API_CLIENT_SECRET", "")
    substituted_content = template_content.replace("$ACTION_CODE", action_string)
    substituted_content = substituted_content.replace("$MANAGEMENT_API_CLIENT_ID", api_client_id)
    substituted_content = substituted_content.replace("$MANAGEMENT_API_CLIENT_SECRET", api_client_secret)

    # write the post/patch action json body
    with open(output_file, "w", encoding='UTF-8') as output:
        output.write(substituted_content)

    return substituted_content

def package_action_js_for_json_body(custom_action):
    """Minimal templating required for nodejs script pulling values from ENV, dev or prod releases"""
    # Create custom_action.js
    # substitute current domain name in action code (dev or not dev), and write result
    template_file = f"actions/{custom_action}.js.tpl"
    output_file = f"actions/{custom_action}.js"

    with open(template_file, "r", encoding='UTF-8') as template:
        template_content = template.read()

    # basically envsubst the listed entries
    substituted_content = template_content.replace("$DOMAIN", os.environ.get("DOMAIN", ""))
    substituted_content = substituted_content.replace("$TENANT", os.environ.get("TENANT", ""))

    # write the custom_action.js
    with open(output_file, "w", encoding='UTF-8') as output:
        output.write(substituted_content)

    # create json body for port/patch action api call
    # package the action js file as a string to include in API call to create/patch action
    output_string = ""
    with open(output_file, "r", encoding='UTF-8') as file:
        for line in file:
            # escape quotes and replace carriage returns with \n
            line = line.replace('"', '\\"').rstrip() + "\\n"
            output_string += line

    return output_string
