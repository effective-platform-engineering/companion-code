## ***Exercise 2.4: Model a feature request***
Let’s say a stakeholder comes and says, “My team wants a browser interface for integrating new git repositories with platform features. On our team, it is usually the analyst or the scrum master that creates a new repository since we try to take care of as many things as possible for developers to save them time. These folks aren’t as comfortable with the CLI you provided, and it causes stress and slows them down.” Our Epetech platform team internally debates the idea. Using the CLI requires the user to install and maintain a sufficiently recent version of the tool on their laptop, ensuring it is in their terminal path. Integrating a repo requires the user to authenticate using the cli and then run the repo integration command as follows.

$> <tool name> login
Your browser window will open (or click here) to complete the login

$> <tool name> create repo <repo name>

Behind the scenes, the tool calls a custom platform API that will first check to see if the repo already exists for the team and if not will create it. Then, the API will add the repo to its internal reconciliation loop and maintain the integration between the repo and the software pipeline tool, along with a handful of other automated tasks provided by the platform to improve git-related user experiences.

How might we model and qualify this feature request following our incremental change process? 

As a user of the epetech engineering platform, I need a Browser-based Interface to create and integrate new github repositories with the platform automation.
What would we need to know to quantify the value of this feature? How could we obtain the information? How could we continue tracking the value over time if we implement the feature?

When you’re done with the exercise, here are some additional things to consider.

Over time, it costs more to operate software than to create it. That’s not a bad thing by itself. It is also when it is being used that software generates value. But this should alter how we think about features in software that are not used (or rarely used), especially internal software systems like an engineering platform. What if, in researching a capability such as described in exercise 2.4, we discover that the average team creates 12 new repos per year? Except for the team that made the request, the developers create the repos and spend barely 1 to 2 minutes doing it. If a GUI were made available, most developers would not use it, and anyone using the GUI would take more than 10 minutes to complete the same task. The team that requested it is expending several hours per year to save their developers just a few minutes. If that were the actual situation, we would lose money implementing such a feature.
Of course, it would be better to successfully figure this out before expending the time to implement a feature. But that isn’t always possible. Sometimes, all the data suggests a feature is worth shipping, and only afterward do we discover that it will not generate the value we expected. It is better to remove the feature than incur the ongoing sustainment costs.

On the other hand, what if our investigation revealed that a 10-minute GUI experience would save 40 hours of time per quarter per team and we have a hundred teams using our platform? Implementing the feature would add back the equivalent of two full-time developers’ time.  

If we were to build this GUI for our users, what sort of data do we need to think about in our Define stage? We’ll want to ensure they have an excellent overall experience, including latency, low error percentages, and fast page load times. But more important than that will be confirming the time savings. Our GUI should provide the tracking data to confirm the adoption rate and penetration. If users aren’t adopting, we will need to figure out why. We will also need a few follow-up surveys to track the impact.

**Solution**

This request is targeted at reducing the amount of time it takes folks other than the developer members of a development team to create or add a new github repo to our platform automation.
Here is the kind of information we could use to model and assess the impact. You may think of additional ways to measure.
How many new repositories are created and integrated with the platform on a weekly, monthly, and annual basis?
What is the breakdown by role and team of the people who perform this task across all platform customers?
By role and team, how long on average does it take a person to perform this task?
How could I create an experiment to calculate how long it would take on average to perform the same task via a browser interface?
Assuming we think the above data would be sufficient to calculate an average time savings, how would we gather this info?
The first two we could pull from our API logs, with potential some change needed if the logs don’t currently collect all the info.
The third bullet isn’t something we can track in automation. Maybe we could extrapolate some data based on the time between when a person hits a specific page in the platform documentation about integrating repos and subsequently triggers the API call, but how often would that even reflect the way people really went about the task? Surveying the platform users is probably the only option. 

Question 1 : Do you create and integrate Git repositories with the Engineering Platform?
Yes
Rarely, I have but not normally part of my job
No
What is Git?
If you answered 1 or 2 respond to the rest of the questions, if not then youre done! ;)
Question 2 : Which answer best describes how long it typically takes you to create and integrate a Git repositories with the Engineering Platform?
Just a couple of minutes
10 to 15 minutes
More than a half-hour
Couple of hours
It’s the only thing I accomplish for the day
Question 3 : In your day-to-day role, do you:
Routinely use git and other CLIs and prefer such tools
Use CLIs and UIs, but don’t have a preference one way or another
Use CLIs but prefer a browser or app option if available
Question 4 : What is your role on the team? ___________________________________________
We could send this out as a simple Slackbot 2-part question, making it as easy for people to answer it and return to their jobs. We don’t want to inundate our users with lengthy or wordy surveys; it’s best to model these new capabilities with questions that are most likely to get as many responses as possible. Keeping it short ensures we’ll at least get a majority (50% or higher) response rate.
Our results come in, and we get:
50 overall responses
Table 2.1 Shows the responses to the two questions that were posed above


Q1
Q2
Responses
35 CLIs, 30 APIs, 25 GUIs
10 All of the Above, 5 other
30 CLIs, 20 GUIs

Surprisingly, there are more users than we expected who want to use a GUI to deploy to the platform! Had we just used our assumptions and not modeled and validated them, we never would have developed this feature, leaving 40% of our users using a set of features they would prefer to do in a different interface.
