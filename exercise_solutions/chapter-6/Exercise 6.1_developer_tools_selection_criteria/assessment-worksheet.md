# Example: Software Selection Criteria Assessment

Tool: [Buildkite](https://buildkite.com)  
Category: Pipeline Orchestration

## General Software Selection Criteria
1. [X] Prefer smaller, focused tools that are exceptional in their implementation and interoperate well over monolithic solutions that do many things, often poorly.  

2. [X] Use strongly domain-bounded tools and frameworks, implemented with replacement in mind. You want to preserve the possibility of a low-friction change to a higher-value alternative should it become available.  

Discussion: Buildkite does offer additional capabilities beyond pipelines, namely test analytics and artifact store. The pipeline capability does not require use of the other capabilities.  

3. [X] Prefer solutions offered by qualified SaaS providers over self-managed, performing realistic assessments of the total cost of ownership. Always qualify a SaaS tool with actual POC implementations and security assessments.  

Discussion: Founded 2013 in Melbourne, Aus. Industry security on SaaS hosted data. Pipeline execution has historically been 100% private-hosted runners (user retains fuill security control over actual pipeline jobs), though vendor hosted runners is in private Trials. 1000+ customers including notables. [Market info](https://www.prnewswire.com/news-releases/buildkite-raises-21-million-to-invent-the-future-of-devops-301677746.html).  

4. [X] Use or implement software that has an API.  

[Documentation](https://buildkite.com/docs/apis). REST and GraphQL.  

5. [X] The API should be easy to use, and the related documentation should include functional examples.  

Discussion: functional examples are Curl only. Provides explorer for GraphQL interface.  

6. [-] The API should provide access to all application functionality, including the generation and rotation of internal secrets or certificates if used.  

Discussion: Certain capabilities are limited to Enterprise plan.  

7. [X] The API should not require the use of a specific programming language.  

8. [-] Coding around deficiencies in the product should be easier than recreating the product.  

Discussion: For platform capability purposes, team management appears sufficient. Options/examples exist for providing dynamic, ephmeral runners. Initial identified list of things that may require custom automation is short and doable at modest investment.  

9. [X] All data stored in the product should be readable and writable by other applications.  

Discussion: In testing don't see particular examples of unavailable data.  

10. [X] Products with authentication requirements should be able to authenticate and authorize users from external, configurable sources using frameworks appropriate for public networks. In particular, assess whether the tool can be configured to align with the platform’s team-oriented RBAC goals of enabling complete self-serve user experiences.  

Discussion. SAML available. Also, good GitHub Teams integration (if using that for customer rbac experience).  

11. [-] Place a high value on the depth of community involvement and support.  

Discussion: Moderate. Several searches indicate depth of community is proportionate to general market penetration. 

12. [X] Where the software is self-managed, do not buy software that requires bare metal or cannot be installed and maintained through software-defined practices.


Tool Specific Capabilities:  

1. [-] Secure mechanism for storing per-team and per-pipeline environment values. Note. This capability is both essential and to be used quite sparingly as will be discussed later.  

Discussion. Historically assumes you will self-manage this issue and doesn't provide a generalized means, though this is now a new feature in Preview. With private-hosted runners this is not difficult to do, though this is a self-managed automation.  

1. [X] Ephemeral, on-demand runners. Idle runners create waste. Runners should be provisioned rapidly as needed and live only for the life of the pipeline job or workflow.  

2. [X] Self-hosted runners. While vendor hosted runners are more cost effective there are many situations where self-hosted runners will be a necessity.  

3. [X] Fully software defined pipelines.  

4. [X] Support for reusable, versioned pipeline code steps.  

5. [-] Secure options for caching artifacts and data between ephemeral jobs.  

Discussion: For private-hosted runners this is not difficult to provide, though it is self-managed. Not clear if this will be part of the vendor hosted runners.  

Not essential but highly valuable:  

7. [ ] Secure runtime runner access for debugging.  

Discussion. Not currently part of Agent features, though in private-hosted setting can be implemented (self-managed automation).  

8. [ ] No or highly limited means of pipeline creation or maintenance via a GUI.  

Discussion: Though it is not the recommended method, it is possible to define a broad category of pipeline capabilities through the UI by entering the YAML structure directly. Not quite _highly limited_. It is possible to create  automation to scan for and discourage the behavior.  
