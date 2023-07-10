# Infrastructure As Code - Attack/Defense

## Introduction

This repository contains the code for the Infrastructure As Code - Attack/Defense project.
The goal of this project is to create a complete infrastructure, able to host an Attack/Defense challenge, using Infrastructure As Code (IaC) tools.  
The provisioning is handled by Terraform and the machine configuration is handled by Ansible.

## Requirements

- [Python3](https://www.python.org/)
- [Terraform](https://developer.hashicorp.com/terraform)
- [Ansible](https://www.ansible.com/)

Depending on the provider you want to use, you may need to install the corresponding CLI to handle the authentication.

- [AWS CLI](https://aws.amazon.com/cli/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstarts)
- [OpenStack CLI](https://docs.openstack.org/newton/user-guide/common/cli-install-openstack-command-line-clients.html)

## Topology

```mermaid
---
title: Cloud Topology
---
flowchart LR

i((Internet))
n((NAT))

subgraph net[Network - 192.168.0.0/16]

    subgraph lr[Subnet R - 192.168.0.0/24]
        r{{router\n192.168.0.1}}
    end

    subgraph ls[Subnet S - 192.168.1.0/24]
        s[Server\n192.168.1.1]
    end

    subgraph lv[Subnet V - 192.168.2.0/24]
        v1[Vulnbox 1\n192.168.2.1]
        v2[Vulnbox 2\n192.168.2.2]
        v3[Vulnbox 3\n192.168.2.3]
    end

end

    i <--> r --- lv & ls
    lv & ls --> n
```

```mermaid
---
title: VPN Topology
---
flowchart TB

subgraph net[Network - 10.0.0.0/8]

    subgraph lr[Subnet R - 10.0.0.1/32]
        r{{router\n10.0.0.1}}
    end

    subgraph ls[Subnet S - 10.10.0.0/16]
        s[Server\n10.10.0.1]
    end

    subgraph lv[Subnet V - 10.60.0.0/16]
        v1[Vulnbox 1\nTeam 1\n10.60.1.1]
        v2[Vulnbox 2\nTeam 2\n10.60.2.1]
        v3[Vulnbox 3\nTeam 3\n10.60.3.1]
    end

    subgraph lp[Subnet P - 10.80.0.0/16]
        p1[Player 1\nTeam 1\n10.80.1.1]
        p2[Player 2\nTeam 1\n10.80.1.2]
        p3[Player 1\nTeam 2\n10.80.2.1]
        p4[Player 2\nTeam 2\n10.80.2.2]
        p5[Player 1\nTeam 3\n10.80.3.1]
    end

end

    r --- lv & ls & lp
```

## Configuration

### Terraform

The suggested way to configure Terraform is creating a _terraform.tfvars_ file in the _terraform/\<provider\>_ folder.  
See the _terraform.tfvars.example_ file for an example.

A list of all the variables that can be configured can be found in the _variables.tf_ file in the same folder.

### Ansible

The suggested way to configure Ansible is creating an _inventory.yml_ file in the _ansible_ folder.

See the _inventory.yml.example_ file for an example.

## Usage

### Using the run.sh script

In the root of the project, there is a script called _run.sh_.
It is used to simplify the usage of Terraform and Ansible with this project.

```shell
# Create the infrastructure
./run.sh apply -p <provider>
# Example
./run.sh apply -p aws
```

```shell
# Destroy the infrastructure
./run.sh destroy -p <provider>
# Example
./run.sh destroy -p aws
```

```shell
# Using the outputs from Terraform to configure
# hosts and private keys
./run.sh outputs -p <provider>
# Example
./run.sh outputs -p aws
```

```shell
# Setup all the hosts
./run.sh setup
```

```shell
# Force start wireguard on all the hosts
./run.sh wireguard
```

### Manual setup

Although the _run.sh_ script is the recommended way to use this project, it is possible to use Terraform and Ansible manually.
Make sure the working directory is the correct one before running the commands.

#### Terraform

Folder _terraform/\<provider\>_.

```shell
# Initialize Terraform, download the providers and modules
terraform init
```

```shell
# Create the infrastructure
terraform apply
```

```shell
# Destroy the infrastructure
terraform destroy
```

#### Ansible

Folder _ansible_.

```shell
# Setup all the hosts
ansible-playbook -i inventory.yml main.yml
```

```shell
# Force start wireguard on all the hosts
ansible-playbook -i inventory.yml wireguard_start.yml
```
