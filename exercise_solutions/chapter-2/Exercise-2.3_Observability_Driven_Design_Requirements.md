## ***Exercise 2.3: Observability Driven Design Requirements

Practice defining the observability data needed for a feature using ODD principles, listed in the previous section, by considering the following feature of an engineering platform:

The platform provides a number of predefined ingress domains for Epetech API developers. For example, dev.api.epetech.io is an ingress url reserved for all teams initial testing environments and a dedicated gateway has been defined that receives all traffic to this domain. Teams specify the dev gateway and the path for the dev instance of their API among the values passed during a deployment. Their Helm chart will include a VirtualService resource that includes these values, directing the service mesh to send such traffic to their API. Assuming the customer domain team deploys a profile service, their VirtualService definition would define and direct traffic as follows:

Listing 2.1 Example VirtualService definition
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: profile
  namespace: customer-dev
spec:
  hosts:
    - “dev.api.epetech.io”
  gateways:
    - dev-api-epetech-io-gateway
  http:
    - name: profile-route
      match:
        - uri:
            prefix: /customers/profile
      route:
      - destination:
          host: profile.customer-dev.svc.cluster.local
          port:
            number: 8000

Results in traffic direction of:
https://dev.api.epetech.io/customers/profile => profile.customer-dev.svc.cluster.local 

As the platform engineering team responsible for maintaining this capability, what kinds of observability data will we need to be able to effectively operate, upgrade, and maintain this feature?
How do I know with this is working correctly?
What metrics, logs, traces, or event info would I need to diagnose success or failure?
What kinds of behaviors do I want to be alerted about?

**Solution**
