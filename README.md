# K8s RabbitMQ Pod Autoscaler

Autoscaling process (`autoscale.sh`):
- Loops through deployments defined in `AUTOSCALING` (env var), every `INTERVAL` (env var) seconds.
- Gets the messages queue on RabbitMQ for the current deployment's queue.
- Calculates the amount of desired pods and scales the deployment if required.
- Every event success or failure will log and notify slack if the `SLACK_HOOK` env var is set (logging intensity depends on `LOGS` env var).

This Pod runs in the `kube-system` namespace on K8s master nodes.

### Requirements

- Namespace(s), deployment(s) or queue(s) defined in `AUTOSCALING` env var can't have `|` or `;` symbols in name(s).

### Environment variables

- `INTERVAL`: Seconds between checks in the pod autoscaling process described above (default 30s)
- `RABBIT_HOST`: RabbitMQ host (e.g. http://rabbitmq.example.com), if it running on custom port pass like localhost:15673.
- `RABBIT_USER`: Username used for authentication with the RabbitMQ API (check `deploy.yml`, defaults to `rabbit-pod-autoscaler` secret, `rabbit-user` key)
- `RABBIT_PASS`: Password used for authentication with the RabbitMQ API (check `deploy.yml`, defaults to `rabbit-pod-autoscaler` secret, `rabbit-pass` key)
- `AUTOSCALING`: Contains min/max pods, messages handled per pod, deployment info and queue name in the following pattern:
  - single deployment to autoscale: `<minPods>|<maxPods>|<mesgPerPod>|<k8s namespace>|<k8s deployment name>|<RabbitMQ vhost>|<RabbitMQ queue name>`
    - e.g. `3|10|5|development|example|vhostexample|example.queue`
    - `mesgPerPod` represents the amount of RabbitMQ messages a Pod can process within the `INTERVAL` (env var). As an example, if a Pod needs 6s to process a message from RabbitMQ, the `mesgPerPod` value will be `INTERVAL (30s) / process time (6s) = 5`.
  - multiple deployments to autoscale: check example `deploy.yml`
- `LOGS`: Logging and Slack notifications intensity. Errors are logged and notified on every option
  - `HIGH` (default): Logs and notifies on every event
  - `MEDIUM`: Logs and notifies on min pods, avg pods ((min+max)/2) and max pods scale events
  - `LOW`: Logs and notifies on min pods and max pods scale events
- `SLACK_HOOK`: Slack incoming webhook for event notifications

### Deployment

```
kubectl --context CONTEXT -n kube-system apply -f deployment.yml
```

### Notes
K8s RabbitMQ Pod Autoscaler is based on [Onfido's](https://github.com/onfido/k8s-rabbit-pod-autoscaler) original project and [Prasvats](https://github.com/prasvats/k8s-rabbit-pod-autoscaler) improvements.

### Contributors
- Sebastian Gogoasa (GitHub: [SebastianGogoasa](https://github.com/SebastianGogoasa))