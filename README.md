# VCN Watchdog
This project provides a proof of concept for _CONTINUOUS VERIFICATION_ (CV) 
via CodeNotary.

The idea behind CV is to continuously monitor your application environment at
runtime and prevent unknown/bad containers from being executed.

## Usage
Check out the project, edit the `verify` file and fill in whatever 
alerting/monitoring functionality you want.

Make sure /var/run/docker.sock is accessible.

Run this on your server:

    docker-compose build && docker-compose up

## Design
This tool is designed as a sidecar for your existing docker environment. All
running containers are continuously checked via `vcn` for integrity. If a 
container fails the verification check, a customisable alert is triggered.

