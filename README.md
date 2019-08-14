# VCN Watchdog
This project provides a tool for _CONTINUOUS VERIFICATION_ (CV) via CodeNotary.

The idea behind CV is to continuously monitor your application environment at
runtime and prevent unknown/bad containers from being executed.

## Usage
Check out the project, edit the `verify` file and fill in whatever
alerting/monitoring functionality you want.

Make sure /var/run/docker.sock is accessible.

Run this on your server:

    docker-compose build && docker-compose up -d

## Design
This tool is designed as a sidecar for your existing docker environment. All
running containers are continuously checked via `vcn` for integrity. If a
container fails the verification check, a customisable alert is triggered.

## Docker Swarm and Prometheus

### Docker Swarm

Best is to integrate into your existing docker-compose file for monitoring (that includes the Prometheus server):

add the following service to your existing docker-compose.yml file:

```yaml
 services:
   vcn-watchdog:
     image: vcn-watchdog_vcn:latest
     networks:
       - net
     volumes:
       - /var/run/docker.sock:/var/run/docker.sock:ro
     deploy:
       mode: global
       resources:
         limits:
           memory: 128M
         reservations:
           memory: 64M
```

Typically the Docker swarm deployment is done using docker stack

```bash
docker stack deploy -c docker-compose.yml mystack
```

You can check the running service and if there vcn-watchdog container running on each node:

```bash
docker service ls
```

**Please be aware**: If you don't use a vcn-watchdog container on dockerhub, you need to build the image on each node for swarm to start the container

```bash
docker-compose build -f docker-compose-prometheus.yml
```


### Prometheus service discovery

In order to collect metrics from Swarm nodes you need to deploy the vcn watchdogs on each server.
Using global services (mode) you don't have to manually deploy the exporters. When you scale up your
cluster, Swarm will launch a vcn-watchdog  instance on the newly created nodes.
All you need is an automated way for Prometheus to reach these instances.

Running Prometheus on the same overlay network as the exporter services allows you to use the DNS service
discovery. Using the exporters service name, you can configure DNS discovery:

```yaml
  - job_name: 'vcn-watchdog'
    metrics_path: "/"
    dns_sd_configs:
    - names:
      - 'tasks.vcn-watchdog'
      type: 'A'
      port: 9581

```

When Prometheus runs the DNS lookup, Docker Swarm will return a list of IPs for each task.
Using these IPs, Prometheus will bypass the Swarm load-balancer and will be able to scrape each exporter
instance.

## Full Stack deployment (Prometheus + vcn-watchdog)
If you don't have a running Prometheus and want to run the full stack, just use the docker-compose.stack.yml file

```bash
$ git clone https://github.com/vchain-us/vcn-watchdog.git
$ cd vcn-watchdog

docker stack deploy -c docker-compose.stack.yml vcn-fullstack
docker service ls
```

That starts a Prometheus service as well as a vcn-watchdog on every Docker Swarm node.
By default Prometheus exports Port 9091 based on the docker-compose.stack.yml file

To remove the stack:
```bash
docker stack rm vcn-fullstack
```

## Grafana

You can simply add the Prometheus datasource to Grafana and import the Docker Swarm dashboard from here:
