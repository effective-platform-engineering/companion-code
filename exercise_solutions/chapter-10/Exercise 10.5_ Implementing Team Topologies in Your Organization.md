## ***Exercise 10.5: Implementing Team Topologies in Your Organization***

Objective: Restructure team interactions based on Team Topologies to improve collaboration and flow efficiency.

Here are the recommended steps for this exercise.

1. Map Current Team Structures:  
* Modeling Activity: Create organizational charts and team interaction diagrams using tools like draw.io, Visio, or Miro. Highlight communication channels and dependencies.  
* Coding Activity: Use network analysis libraries in Python (e.g., NetworkX) to model and visualize team communication patterns based on data from communication tools (e.g., Slack API).  
2. Identify Appropriate Team Types:  
* Analyze the data to determine optimal team structures.  
* Modeling Activity: Update diagrams to reflect proposed Stream-Aligned, Platform, Enabling, or Complicated-Subsystem teams.  
3. Define Interaction Modes:  
* Modeling Activity: Create sequence diagrams or flowcharts illustrating new interaction modes between teams.  
* Coding Activity: Simulate interactions using scripts or tools to model workflows (e.g., BPMN tools).  
4. Propose a Restructured Team Topology:  
* Modeling Activity: Present the new organizational structure using visual aids.  
* Coding Activity: Develop a simple application to showcase how teams interact with shared tools or platforms.  
5. Develop a Transition Plan:  
* Outline the steps and timelines  
6. Pilot the Changes:  
* Implement the new structure in a pilot area.  
* Coding Activity: Create collaborative coding projects on platforms like GitHub or GitLab to reflect new team interactions.  
7. Collect Feedback and Iterate:  
* Coding Activity: Use custom scripts to collect metrics on collaboration (e.g., pull requests and code reviews).  
* Analyze the effectiveness of the new topology and make adjustments.

The expected deliverables will be the following.

* Organizational charts of current and proposed structures.  
* Communication Patterns Analysis using visualizations from coding activities.  
* Interaction Diagrams showing new workflows.  
* Simulated Interaction Models or Applications.  
* Transition Plan with automated project management tasks.  
* Pilot Implementation Report with data-driven insights.

### **Solution**

### 1. Map Current Team Structures
- **Modeling Activity**:  
  - Create organizational charts of Epetech’s current engineering, product, and operations teams using tools like Miro or draw.io.  
  - Highlight key communication channels (Slack, Jira, GitHub) and dependencies.  
- **Coding Activity**:  
  - Use Python libraries like **NetworkX** to ingest Slack API or GitHub activity logs and visualize cross-team communication density.  
  - Identify bottlenecks such as “one-team-dependency” patterns.

**Outcome**: A baseline map of how Epetech’s teams interact today.


### 2. Identify Appropriate Team Types
- Based on the analysis, classify teams into the four Team Topologies archetypes:  
  - **Stream-Aligned Teams** → aligned to business value streams (e.g., API services, onboarding, payments).  
  - **Platform Team** → builds shared developer infrastructure and internal platforms.  
  - **Enabling Team** → supports adoption of practices like observability, CI/CD, and SRE.  
  - **Complicated Subsystem Team** → specialized focus (e.g., machine learning models, regulatory compliance).  

**Outcome**: Updated diagrams reflecting proposed team types for Epetech.online.


### 3. Define Interaction Modes
- **Modeling Activity**:  
  - Define how teams interact using **Collaboration, X-as-a-Service, and Facilitating** modes.  
  - Example: Platform Team provides infrastructure **as a service**; Enabling Team **facilitates** adoption of observability practices.  
- **Coding Activity**:  
  - Create simple BPMN (workflow) diagrams or simulations that show new collaboration flows.  

**Outcome**: Clear expectations for team-to-team engagement.

### 4. Propose a Restructured Team Topology
- **Modeling Activity**:  
  - Present the new topology as a visual organization map (current vs. future state).  
- **Coding Activity**:  
  - Build a lightweight web app or GitHub wiki that documents how teams interact with shared tools, APIs, and workflows.  

**Outcome**: A tangible representation of the “future Epetech team structure.”


### 5. Develop a Transition Plan
- Define phased steps to shift from the old structure to the new one:  
  - **Phase 1**: Introduce Stream-Aligned + Platform Teams.  
  - **Phase 2**: Add Enabling Teams to support adoption.  
  - **Phase 3**: Incorporate Complicated Subsystem Teams as needed.  
- Establish **timelines, ownership, and metrics** for success.  

**Outcome**: A realistic change management plan.


### 6. Pilot the Changes
- Select one value stream (e.g., **Onboarding API**) to test the new structure.  
- Implement cross-functional collaboration between the Stream-Aligned and Platform teams.  
- **Coding Activity**: Use a shared GitHub repo to model collaboration, reflecting new PR review workflows, branching strategies, and ownership boundaries.  

**Outcome**: Measured experiment with early learnings.



### 7. Collect Feedback and Iterate
- **Coding Activity**:  
  - Use scripts to track collaboration metrics: PR review times, cross-team commits, code ownership spread.  
- Conduct qualitative retrospectives with the pilot teams.  
- Adjust topology and interaction models based on insights.  

**Outcome**: Continuous improvement loop to evolve Epetech’s topology.



## Expected Deliverables
- **Organizational Charts** of current and proposed structures.  
- **Communication Patterns Analysis** from NetworkX/Slack/GitHub activity.  
- **Interaction Diagrams** showing collaboration, X-as-a-Service, and facilitation workflows.  
- **Simulated Interaction Models or Applications** for demonstration.  
- **Transition Plan** with phased approach and timelines.  
- **Pilot Implementation Report** with metrics-driven insights and iteration plan.


## Intended Outcome
By applying Team Topologies, **Epetech.online** will:  
- Reduce cross-team dependencies that slow down delivery.  
- Improve collaboration by clarifying roles, responsibilities, and interaction modes.  
- Enhance developer experience with a dedicated platform and enabling teams.  
- Evolve into a more resilient and adaptable organization aligned to business value streams.
