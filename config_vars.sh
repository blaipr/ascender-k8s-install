#!/bin/bash

rm ./custom.config.yml

# k8s_platform
echo $'\n'
platforms=(k3s eks aks gke rke2 dkp ocp)
selected=()
PS3='Select the number of the Kubernetes platform you are using to install Ascender: '
select name in "${platforms[@]}" ; do
    for reply in $REPLY ; do
        selected+=(${platforms[reply - 1]})
    done
    [[ $selected ]] && break
done

k8s_platform=${selected[@]}

echo "---"$'\n'"# This variable specificies which Kubernetes platform Ascender and its components will be installed on." >> custom.config.yml
echo "k8s_platform: "$k8s_platform >> custom.config.yml

# kube_install
if [ $k8s_platform == "k3s" ]; then
    echo $'\n'
    k_install=(true false)
    selected=()
    PS3='Boolean indicating whether to set up a new k3s/k8s on premise cluster (true) or use an existing k3s/k8s on premise cluster (false): '
    select name in "${k_install[@]}" ; do
        for reply in $REPLY ; do
            selected+=(${k_install[reply - 1]})
        done
        [[ $selected ]] && break
    done

    kube_install=${selected[@]}
    echo "# Boolean indicating whether to set up a new k3s cluster (true) or use an existing k3s cluster (false)" >> custom.config.yml
    echo "kube_install: "$kube_install >> custom.config.yml
fi

# download_kubeconfig
echo $'\n'
d_kubeconfig=(true false)
selected=()
PS3='Boolean indicating whether or not the kubeconfig file needs to be downloaded to the Ansible controller: '
select name in "${d_kubeconfig[@]}" ; do
    for reply in $REPLY ; do
        selected+=(${d_kubeconfig[reply - 1]})
    done
    [[ $selected ]] && break
done

download_kubeconfig=${selected[@]}
echo "# Boolean indicating whether or not the kubeconfig file needs to be downloaded to the Ansible controller" >> custom.config.yml
echo "download_kubeconfig: "$download_kubeconfig >> custom.config.yml


# k3s_master_node_ip
echo $'\n'
if [ $k8s_platform == "k3s" ]; then
   echo $'\n'
   read -p "Routable IP address for the K3s Master/Worker node [127.0.0.1]: " k3s_m_node_ip
   k3s_master_node_ip=${k3s_m_node_ip:-127.0.0.1}
   echo "# Routable IP address for the K3s Master/Worker node" >> custom.config.yml
   echo "# required for DNS and k3s install" >> custom.config.yml
   echo "k3s_master_node_ip: "\"$k3s_master_node_ip\" >> custom.config.yml
fi

# kubeapi_server_ip
if [ $k8s_platform == "rke2" ]; then
   echo $'\n'
   read -p "Routable IP address for the K8s API Server (This could be a Load Balancer if using 3 K8s control nodes) [127.0.0.1]: " k8s_api_srvr_ip
   kubeapi_server_ip=${k8s_api_srvr_ip:-127.0.0.1}
   echo "# Routable IP address for the K8s API Server" >> custom.config.yml
   echo "# (This could be a Load Balancer if using 3 K8s control nodes)" >> custom.config.yml
   echo "kubeapi_server_ip: "\"$kubeapi_server_ip\" >> custom.config.yml
fi

if [ $k8s_platform == "eks" ]; then
   
   # USE_ROUTE_53
   echo $'\n'
   use_r53=(true false)
   selected=()
   PS3='Boolean indicating Determines whether to use Route53 Domain Management (true) Or a third-party service such as Cloudflare or GoDaddy (false). If this value is set to false, you will have to manually set a CNAME record for Ascender/Ledger to point to their respective AWS Load Balancers: '
   select name in "${use_r53[@]}" ; do
       for reply in $REPLY ; do
           selected+=(${use_r53[reply - 1]})
       done
       [[ $selected ]] && break
   done

   use_route_53=${selected[@]}
   echo "# Determines whether to use Route53's Domain Management (which is automated)" >> custom.config.yml
   echo "# Or a third-party service (e.g., Cloudflare, GoDaddy, etc.)" >> custom.config.yml
   echo "# If this value is set to false, you will have to manually set a CNAME record for" >> custom.config.yml
   echo "# {{ASCENDER_HOSTNAME }} and {{ LEDGER_HOSTNAME }} to point to the AWS" >> custom.config.yml
   echo "# Loadbalancers" >> custom.config.yml
   echo "USE_ROUTE_53: "$use_route_53 >> custom.config.yml


   #EKS_CLUSTER_NAME
   echo $'\n'
   read -p "The name of the eks cluster to install Ascender on - if it does not already exist, the installer can set it up [ascender-eks-cluster]: " e_cluster_name
   eks_cluster_name=${e_cluster_name:-ascender-eks-cluster}
   echo "# The name of the eks cluster to install Ascender on - if it does not already exist, the installer can set it up" >> custom.config.yml
   echo "EKS_CLUSTER_NAME: "$eks_cluster_name >> custom.config.yml

   #EKS_CLUSTER_STATUS:
   echo $'\n'
   e_cluster_status=(provision configure no_action)
   selected=()
   PS3='Specifies whether the EKS cluster needs to be provisioned (provision), exists but needs to be configured to support Ascender (configure), or exists and needs nothing done before installing Ascender (no_action): '
   select name in "${e_cluster_status[@]}" ; do
       for reply in $REPLY ; do
           selected+=(${e_cluster_status[reply - 1]})
       done
       [[ $selected ]] && break
   done
   eks_cluster_status=${selected[@]}
   echo "# Specifies whether the EKS cluster needs to be provisioned (provision), exists but needs to be configured to support Ascender (configure), or exists and needs nothing done before installing Ascender (no_action)" >> custom.config.yml
   echo "EKS_CLUSTER_STATUS: "$eks_cluster_status >> custom.config.yml

   #EKS_CLUSTER_REGION
   echo $'\n'
   read -p "The AWS region hosting the eks cluster [us-east-1]: " e_cluster_region
   eks_cluster_region=${e_cluster_region:-us-east-1}
   echo "# The AWS region hosting the eks cluster" >> custom.config.yml
   echo "EKS_CLUSTER_REGION: "$eks_cluster_region >> custom.config.yml

   if [ $eks_cluster_status == "provision" ]; then
      #EKS_CLUSTER_CIDR
      echo $'\n'
      read -p "The CIDR block for the EKS cluster [10.10.0.0/16]:" e_cluster_cidr
      eks_cluster_cidr=${e_cluster_cidr:-10.10.0.0/16}
      echo "# The CIDR block for the EKS cluster" >> custom.config.yml
      echo "EKS_CLUSTER_CIDR: "$eks_cluster_cidr >> custom.config.yml

      #EKS_PUBLIC
      echo $'\n'
      eks_public_opts=(true false)
      selected=()
      PS3='Should cluster nodes be assigned public IPs? If true, nodes will be publicly accessible (false is recommended for production): '
      select name in "${eks_public_opts[@]}" ; do
          for reply in $REPLY ; do
              selected+=(${eks_public_opts[reply - 1]})
          done
          [[ $selected ]] && break
      done
      eks_public=${selected[@]}
      echo "# Determines whether cluster nodes are assigned public IPs." >> custom.config.yml
      echo "EKS_PUBLIC: "$eks_public >> custom.config.yml

      #EKS_NUM_SUBNETS
      echo $'\n'
      read -p "The number of subnets for the EKS cluster [3]: " e_num_subnets
      eks_num_subnets=${e_num_subnets:-3}
      echo "# The number of subnets for the EKS cluster" >> custom.config.yml
      echo "EKS_NUM_SUBNETS: "$eks_num_subnets >> custom.config.yml

      #EKS_SUBNET_SIZE
      echo $'\n'
      read -p "The network prefix size for each subnet (e.g. 26 = /26) [26]: " e_subnet_size
      eks_subnet_size=${e_subnet_size:-26}
      echo "# The network prefix size for each of the subnets" >> custom.config.yml
      echo "EKS_SUBNET_SIZE: "$eks_subnet_size >> custom.config.yml

      #EKS_K8S_VERSION
      echo $'\n'
      read -p "The kubernetes version for the eks cluster; available kubernetes versions can be found here: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html [1.33]:" e_k8s_version
      eks_k8s_version=${e_k8s_version:-1.33}
      echo "# The kubernetes version for the eks cluster; available kubernetes versions can be found here:" >> custom.config.yml
      echo "EKS_K8S_VERSION: "\"$eks_k8s_version\" >> custom.config.yml





      #EKS_EBS_CSI_DRIVER_VERSION
      echo $'\n'
      read -p "The EBS CSI driver version for the eks cluster [v1.48.0]:" e_ebs_csi_driver_version
      eks_ebs_csi_driver_version=${e_ebs_csi_driver_version:-v1.48.0}
      echo "# The EBS CSI driver version for the eks cluster" >> custom.config.yml
      echo "EKS_EBS_CSI_DRIVER_VERSION: "$eks_ebs_csi_driver_version >> custom.config.yml

      #EKS_INSTANCE_TYPE
      echo $'\n'
      read -p "The eks worker node instance types [t3.large]:" e_instance_type
      eks_instance_type=${e_instance_type:-t3.large}
      echo "# The eks worker node instance types" >> custom.config.yml
      echo "EKS_INSTANCE_TYPE: "\"$eks_instance_type\" >> custom.config.yml

      #EKS_MIN_WORKER_NODES
      echo $'\n'
      read -p "The minimum number of eks worker nodes [2]:" e_min_worker_nodes
      eks_min_worker_nodes=${e_min_worker_nodes:-2}
      echo "# The minimum number of eks worker nodes" >> custom.config.yml
      echo "EKS_MIN_WORKER_NODES: "$eks_min_worker_nodes >> custom.config.yml

      #EKS_MAX_WORKER_NODES: 6
      echo $'\n'
      read -p "The maximum number of eks worker nodes [6]:" e_max_worker_nodes
      eks_max_worker_nodes=${e_max_worker_nodes:-6}
      echo "# The maximum number of eks worker nodes" >> custom.config.yml
      echo "EKS_MAX_WORKER_NODES: "$eks_max_worker_nodes >> custom.config.yml

      #EKS_NUM_WORKER_NODES: 3
      echo $'\n'
      read -p "The desired number of eks worker nodes [3]:" e_num_worker_nodes
      eks_num_worker_nodes=${e_num_worker_nodes:-3}
      echo "# The desired number of eks worker nodes" >> custom.config.yml
      echo "EKS_NUM_WORKER_NODES: "$eks_num_worker_nodes >> custom.config.yml

      #EKS_WORKER_VOLUME_SIZE
      echo $'\n'
      read -p "The volume size of eks worker nodes in GB [100]:" e_worker_volume_size
      eks_worker_volume_size=${e_worker_volume_size:-100}
      echo "# The volume size of eks worker nodes in GB" >> custom.config.yml
      echo "EKS_WORKER_VOLUME_SIZE: "$eks_worker_volume_size >> custom.config.yml

   fi 
fi

if [ $k8s_platform == "aks" ]; then
   
   # USE_AZURE_DNS
   echo $'\n'
   use_azuredns=(true false)
   selected=()
   PS3='Boolean indicating Determines whether to use Azure DNS Domain Management (true) Or a third-party service such as Cloudflare or GoDaddy (false). If this value is set to false, you will have to manually set an A record for Ascender/Ledger to point to their respective Azure Load Balancers: '
   select name in "${use_azuredns[@]}" ; do
       for reply in $REPLY ; do
           selected+=(${use_azuredns[reply - 1]})
       done
       [[ $selected ]] && break
   done

   use_azuredns=${selected[@]}
   echo "# Determines whether to use Azure DNS Domain Management (which is automated)" >> custom.config.yml
   echo "# Or a third-party service (e.g., Cloudflare, GoDaddy, etc.)" >> custom.config.yml
   echo "# If this value is set to false, you will have to manually set an A record for" >> custom.config.yml
   echo "# {{ASCENDER_HOSTNAME }} and {{ LEDGER_HOSTNAME }} to point to the Azure" >> custom.config.yml
   echo "# Loadbalancers" >> custom.config.yml
   echo "USE_AZURE_DNS: "$use_azuredns >> custom.config.yml

   #AKS_CLUSTER_NAME
   echo $'\n'
   read -p "The name of the aks cluster to install Ascender on - if it does not already exist, the installer can set it up [ascender-aks-cluster]: " a_cluster_name
   aks_cluster_name=${a_cluster_name:-ascender-aks-cluster}
   echo "# The name of the eks cluster to install Ascender on - if it does not already exist, the installer can set it up" >> custom.config.yml
   echo "AKS_CLUSTER_NAME: "$aks_cluster_name >> custom.config.yml

   #AKS_CLUSTER_STATUS:
   echo $'\n'
   a_cluster_status=(provision configure no_action)
   selected=()
   PS3='Specifies whether the AKS cluster needs to be provisioned (provision), exists but needs to be configured to support Ascender (configure), or exists and needs nothing done before installing Ascender (no_action): '
   select name in "${a_cluster_status[@]}" ; do
       for reply in $REPLY ; do
           selected+=(${a_cluster_status[reply - 1]})
       done
       [[ $selected ]] && break
   done
   aks_cluster_status=${selected[@]}
   echo "# Specifies whether the AKS cluster needs to be provisioned (provision), exists but needs to be configured to support Ascender (configure), or exists and needs nothing done before installing Ascender (no_action)" >> custom.config.yml
   echo "AKS_CLUSTER_STATUS: "$aks_cluster_status >> custom.config.yml

   #AKS_CLUSTER_REGION
   echo $'\n'
   read -p "The Azure region hosting the aks cluster [eastus]: " a_cluster_region
   aks_cluster_region=${a_cluster_region:-eastus}
   echo "# The Azure region hosting the aks cluster" >> custom.config.yml
   echo "AKS_CLUSTER_REGION: "$aks_cluster_region >> custom.config.yml

   if [ $aks_cluster_status == "provision" ]; then
      #AKS_K8S_VERSION
      echo $'\n'
      read -p "The kubernetes version for the aks cluster; available kubernetes versions can be found here: https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli [1.29]:" a_k8s_version
      aks_k8s_version=${a_k8s_version:-1.29}
      echo "# The kubernetes version for the aks cluster; available kubernetes versions can be found here:" >> custom.config.yml
      echo "AKS_K8S_VERSION: "\"$aks_k8s_version\" >> custom.config.yml
 
      #AKS_INSTANCE_TYPE
      echo $'\n'
      read -p "The aks worker node instance types [Standard_D2_v2]:" a_instance_type
      aks_instance_type=${a_instance_type:-Standard_D2_v2}
      echo "# The aks worker node instance types" >> custom.config.yml
      echo "AKS_INSTANCE_TYPE: "\"$aks_instance_type\" >> custom.config.yml

      #AKS_NUM_WORKER_NODES: 3
      echo $'\n'
      read -p "The desired number of aks worker nodes [3]:" a_num_worker_nodes
      aks_num_worker_nodes=${a_num_worker_nodes:-3}
      echo "# The desired number of aks worker nodes" >> custom.config.yml
      echo "AKS_NUM_WORKER_NODES: "$aks_num_worker_nodes >> custom.config.yml

      #AKS_WORKER_VOLUME_SIZE
      echo $'\n'
      read -p "The volume size of aks worker nodes in GB [100]:" a_worker_volume_size
      aks_worker_volume_size=${a_worker_volume_size:-100}
      echo "# The volume size of aks worker nodes in GB" >> custom.config.yml
      echo "AKS_WORKER_VOLUME_SIZE: "$aks_worker_volume_size >> custom.config.yml
   
   fi 

fi




if [ $k8s_platform == "gke" ]; then
   
   #GKE_PROJECT_ID
   echo $'\n'
   read -p "The name of the Google Cloud Project ID where the gke cluster should live [ascender-gke-project]: " g_project
   google_project=${g_project:-ascender-gke-project}
   echo "# The name of the Google Cloud Project ID where the gke cluster should live" >> custom.config.yml
   echo "GKE_PROJECT_ID: "$google_project >> custom.config.yml

   # USE_GOOGLE_DNS
   echo $'\n'
   use_googledns=(true false)
   selected=()
   PS3='Boolean indicating Determines whether to use Google Cloud DNS Domain Management (true) Or a third-party service such as Cloudflare or GoDaddy (false). If this value is set to false, you will have to manually set an A record for Ascender/Ledger to point to their respective Google Cloud Load Balancers: '
   select name in "${use_googledns[@]}" ; do
       for reply in $REPLY ; do
           selected+=(${use_googledns[reply - 1]})
       done
       [[ $selected ]] && break
   done

   use_googledns=${selected[@]}
   echo "# Determines whether to use Google Cloud DNS Domain Management (which is automated)" >> custom.config.yml
   echo "# Or a third-party service (e.g., Cloudflare, GoDaddy, etc.)" >> custom.config.yml
   echo "# If this value is set to false, you will have to manually set an A record for" >> custom.config.yml
   echo "# {{ASCENDER_HOSTNAME }} and {{ LEDGER_HOSTNAME }} to point to the Google Cloud" >> custom.config.yml
   echo "# Loadbalancers" >> custom.config.yml
   echo "USE_GOOGLE_DNS: "$use_googledns >> custom.config.yml

   #GKE_CLUSTER_NAME
   echo $'\n'
   read -p "The name of the gke cluster to install Ascender on - if it does not already exist, the installer can set it up [ascender-gke-cluster]: " g_cluster_name
   gke_cluster_name=${g_cluster_name:-ascender-gke-cluster}
   echo "# The name of the gke cluster to install Ascender on - if it does not already exist, the installer can set it up" >> custom.config.yml
   echo "GKE_CLUSTER_NAME: "$gke_cluster_name >> custom.config.yml

   #GKE_CLUSTER_STATUS:
   echo $'\n'
   g_cluster_status=(provision configure no_action)
   selected=()
   PS3='Specifies whether the GKE cluster needs to be provisioned (provision), exists but needs to be configured to support Ascender (configure), or exists and needs nothing done before installing Ascender (no_action): '
   select name in "${g_cluster_status[@]}" ; do
       for reply in $REPLY ; do
           selected+=(${g_cluster_status[reply - 1]})
       done
       [[ $selected ]] && break
   done
   gke_cluster_status=${selected[@]}
   echo "# Specifies whether the GKE cluster needs to be provisioned (provision), exists but needs to be configured to support Ascender (configure), or exists and needs nothing done before installing Ascender (no_action)" >> custom.config.yml
   echo "GKE_CLUSTER_STATUS: "$gke_cluster_status >> custom.config.yml

   #GKE_CLUSTER_ZONE
   echo $'\n'
   read -p "The Google Cloud zone hosting the gke cluster. To see a list of all available zones in your Google Cloud project, you can type the following command into your terminal: $ gcloud compute zones list --project <your-project-id> [us-central1-a]: " g_cluster_zone
   gke_cluster_zone=${g_cluster_zone:-us-central1-a}
   echo "# The Google Cloud zone hosting the gke cluster" >> custom.config.yml
   echo "GKE_CLUSTER_ZONE: "$gke_cluster_zone >> custom.config.yml

   if [ $gke_cluster_status == "provision" ]; then
      #GKE_K8S_VERSION
      echo $'\n'
      read -p "The kubernetes version for the gke cluster; available kubernetes versions can be determined by typing the following command into your terminal: &gcloud container get-server-config --zone < zone > [1.29.4-gke.1043002]:" a_k8s_version
      gke_k8s_version=${g_k8s_version:-1.29.4-gke.1043002}
      echo "# The kubernetes version for the gke cluster" >> custom.config.yml
      echo "GKE_K8S_VERSION: "\"$gke_k8s_version\" >> custom.config.yml
 
      #GKE_INSTANCE_TYPE
      echo $'\n'
      read -p "The gke worker node instance types [e2-medium]:" g_instance_type
      gke_instance_type=${g_instance_type:-e2-medium}
      echo "# The gke worker node instance types" >> custom.config.yml
      echo "GKE_INSTANCE_TYPE: "\"$gke_instance_type\" >> custom.config.yml

      #GKE_NUM_WORKER_NODES: 3
      echo $'\n'
      read -p "The desired number of gke worker nodes [3]:" g_num_worker_nodes
      gke_num_worker_nodes=${g_num_worker_nodes:-3}
      echo "# The desired number of gke worker nodes" >> custom.config.yml
      echo "GKE_NUM_WORKER_NODES: "$gke_num_worker_nodes >> custom.config.yml

      #GKE_WORKER_VOLUME_SIZE
      echo $'\n'
      read -p "The volume size of gke worker nodes in GB [100]:" g_worker_volume_size
      gke_worker_volume_size=${g_worker_volume_size:-100}
      echo "# The volume size of gke worker nodes in GB" >> custom.config.yml
      echo "GKE_WORKER_VOLUME_SIZE: "$gke_worker_volume_size >> custom.config.yml
   
   fi 

fi


if [ $k8s_platform == "dkp" ]; then
   #DKP_CLUSTER_NAME
   echo $'\n'
   read -p "The name of the dkp cluster you wish to deploy Ascender to and/or create [dkp-cluster]:" d_cluster_name
   dkp_cluster_name=${d_cluster_name:-dkp-cluster} 
   echo "# The name of the dkp cluster you wish to deploy Ascender to and/or create" >> custom.config.yml
   echo "DKP_CLUSTER_NAME: "$dkp_cluster_name >> custom.config.yml
fi
if [[ ( $k8s_platform == "k3s" || $k8s_platform == "dkp" || $k8s_platform == "rke2") ]]; then
   echo $'\n'
   u_etc_hosts=(true false)
   selected=()
   PS3='Boolean indicating whether to use the local /etc/hosts file for DNS resolution to access Ascender: '
   select name in "${u_etc_hosts[@]}" ; do
       for reply in $REPLY ; do
           selected+=(${u_etc_hosts[reply - 1]})
       done
       [[ $selected ]] && break
   done
   use_etc_hosts=${selected[@]}
   echo "# Boolean indicating whether to use the local /etc/hosts file for DNS resolution to access Ascender" >> custom.config.yml
   echo "use_etc_hosts: "$use_etc_hosts >> custom.config.yml
fi

