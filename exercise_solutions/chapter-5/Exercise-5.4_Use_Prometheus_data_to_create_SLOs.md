***Exercise 5.4: Use Prometheus data to create SLOs***

In this exercise, you will first define SLOs for your engineering platform. The SLOs have to be aligned to your business needs, and sufficient justification should be provided for the SLOs.  You will then explain what SLIs can be pulled from your observability metrics to show that SLOs are being met or missed.

#### Objectives:

1. Understand the importance of SLOs in a business context and how they are a crucial part of maintaining system reliability.  
2. Justify SLOs based on collected data by writing down the reasoning behind chosen SLOs aligning with business context and user expectations.
3. Align technical metrics to business needs by selecting appropriate SLIs from metrics data that reflect business objectives.

#### Deliverables:

1. A list of key objectives for your engineering platform 
2. Defined SLOs (2-3) based on the chosen objectives, with specific targets (e.g., 99.9% uptime, \<200ms latency). 
3. Justification document explaining why each SLO was selected and how it supports business goals.  
4. List of selected perometheus metrics that can be used as SLIs to support the chosen SLOs.  

## ***Solution***
In our business case we should first think about what business goals of the engineering platform are. Here is an example of what we could think about, you likely can provide many others.

**Key Objectives**: 
- Adoption of the platform by users 
- Increase in engineering efficiency
- Stability of releases to the platform

**SLOs**
- Platform Uptime: 99.95%
- Control plane latency: 95% of new configurations should be recognized within 2s
- Control Plane error rate: Less than 0.1% of properly formed configuration changes should report errors

**SLO Justification**
- Platform uptime: This will increase stability of the platform itself, minimizing organizational downtime
- Control Plane Latency: This provides fast feedback time to engineering teams, increasing efficiency of teams releasing new configurations
- Control Plane Error Rate: Minimizes false positives, increasing developer trust in the platform and the willingness to adopt

**SLIs**
- etcd_server_has_leader (indicates control plane network failure)
- apiserver_request_duration_seconds (control plane latency)
- scheduler_e2e_scheduling_duration_seconds (Scheduler latency)
- kube_apiserver_workqueue_errors (control plane errors)
