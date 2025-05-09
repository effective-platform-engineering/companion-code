#!/usr/bin/env bats

# if kube-state-metrics is functioning, should see metrics from both aws-managed services and the services deployed in this pipeline
@test "kube-state-metrics reporting metrics from deployed services" {
  run bash -c "kubectl get --raw /api/v1/namespaces/kube-system/services/kube-state-metrics:http/proxy/metrics"
  [[ "${output}" =~ "kube_replicaset_spec_replicas" ]]
  [[ "${output}" =~ "karpenter" ]]
  [[ "${output}" =~ "event-exporter" ]]
}

# if event-exporter is functioning, should see events from the hpa-test
@test "event-exporter reported events from hpa test" {
  run bash -c "kubectl logs deployment/event-exporter -n kube-system -c event-exporter"
  [[ "${output}" =~ "Started container php-apache" ]]
}
