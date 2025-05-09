/**
* Handler that will be called during the execution of a PostLogin flow.
*
* @param {Event} event - Details about the user and the context in which they are logging in.
* @param {PostLoginAPI} api - Interface whose methods can be used to change the behavior of the login.
*/
exports.onExecutePostLogin = async (event, api) => {
  const requiredOrganization = 'epetech'; //remove this line

  // get users social_connection access token
  const { ManagementClient } = require('auth0');
  const management = new ManagementClient({
    domain: '$DOMAIN',
    clientId: event.secrets.MANAGEMENT_API_CLIENT_ID,
    clientSecret: event.secrets.MANAGEMENT_API_CLIENT_SECRET,
    scope: 'read:users'
  });
  const social_metadata = await management.getUser({ id: event.user.user_id });
  var github = social_metadata.identities.filter(function (id){
                 return id.provider === 'github';
               })[0];
  var access_token = github.access_token;

  // fetch the user's GitHub team memberships
  const axios = require("axios");
  const githubAPIUrl = 'https://api.github.com/user/teams';
  const options = {
    headers: {
      'Authorization': `token ${access_token}`,
      'User-Agent': '$TENANT'
    }
  };

  try {
    var response = await axios.get(githubAPIUrl, options);

    var github_teams = response.data.map(function(team) {
      return team.organization.login + "/" + team.slug;
    });

    // Check if the user is part of the required organization - remove this check
    const isInOrganization = response.data.some(team => team.organization.login === requiredOrganization);

    if (!isInOrganization) {
      return api.access.deny(`User is not a member of the required GitHub organization: ${requiredOrganization}`);
    }

    // add teams list as claims to jwt
    if (event.authorization) {
      api.idToken.setCustomClaim("https://github.org/epetech/teams", github_teams);
      api.idToken.setCustomClaim("cli", "$TENANT");
    }

  } catch (error) {
    // add the error message to the custom claims
    console.error('Error fetching GitHub team memberships:', error.message);
    if (event.authorization) {
      api.idToken.setCustomClaim("github_teams_error", error.message);
    }
  }

};