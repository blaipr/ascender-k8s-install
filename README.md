This repository provides the scripts and documentation for creating
Kubernetes clusters for Ascender Automation Platform deployments. It
was split from https://github.com/ctrliq/ascender-install, which now
contains the steps for installing Ascender itself. If you need to
deploy Ascender after the cluster is ready, use that repository.

While this repository provisions Kubernetes clusters, you do not need
to be a guru in Kubernetes, or even have a Kubernetes cluster up and
working. For each specified Kubernetes platform, the installer will
set up a Kubernetes cluster on your behalf and set up the cluster
access file at its default location of `~/.kube/config`.

## Table of Contents

- [General Prerequisites](#general-prerequisites)
- [Configuration File](#configuration-file)
- [Installation Guides](#installation-guides)
- [Reporting Issues](#reporting-issues)

## General Prerequisites

- On the local server (on which the installer script will run), you
  will need the following prerequisites met:
  - Operating System
    - If the OS family is Enterprise Linux (Rocky, Fedora, Alma, RHEL, CentOS, or other EL based OS) then the major version must be 8 or 9.
      - ***For the AKS and GKE installers, this must be version 9.**
    - If the OS family is Ubuntu/Debian then the major version must be 24
      - ***Installation on AKS, GKE, or EKS not currently supported on this OS***
  - git needs to be installed
    - `$ sudo dnf install git -y`
    - or
    - `$ sudo apt-get install git -y`
  - The [ansible inventory file](inventory) file needs to be changed
    to:
    - `ascender_host`
      - `ansible_host` needs to be a set to a server that hosts the [kube-apiserver](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/) kubernetes cluster access or that you want to eventually host the kube-apiserver.
      - `ansible_user` needs to set to a user that can escalate to
        root with `become` (if different than your logged in user)
      - A port needs to be open for SSH access (typically TCP port
        22). If you choose to have SSH accept connections on a
        different port, you need to specify this port with the
        built-in host variable `ansible_port`.
  - [ansible-core][] will have to be installed, but the setup script
    will install it if it is not already there.
- On `ascender_host`, the following is required:
  - If a Kubernetes cluster is already up, you will need the
    [kubeconfig][] file, located at `~/.kube/config`. The server IP
    address in the [cluster][] section of this file will determine the
    cluster where Ascender will be installed. This cluster must be up
    and running at the time of install.
  - If a kubernetes cluster is to be set up, then the installer script it will create the
    kubeconfig for you automatically.

[ansible-core]: https://github.com/ansible/ansible
[kubeconfig]: https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
[cluster]: https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#context

## Configuration File and Inventory

There is a [default configuration file](default.config.yml) that will
hold all of the options required to set up your installation
properly. While this file is comprehensive, you can find more
platform-specific config file templates in the respective Kubernetes
platform install instructions directory.

Additionally, there is an executable script in this directory called [config_vars.sh](./config_vars.sh) that will generate a config file based on user input, named `custom.config.yml`. `custon.config.yml` is listed in .gitignore, and as such is the suggested/preferred method of setting your install variables.

The Ascender Install script also uses the Ansible inventory file, [inventory](./inventory), located in the top level directory of this repository. 

For both the config file and inventory files, you will find templates for each Kubernetes distribution in its corresponding directory in [docs](./docs/). You can use these templates as guides for how `custom.config.ml` and `inventory` should look for your particular install.

## Installation Guides

- [Installation Guides by Kubernetes Platform](docs/README.md)

## Reporting Issues

If you're experiencing a problem that you feel is a bug in the
installer or have ideas for improving the installer, we encourage you
to open a Github issue and share your feedback.
