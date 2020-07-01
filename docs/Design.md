# helmdeep'S HELM DEPLOYMENT DESIGN

## Overview

### Principle

- As simple and close to helm as possible. Without adding unercessary magic complexity.
- We deployed a complete applications, not deploy to test. (To provide correct versioning). https://semver.org/spec/v2.0.0.html
- Clear and Explicit. Every action is clearly defined.
- Specific charts design. Each chart do one job and one job only.
- Feature is instroduce at Core level, then helper will be develope on top when needed.

### Deployment layer

#### HelmDeep Core Helm deployment
This layer is a very thin layer between HelmDeep and helm. Mostly command that use helm to deploy our service to HelmDeep.

#### HelmDeep Helper deployment
This is a layer that we build on top of the core layer, to make our life easier.
- Is optional.
- Can be plugin and use and plugout without affect the core layers.

This layer may contain scripts and command to help ease the deployment process but it should not affect how HelmDeep Core worked. Which mean we do not design HelmDeep Core to work with the helper.

#### Server support
Server specific support like GKE or AWS should be on the helper layer.

#### Advance topics
Blue Green deployment process

## Implementation

### HelmDeep Core

We use helm command to deploy our applications

Helm's Docs: https://helm.sh/docs/

What HelmDeep Core is:
- A set of rules that we follow.
- How to organize the charts and helm resources.
- Versioning.
- Commonly used templates and how to write a templates.
- Deployment steps.

In general in HelmDeep core we will have some implementation to help everyone can follow and obey our rules. Mostlikely some validation systems, documentations and very basic helper scripts.

#### Discussion
Helm Topics: https://helm.sh/docs/topics/
- Charts
    - Organize A Micro Service. (Nested charts?)
    - Services relationship and communications.
    - Configuration.
    - Environment specific configs and resources.
    - Credential and security.
    - Share features such and API Gateway.
- Chart Hooks
- Chart libs
    - Helm Helper Charts: https://helm.sh/docs/topics/library_charts/#the-common-helm-helper-chart
- Schema

1. Organize helm charts:

Each chart bellong to one of the following category:
- Service: A charts that describe kubernetes resources that need to run a service.
- Libary: A chart that will be share and used in Service Chart
    - No values
- Release: A list of Service Chart that will be release on to server as a packages.
    - No templates
    - Only have dependencies
