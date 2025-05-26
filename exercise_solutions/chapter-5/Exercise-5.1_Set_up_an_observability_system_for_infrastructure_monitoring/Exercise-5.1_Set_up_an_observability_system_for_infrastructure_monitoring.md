***Exercise 5.1: Set up an observability system for infrastructure monitoring***

In this exercise, you will start by selecting an observability stack in your organization. You will also need a system for collecting metrics, logs, and traces. 

* First, you should identify your observability goals - what you need to monitor and determine the scope of what you want to measure
* Next, research the widely used options for Kubernetes. What types of technologies would be needed to gather each of the types of observable data you identified in your goals?
Consider using open-source components like the Grafana LGTM stack and Prometheus (both for metrics), as these are more easily incorporated into later exercises.. 
* Once you decide on the stack, if it is open source or offers a free-trial, install it onto a local instance of Kubernetes. Make a list of the issues you think will need to be solved if this were part of our Epetech platform implementation. 

As an optional step, take a look at how we could capture traces within Kubernetes if our applications were correctly instrumented. OpenTelemetry is a good place to start. What did you learn here that could influence a decision in the previous tasks?

## ***Solution***
### Identify your observability goals
Think about what is needed for you to be sure the platform is operating as it should be.  This might include things like:
* Uptime
* Network throughput
* Cluster control plane errors
* CPU/Memory/DiskIO usage

Also, think about how you will know your platform is being used and (hopefully) show growth over time. This might include tools other than your kubernetes cluster as well:
* Number of team namespaces
* Number of deployments or pods
* Ingress points or routes and services published to the cluster
* Number and frequency of tickets submitted to the platform team and time to resolution

### Open-source components
For this example, we will use the Grafana stack (Prometheus, Loki, Tempo, Grafana), but there are a plethora of others with more being published over time.

### Install on a cluster
The file ### can be run on a local (Linux-based) computer to install a Kubernetes cluster using Kind, and then deploy Grafana LGTM using the public docker image `grafana/otel-lgtm`.  Give it a try if needed, then take a look at some of the default dashboards published!

### Instrumentation
While we have not yet instrumented applications, we should include support for Open Telemetry (OTEL) trace ingestion, as it will be very useful to all teams that adopt it. This will be supported by Grafana LGTM (including accepting Jaegar traces), and an agent can be configured to automatically publish an endpoint.

### Explore captured metrics
Now without any extra configuration, this stack deploys with Prometheus capturing cluster metrics by default and now you can begin to explore them.  In fact, this is the experience your platdform customers should expect when deploying applications!

#### Sample Prometheus Queries
- Open the Prometheus UX at http://localhost:9090 and use the query bar to explore a few metrics
    - Uptime of different cluster components can be seen with `time() - process_start_time_seconds`
    - Uptime of cluster nodes can be queried with `node_time_seconds - node_boot_time_seconds`

### Optional Trace Ingestion
If you look at the prometheus-values we set, notice the `extra_scrape_configs` settings.  This enables prometheus to scrape sone configs from a cluster deployed by Kind that ity would normally get by default in a cluster like EKS, namely `kube-apiserver`.  However, prometheus is set up that any pod deployed by your usage could automatically be scraped for metrics by adding the following annotation to the pod spec:
``` bash
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/path: "/metrics"
  prometheus.io/port: "8080"
```

How can we do the same things for OTEL metrics?  For an open-source option, take a look at the Grafana Agent install to enable this kind of self-service!



