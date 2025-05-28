## Exercise 5.1: Set up an observability system for infrastructure monitoring

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
For this example, we will use the Grafana stack (Prometheus, Loki, Tempo, Grafana), but there are a plethora of others with more being published over time.  Scripts demonstrating how to deploy this on a local computer are available in the chapter-5 folder of the exercise_solutions companion GitHub repository.

### Install on a cluster
The bash script [observability_stack/install_k8s_with_observability.sh](./observability_stack/install_k8s_with_observability.sh) in the solution foldxer for this exercise folder can be run on a local (Linux-based) computer to install a Kubernetes cluster using Kind, and then deploy Grafana LGT (Loki, Grafana, Tempo) using the public Helm chart `ggrafana/lgtm-distributed` with Prometheus using the public Helm chart `prometheus-community/prometheus`. 

### Explore captured metrics
Now without any extra configuration, this stack deploys with Prometheus capturing cluster metrics by default and now you can begin to explore them.  In fact, this is the experience your platform customers should expect when deploying applications!

#### Sample Prometheus Queries
Open the Prometheus UX at http://localhost:9090 and use the query bar to explore a few metrics
  - Uptime of different cluster components can be seen with `time() - process_start_time_seconds`
  - Uptime of cluster nodes can be queried with `node_time_seconds - node_boot_time_seconds`

### Optional Trace Ingestion
While we have not yet instrumented applications, we should include support for Open Telemetry (OTEL) trace ingestion, as it will be very useful to all teams that adopt it.

If you look at the [observability_stack/prometheus-values.yaml](./observability_stack/prometheus-values.yaml) we used for this solution exanple, notice the `extra_scrape_configs` settings on Line 9.  Some of this is unique to our demo deployment, enabling prometheus to scrape some configs from the cluster that you would normally get by default in a cluster like EKS, namely `kube-apiserver`.  

However, this shows that by using standard labels on deployed pods, Prometheus can automatically start capturing metrics without any changes to the prometheus setup itself!   In fact, any application pod deployed with the following labels will automatically get picked up, allowing for a self-service way to provide basic observability to platform users:

``` bash
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/path: "/metrics"
  prometheus.io/port: "8080"
```

We can see how this is applied in the next exercise.  Naturally, the next consideration is how we can do the same things for logs and OTEL metrics?  For an open-source option, take a look at the Grafana Alloy install to enable this kind of self-service!  An example of how to do this on a local cluster created by Kind is in [scraping_agent/install_grafana_alloy.sh](./scraping_Agent/install_grafana_alloy.sh) of the solution folder for this exercise.  We can make use of this in the next exercise as well.