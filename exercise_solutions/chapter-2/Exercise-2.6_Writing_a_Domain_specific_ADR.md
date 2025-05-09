## ***Exercise 2.6: Writing a Domain-specific ADR***

Suppose the security team at Epetech establishes a new requirement that all the custom software we deploy must provide an associated software bill of materials. For the first year, developers can comply with the policy by providing materials information covering the contents of the software at the time of release, leaving information about the build process and responsible parties for a later stage.  

Using what we learned so far, write a top-level ADR describing the primary components of automation that could achieve this outcome. Keep in mind the domain boundaries that will enable the platform engineers, developers, and stakeholders to get to this outcome without introducing breaking product changes.

### **Architectural structure for the Software Bill of Materials capabilities of the Epetech Engineering platform**

Required outcome:  

1. Custom software running on the Epetech engineering platform must have an associated bill of materials that documents all external or 3rd party libraries, data, or any other content not the result of Epetech custom software creation. This list of resources must include any known vulernabilities at the time of release. This SBOM policy is not a statement of the acceptable or non-acceptable of any vulnerability. Organization policy related to acceptable risk is managed independently.

2. Users of the platform should be able to successfully meet or assess this requirement through entirely self-serve means.

3. Users deploying software to the platform should be alerted to non-compliance at the earliest responsible moment and prevented from deploying if the requirement is not met.

## Based on these required outcomes the following architectural attributes are necessary. Existing architectures, capabilities, or process that are believed able to achieve these outcomes are listed and should be followed unless it is discovered they are ineffective.

1. Developers using the platform must have a self-serve means of generating a compliant SBOM.

New capability: SBOM Generation. Based on a review of available third-party options, we will initial assess the results from using Syft (link) to generate a contents SBOM in the following format (type) as the proposed standard going forward.

Based on existing capabilities: A new orb will be created that can be integrated into the Build stage of the platform customer pipelines. Existing starter kits will be updated to have this functionality already integrated.

When integrated the orb will generate an SBOM for each build SHA and upload the SBOM to the image registry of the same image. When completed the orb will also call a custom API that will compare the build log of the image with the SBOM to confirm package accuracy. Upon successful comparison, the API will generate a matching event log, searchable within the observability platform tooling.

2. Users of the platform should be able to successfully assess this requirement through entirely self-serve means.

Existing Capability: The platform 'runtime versions' dashboard already provides a self-serve means for users and stakeholders to see the current versions of all software running in production or nonproduction platform environments, with links to the image registries that will now also contain the SBOM.

3. Users deploying software to the platform should be alerted to non-compliance at the earliest responsible moment and prevented from deploying if the requirement is not met.

Existing Archticture: The platform implements a point-of-change compliance architecture whereby all compliance controls run as validating admission controllers running on the Kubernetes control plane.

New capability: A new admission controller to be created that on any deployment will first validate the deployment object SHA as having a matching, successful SBOM validate event log (from #1). As a result, developers will be alerted to a noncompliant build from the very first environment deployment attempt (their dev environment).

4. A grace period of 90 days will be provided, where the admission controller will not fail but only provide Notice, in order for platform customers to have time to adopt the SBOM orb into their existing build pipelines. 
