# VMware Tanzu Kubernetes Grid Integrated Edition (TKGI) Cluster Validation

This guide covers validating an existing TKGI cluster with this
repository so it is ready for an Ascender deployment. It was split from
https://github.com/ctrliq/ascender-install, which now contains the
steps for installing Ascender itself. If you need to install Ascender
after the cluster is validated, use that repository.

The TKGI path does not provision a TKGI cluster for you; it validates
cluster access, Kubernetes version, ingress, storage, and RBAC against
an existing cluster.

## General Prerequisites

If you have not done so already, follow the general prerequisites in the
[main README](../../README.md#general-prerequisites).

## TKGI-specific Prerequisites

- These instructions assume you already have a reachable TKGI cluster.
- You need a working `kubectl` installation on the machine running the installer.
- You need a valid kubeconfig for the target TKGI cluster.
- You need cluster permissions that allow namespace creation plus the creation of the resources
  required by the Ascender Operator and Ascender manifests.
- You need at least one usable StorageClass for PostgreSQL persistence.
- You need a working ingress controller. TKGI environments commonly use Contour, and the installer
  will try to detect that automatically.

## Install Instructions

### Prepare the inventory and config files

Use the TKGI example files in this directory as your starting point:

- [tkgi.inventory](./tkgi.inventory)
- [tkgi.custom.config.yml](./tkgi.custom.config.yml)

Copy them to the repository root as needed:

```text
$ cp docs/installation/tkgi/tkgi.inventory inventory
$ cp docs/installation/tkgi/tkgi.custom.config.yml custom.config.yml
```

### Required TKGI settings

Update your `custom.config.yml` with the values for your environment:

- `k8s_platform: tkgi`
- `kube_install: false`
- `ASCENDER_HOSTNAME`
- `ASCENDER_NAMESPACE`

You should also review these TKGI-specific settings:

- `TKGI_KUBECONFIG_PATH`: optional kubeconfig path if you are not using `~/.kube/config`
- `TKGI_K8S_CONTEXT`: optional kubeconfig context if you do not want to use the current context
- `TKGI_INGRESS_CLASS_NAME`: optional explicit ingress class name if auto-detection is not enough
- `POSTGRES_STORAGE_CLASS`: optional explicit storage class if you do not want to rely on the
  cluster default

### Validate cluster access

Before running the installer, confirm that the kubeconfig and context you plan to use can reach the
TKGI cluster:

```text
$ kubectl config get-contexts
$ kubectl config current-context
$ kubectl get nodes
```

### Run the setup script

Run the installer from the repository root:

```text
$ sudo ./setup.sh
```

The TKGI path validates the kubeconfig, cluster connectivity, Kubernetes version, ingress
controller, storage class availability, namespace access, and the RBAC needed for an Ascender
installation. When `use_etc_hosts` is enabled and a Contour envoy ingress address can be detected,
the installer also adds local `/etc/hosts` entries for `ASCENDER_HOSTNAME` and (when
`LEDGER_INSTALL` is true) `LEDGER_HOSTNAME`.

Once the cluster validates successfully, use
https://github.com/ctrliq/ascender-install to install Ascender onto it.
