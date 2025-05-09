## When do we consider a story done?

### Is a story Dev Complete?

✅ Are the _acceptence criteria_ met?  
✅ Have all necessary _[documentation](#documentation) changes_ been made?  
✅ Are repositories named according to our _[naming conventions](#repository-naming-conventions)_?  
✅ Do code changes and quality adhere to our _[code conventions](#code-conventions)_?  
✅ Have infrastructre and helm _[tagging conventions](#tagging-conventions) been followed?  
✅ Have _[testing standards](#testing-standards)_ been maintained?  
✅ Are _[engineering practice and observability standards](#engineering-practice-and-observability)_ met?   
✅ Is the _pipeline green_?  
✅ Has a _desk check_ occured?  

### Is DeskCheck Complete?

✅ Performed by _someone who didn't work on the story_?  
✅ Confirm the story _is Dev Complete?_  
✅ Where called for, are _manual tests successful and are they necessary_?  
✅ Is _[Tech Debt](#tech-debt)_ addressed?  

### Is it done?

✅ Have any _unique release requirements_ listed in the story been met (e.g., customer notification, on certain date/time)?  
✅ Is it running _in Production_? (even if toggled off)  

## Acceptance Criteria

Each story includes the following information, when applicable.  

✅ link to related repository  
✅ link to new or updated documentation where maintained outside repository  
✅ Environments to verify (endpoint URLs, AWS, etc)  
✅ Any manual steps required for verfication  

## Documentation

* Has _Product Documentation_ been updated to reflect necessary changes?
* Has the repository _README_ been updated to reflect necessary changes?
* If any architectural decision were made, have they been entered into the _ADR_?
* Does the repository name and documentation _follow the conventions_?
* Is the repository pipeline reflected in the _build diagram_?
* Have the _Demo Applications and Documentation_ (primary training and orientation mechanism) been updated to include necessary changes or incorporate new functionality?
* Has the supporting _Triage Guide_ and/or _Runbook_ been updated to reflect necessary changes?
* Do _story comments_ reflect important details? (such as tech debt found and resolved, agreed changes, QA instructions if applicable.)

_Triage Guide_: Guide for the ‘initial’ support layer that accelerates or assists them in quickly identifying whether the Platform team or a customer team is the escalation target.

_Runbook_: Mostly this will be our own team-oriented response-runbook, but if/when capabilities are created that allow external support response teams to make adjustments (the ‘scale’ button), it includes these as well.

## Code Conventions

* README is primary documentation for the code base
* README states the development and deployment dependencies
* (source) is the evolving user documentation for all things that do not fit in a particular repo README

### Repository naming conventions

(list naming conventions)

### tagging conventions

#### helm deployment labels or annotations

```yaml
metadata:
  labels:
    # istio/kiali required labels
    app:            # helm/pod app name
    version:        # release version

    # standard base-kubernetes labels
    app.kubernetes.io/name:        # helm/pod app name
    app.kubernetes.io/instance:    # Chart instance
    app.kubernetes.io/version:     # release version
    app.kubernetes.io/managed-by: Helm # if applicable
```

### aws resource tagging conventions

(list team, product, and organizational tagging conventions)

## static-code-analysis and integration standards

**terraform pipelines**

Static Analysis. 
* tflint
* terraform fmt
* terraform validate
* checkov (optional)  
* trivy

Integration Tests. 
* AWSpec
* bats

**docker build pipelines**

**general**
* Every environment is tested identically (exceptions being destructive data testing in prod when it is not supported)
* See testing guide/pyramid
* Code test coverage is assessed and reported

## Engineering Practice and Observability

### Engineering Generally

* Trunk-based development.  
* Frequent commits, merging often.  
* Commits are signed.  
* By default, the trunk branch is named `main`.  
* Git-push (or PR) triggers CI and dev release, git-tag triggers release pipeline.  
* Everything is a pipeline  - no manual configuration or orchestration, git push is only means of changing actual state of our products (environments, services, tools, UI’s).  
* Is the domain-area associated with the story included among the Game Day challenges?  
* Have additional cross-functional concerns been identified since that last time you reviewed these DefOfDone standards and are they incorporated? Include if not.  
* Peer-reviewed? (desk_check)  
* Are dependencies pinned to specific versions? If there are new versions of dependencies, did you update them or create a story for the work?

### Engineering Security

* Encryption at rest (for data we own)
* Encryption in transit
* Zero-trust network patterns
* Distro-less image builds
* State scanning includes both security and conformity, and scans run both in domain pipelines are part of every change as well as recurring

### Engineering Observability

* The metrics/logs emitted and collected, monitoring, alerting, and all such modes of observability, however shaped, are identical in each environment. This assumes that the ‘level’ of alerting is an environmental config setting and is pragmatic (don’t page out folks for dev/qa env alerts).  
* Broad spectrum health and functional metrics are radiated in a manner that supports effective triage. (the ones you don’t necessarily look at much unless there’s a problem, but then these are essential.)  
* Healthy state is defined and alert-monitored.  
* Health monitoring radiators include current service ‘version’, by environment, and where applicable include the latest available release version.  
* For each story effecting a given capability, assess the effectiveness of the radiators and health monitoring. Is there a better understanding of the service from which we could create more effective monitoring? Refactor, or at a minimum create the tech-debt story to reflect.  
* Are we monitoring for things we will/can respond to? Alerts must be actionable. For each story, assess whether current monitoring is not actionable (either there is no response or historically no response has been taken) and refactor, or at a minimum create a tech-debt story.  
* Is the associated pipeline on the build radiator? Is the pipeline integrated with the deployment radiator, by environment.  
* Are the external dependencies associated with the domain of the story being monitored with alerting? Refactor or at minimum create a tech-debt story. This includes technology versions such as kubernetes, istio, eks AMIs, etc.  
* Does the deployment pipeline send a deployment event to datadog so that time-series widgets can include deployment as an overlay?
* Does the deployment pipeline send a message to the platform-events channel in the team's slack workspace?

### Tech Debt

* Known technical debt is reflected in the backlog.  
* When making a technical debt decision, it is always reflected in the backlog.  
* When encountering previously untracked tech debt while working on a story, if it can be corrected relatively fast, then it should be fixed within the context of the story. Otherwise, it should be added to the backlog.  
* Discuss discovered and corrected tech debt in the comments section of the to story card.  
* Discuss any newly added tech debt stories in tech huddle discussions. 
* As part of reviewing tech debt, also assess code and pipelines for DRYness. Should an Orb exist to reduce duplication and/or make an implementation consistent across repos? Should a shared instance be created for a: library, executor, radiator 

Common causes of technical debt include:

* Business pressures
* Lack of ownership
* Insufficient up-front definition
* Poor technological leadership
* Lack of domain knowledge
* Lack of alignment to standards
* Delayed refactoring
* Lack of documentation
* Tightly-coupled components
* Lack of a test suite
* Lack of collaboration

## Build Radiators
## Other NFRs  

Ongoing development, long series of project enhancements over time renders old solutions sub-optimal.


<br />
<hr />
<br />
<div align="center">
  <h4>Platform Manifesto</h4>
  <p>• There is one platform, not a collection of platforms •</p>
  <p>• The desired state of the platform is a known quantity •</p>
  <p>• The desired state is machine parseable •</p>
  <p>• The only authoritative source for the actual state of the platform is the platform •</p>
  <p>• The actual state must self-correct to the desired state •</p>
  <p>• The entire platform is deployable using diffable source code and 3rd party artifacts •</p>
  <p>• Test don’t inspect •</p>
  <p>• Convention rather than configuration •</p>
  </p>
  <br />
  <p>
  <p>_translation_</p>
  <p>(Every environment is like production)</p>
  <p>(Every detail of the desired state is documented)</p>
  <p>(The "desired state" documention is also the source-code for the software-defined delivery of the platform )</p>
  <p>(Avoid monitoring only proxies of state wherever possible)</p>
  <p>(The platform architecture is based on resiliency, not just availability)</p>
  <p>(It is software-defined, employing sdlc practices, not merely automated)</p>
  <p>(No dependencies on human inspection either to determine or validate state)</p>
  <p>(Naming is not merely an identifier but aims to be derivable from knowing the product, environment, component, etc)</p>
</div>
<br />