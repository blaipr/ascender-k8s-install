# Ascender Installation and Updating on K3s

This guide covers creating and configuring a K3s cluster with this
repository. It was split from https://github.com/ctrliq/ascender-install,
which now contains the steps for installing Ascender itself. If you
need to install Ascender after the cluster is ready, use that
repository.

## Table of Contents

- [General Prerequisites](#general-prerequisites)
- [K3s-specific Prerequisites](#k3s-specific-prerequisites)
- [Install Instructions](#install-instructions)
  - [Offline Installation](#offline-installation)
  - [Offline Ascender Upgrade](#offline-ascender-upgrade)

## General Prerequisites

If you have not done so already, be sure to follow the general prerequisites found in the
[main README](../../README.md#general-prerequisites).

## K3s-specific Prerequisites

- NOTE: This guide uses a single-node K3s cluster as a sandbox for the
  cluster installation flow. The installer expects a single-node K3s
  cluster which will act as both master and worker node.
- Operating System
  - If the OS family is Enterprise Linux (Rocky, Fedora, Alma, RHEL, or CentOS) then the major version must be 8 or 9.
  - If the OS family is Ubuntu/Debian then the major version must be 24
- Minimal System Requirements for the k3s server:
  - CPUs: 2
  - Memory: 8GB (if installing both Ascender and Ledger)
  - 20GB of free disk (for Ascender and Ledger Volumes)
- These instructions accommodate an existing K3s cluster, or will set up a new one on your behalf if
  necessary. This behavior is determined by the variable `kube_install`
  - If `kube_install` is set to true, the installer will set up K3s on the `ascender_host`in the
    inventory file. (`ascender_host` can be localhost)
  - If `kube_install` is set to false, the installer will not perform a K3s install
- SSL Certificate and Key
  - To enable HTTPS on your cluster endpoint, you need to provide the
    installer with an SSL Certificate file and a Private Key file.
    While these can be self-signed certificates, it is a good practice
    to use a trusted certificate issued by a Certificate Authority. A
    good way to generate a trusted certificate for sandboxing is to use
    the free Certificate Authority, [Let's Encrypt](https://letsencrypt.org/getting-started/).
  - Once you have a Certificate and Private Key file, make sure they
    are present on the machine running the installer and specify their
    locations in the default config file with the variables
    `tls_crt_path` and `tls_key_path`, respectively. The installer will
    parse these files for their content and use the content to create a
    Kubernetes TLS Secret for HTTPS enablement.

## Install and Upgrade Instructions

### Obtain the sources

You can use the `git` command to clone the ascender-k8s-install repository or you can download the
zipped archive. (Install `git` with `sudo yum -y install git` if it is not already present.)

```text
$ git clone https://github.com/ctrliq/ascender-k8s-install.git
```

This will create a directory named `ascender-k8s-install` in your present working directory (PWD).

We will refer to this directory as the \<K8S-INSTALL-SOURCE\> in the remainder of these
instructions.

### Set the configuration variables for a K3s Install

Change directories into the newly created `ascender-k8s-install` and run the `config_vars.sh` script.

```text
$ cd ascender-k8s-install

$ ./config_vars.sh
```

The script will take you through a series of questions that will populate the variables file
required to create the K3s cluster. This variables file will be located at `./custom.config.yml`:

You can edit this file manually if you want to change variables before (re)creating the cluster.

Examples of Configuration files for traditional installation (where resources such as container
images are retrieved from online) and offline installation can be found in this directory as:

- [k3s.default.config.yml](./k3s.default.config.yml)
- [k3s.offline.default.config.yml](./k3s.offline.default.config.yml)

### Run the setup script

Run `./setup.sh` from top level directory in this repository. The setup must run as a user with
Administrative or `sudo` privileges. To begin the setup process, type:

```text
$ sudo ./setup.sh
```

Once the setup is completed successfully, you should see a final output similar to:

```text
[snip...]
PLAY RECAP *************************************************************************************************************************
ascender_host              : ok=14   changed=6    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
localhost                  : ok=72   changed=27   unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

CLUSTER SUCCESSFULLY SETUP
```

### Uninstall

To uninstall K3s, run:

/usr/local/bin/k3s-uninstall.sh
