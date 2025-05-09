***Exercise 5.1: Set up an observability system for infrastructure monitoring***

In this exercise, you will start by selecting an observability stack in your organization. You will also need a system for collecting metrics, logs, and traces. 

* First, you should identify your observability goals \- what you need to monitor and determine the scope of what you want to measure  
* Then, consider using open-source components like *the Grafana LGTM stack, Prometheus* *(both for metrics), and Fluentd (for log aggregation)*, as they all have open-source versions.   
* Since you are not monitoring applications in this exercise, you may not yet have to instrument your applications.  
* Once you decide on the stack, install and configure them and collect the data for your infrastructure monitoring. 

The expected deliverable for this exercise is a working dashboard that provides real-time metrics and logs. Traces are optional, but they are typically needed to identify how requests flow through the system, a far more detailed use case for most of the more straightforward problems that can be solved with real-time metrics and logs. However, if you wish to configure your tracing, we recommend trying out *Jaeger*, which allows distributed tracing.

## ***Solution***

