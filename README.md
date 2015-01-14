CI/CD Canary Workflow
=========

This project highlights the use of StackStorm in a generic, deployable CI/CD pipeline. It
is built off of [st2-workroom](https://github.com/StackStorm/st2workroom) and can be deployed
to a local Vagrant environment, deployed to Digital Ocean, or deployed to a local set of servers.

For use on: Debian/Ubuntu systems. Please see [Expansion](#Expansion) for more details on how
to use this with different components.

# Overview

This CI/CD Workflow is designed as a generic packaging and deployment pipeline. The aim here is to create a pipeline flexible enough to be able to push code of any type through, and prepare it for rapid deployment and management via StackStorm.


This workflow subscribes to the 'Convention over Configuration' view of the world. Any project
should be able to be used by this pipeline, assuming it follows these conventions:

  * CI Portion
    * A project exists on GitHub, and has its outgoing webhook configured to send to StackStorm
    * The project has two scripts designed to ensure the project is setup for  CI
      * `script/cisetup` - Prepares the build directory to run CI. Executed prior to CI begin
      * `script/cibuild` - Commands to test the execute the CI build process.
    * Project has been configured in on Jenkins Server
    * Project has a post-install script (`script/post-inst`) to do any items post-package installation.
    * (NOTE: Any of the scripts can simply `exit 0`, but they need to exist)
  * Consul has been configured to advertise servers with the following tags:
    * 'appname::approle'
    * 'appname::approle_canary'
    * By default, appname is the project name, and approle is `app`

# Configuration

# Design

The section below is aimed at helping guide new users at understanding how the solution was put designed.

## Decisions

This workflow was designed initially to cover the most generic use-case possible, and attempts to make assumptions about the operating environment that this could be used in. Specifically:

* The application language used should not be relevant to the pipeline
* The deploy mechanism must be native to the operating system
* Deploys should make best-effort at synchronous deployment, and also be eventually consistent

## Architecture

![cicd-components](https://cloud.githubusercontent.com/assets/20028/5621151/7f690d3e-94e7-11e4-950d-e5c8cb98adf5.png)

* Load Balancing: HAProxy
* Continuous Delivery
  * Asset: OS Packages
  * Strategy: Canary
* Continuous Integration Server: Jenkins
* Service Discovery: Consul
* Orchestration Layer: StackStorm
* Configuration Management: Puppet / Consul-Template
* Provisioning: Vagrant / EC2 / DigitalOcean

## Process Flow

![cicd-workflow](https://cloud.githubusercontent.com/assets/20028/5620939/7ae8e4de-94e5-11e4-88ed-527fc285c11a.png)

1. User pushes new commit to GitHub
2. [GitHub] Fires a webhook to StackStorm
3. [StackStorm :: Web Hook] StackStorm receives the webhook, and matches it to an incoming rule to begin a CI Job
4. [Jenkins] Clones application from GitHub
5. [Jenkins] On build completion, sends a webhook back to StackStorm with Success/Failure
6. [Jenkins :: Success] StackStorm kicks off packaging workflow to build an OS package from the application.
7. [Package] StackStorm queries Consul for an available host to build a package
8. [Package] StackStorm downloads the application from GitHub
9. [Package] StackStorm queries the downloaded repository for metadata to build the package
10. [Package] StackStorm packages up the repository using FPM
11. [Package] StackStorm takes the package and inserts it into Freight (APT Repository), marking it eligible for download
12. [Package] StackStorm cleans up all tempfiles and hands off to Deploy Workflow
13. [Deploy :: Canary] StackStorm updates the currently advertised version of the application to deploy.
14. [Deploy :: Canary] StackStorm queries all hosts that have been tagged as 'canary'
15. [Deploy :: Canary] StackStorm tells all canary hosts a package has been updated, and updates the servers.
16. User waits for any external alarms to fire (New Relic, Nagios, etc).
17. If no failures, user deploys new package to production.
18. [Deploy :: Production] StackStorm updates the currently advertised version to the currently deployed canary version
19. [Deploy :: Production] StackStorm tells all production hosts a package has been updated, and updates the servers.

## Expansion

