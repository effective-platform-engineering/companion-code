***Exercise 5.3: Case Study: Evaluate the TCO of continuing to support your observability system locally***

| *In this exercise, we will revisit a specific case study related to PETech. The goal of this exercise is for you to make appropriate decisions concerning build vs. buy decisions. Your task is to pick the correct option. You are expected to write a short justification for your option of choice. 

Option \# 1: In this option, the platform engineering team at PETech decides to build a custom observability platform as they came to the conclusion that there are a lot of custom requirements that they could not find in an COTS solution. It involved using open-source tools such as Grafana LGTM, and Prometheus among others. They collected the requirements and decided to build an MVP to get quick feedback. Based on the user feedback, they invested in two full-time developers and a technical product manager to work on the observability platform. Their tasks included the whole lifecycle \- define the product features working with the engineering team, building, testing and deploying the products in a continuous manner and ensuring adoption of this platform for all the stakeholders within the organization Option 

\#2: In the second option, PETech decides to buy a third-party SaaS observability platform from Chronosphere with fluentd. This platform came with built-in scalability, cloud-native application integration, comprehensive features for about 80% of what PETech engineers needed. The benefit the platform engineering team found was that they did not need a separate team to maintain this and was able to democratize the decision making. Moreover, they were able to goto market (have all of 80% of the requirements fulfilled) within a span of 2 weeks. They did so by investing in 6 sprints of work for three developers to integrate and rollout Chronosphere with the help of the vendor recommended, third party experts. 

Which option would you pick? Why?

## ***Solution***
If we evaluate the options using the TCO, in most cases the answer will be **option 2**.

This can be justified by using a breakdown of what it will cost the company to support the chosen observability platform  across all the factors we talked about in the chapter.  We need to make some assumptions here on costs, but even with very average numbers you can see that the costs do not balance.

### Option 1: Custom stack
Assumptions:

Salaries
  - Technical Product Manager Salary (with benefits): 200K/year
  - Developer Salary (with Benefits): 250K/year (x2)

Cloud Hosting
  - Kubernetes Cluster: 10k/month = 120k/year
  - Storage for logs, metrics and traces: 10k/month - 120k/year
  - Network, Communication, Security Infrastructure: 5k/month = 60k/year

Timelines:
  - Time to MVP: 2 months
  - Cycle time for new features: 4 weeks

Adoption Roadmap
  - 1 Key team at MVP
  - Gradual onboarding with expectation for full adoption around 1 year depending on feature and support availability

SLOs
  - 98% uptime (could be a stretch without additional ops support)
  - New software version availability: Within 6 months of release

This means that option 1 provides the following in year 1

- Cost: 750K
- Time to full adoption: 1 year 
- Availability: 98%
- Latest OSS package Features: Within 6 months of release
- 10-12 custom feature releases per year

### Option 2: SaaS Platform
Assumptions:

License cost: 
- Priced based on data retention.  
- Estimates show a license cost of $500K per year (support included)

Timelines:
- Configured and available for full company-wide adoption in 2 months
- New features released as available (often weekly)

SLAs:
- 99.99% Uptime or a bill credit is issued

This means that option 2 provides the following in year 1:

- Cost: 500K
- Time to full adoption: 2 months 
- Availability 99.99%
- Feature releases: Weekly

### Comparison
While these numbers are ficticious, in our experience the general pattern will be shown to play out the same way in a real situation and often be more lopsided.  Here we can see the following:

- Cost: Option 2 is 200k/year cheaper
- Time to value: Option 2 provides adoption across the company in 1/6th of the time.  This means that implementation costs havbe to be absorbed by the company without any benefit for much less time
- Availability: The SaaS option is guaranteed to be available over a week more per year, plus a monetary reimbursement will be received in the event of the guarantee being exceeded.

Last is the value of developer experience in getting features that make the observability platform more useful on a regular basis which will enhance adoption.  Without this, costs related to outages as a lack of observability available, or even teams acquiring their own tools will need to be accounted for!