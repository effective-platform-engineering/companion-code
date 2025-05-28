***Exercise 5.2: Correlating data with a demo application***

In this exercise, you will build on exercise 5.1.

* Identify a demo application.  
* Start your observability stack  
* Send the data from your demo application.  
* Check and make sure that the data is showing up on an observability dashboard.

## ***Solution***
### Identify a demo application
For this solution, we can deploy the publicly available demo "OpenTelemetry Demo" published by the OpenTelemetry Project at https://opentelemetry.io/docs/demo/kubernetes-deployment/.  The OpenTelemetry demo app is a microservices-based web application that will allow us to generate metrics, logs and traces that can be ingested by our observability stack.

### Start the observability stack
If you followed the example solution to exercise 5.1 in the companion repository, ensure the local cluster you installed is running along with all services that were deployed as part of the Grafana LGT stack, Prometheus, and the optional Grafana Alloy install.  This will allow you to pick up all the telemetry data being sent by the OTel demo once it is properly configured.

### Send data from the demo application
First, we need to configure the otel demo application to ensure that the metrics, logs, and traces are being collected by our deployed agent.  A script that can do this is in the Exercise 5.2 folder of the solutions companion repository.

Note that as a best practice deployed services shouold provide an endpoint for any custom generated metrics, and we can be sure they're sent to the right endpoint with pod annotations.  In a true engineering platform, we could simply document this and expect the engineering team to follow the procedure. For more advanced automation we could even patch deployments with the information when they're deployed as part of the platform!  

For this solution, if you followed the example solution to exercise 5.1 to deploy the observability stack no changes to that are needed to pick up telemetry from the new application deployment.  This is exactly what we want in a self-service platform!  

A script that can deploy and configure the otel demo in a cluster is available at [install_and_configure_demo.sh](./Install_and_configure_demo.sh).  This script will:
- Install the otel demo application on the cluster
- Configure te demo to emit metrics to the installed Prometheus instance
- Configure otel traces to be sent to Tempo
- Logs are automatically scraped from any namespace, so there's nothing needed

If you'd like to check out the application, you can port-forward the frontend and explore, or even generate simulated load.

First, expose the frontend on your local machine
```bash
 kubectl --namespace demo port-forward svc/frontend-proxy 8080:8080
 ```
 Now, you can see it in your browser at `http://localhost:8080`

 If you would like to simulate load on the application, access it at `http://localhost:8080/loadgen`

### Check and make sure that the data is showing up on an observability dashboard
Now we can go into our sample Grafana installation and create a dashboard to verify that the application telemetry is being collected.  First, either run some load through the application or explore the app and purchase some merchandise so we have good telemetry data.  Now we can create a dashboard with 3 panels, one for a metric, log and traces.

- Open the Grafana Interface at http://localhost:3000
- Login with username: admin and password: Epetech
- Click on Dashboards -> Create Dashboard -> Add Visualization
  - Note that data sources should already be configured if you used the solution from Ex 5.1. 

First, we can add a Metrics panel from Prometheus.  We can use this example to show an interesting business metric.  What percentage of requests for TARGETED ads result in the display of a TARGETED ad?
(HINT: if you explore the application and purchase a few things, or run the loadgen, it should not be 100%)
- Select the Prometheus datasource
- For your query, use th following:
```bash
100 * (sum by (job) (rate(app_ads_ad_requests_total{app_ads_ad_response_type="TARGETED"}[5m]))
    / sum by (job) (rate(app_ads_ad_requests_total{app_ads_ad_request_type="TARGETED"}[5m]))
)
```
- Select `Run Query` and then `Apply` in the top right
- You should have your first Metrics Panel!

Now, we can explore logs from Loki.  For example, we may want to see logs from the recommender to see if it correlates with targeted adds.
- Above the panel we created, click `Add` -> `Visualization`
- Change the Datasource to `Loki` and use the `code` entry
- Use the query `{namespace="demo", app="recommendation"}`
    - Note you could also use the Label filters to explore
- Run Query (You may need to switch the Panel to Table View)
- Apply to your dashboard and save
- We now have a panel showing logs from our demo app of cart activity!

Last, we can explore traces.  Trace the GetAds requests to see why targeted ads are not returned if the ratio gets too high.
- Above the panel we created, click `Add` -> `Visualization`
- Change the Datasource to `Tempo`
- Use the following TraceQL to examine "Add to Cart" actions
  - `{resource.service.name="ad" && name="oteldemo.AdService/GetAds"}`
- Ensure you're in Table view and click the "Refresh" button above the query.
  - Note: You can also use the "Search" query type to explore other traces
- Apply to your dashboard and save
- We now have a panel showing traces from our demo app of cart activity!
