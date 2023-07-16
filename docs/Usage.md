# Usage

In the root of the project, there are two scripts, called _run.sh_ and _run.py_.
Both support the same functions, and are meant to simplify the usage of Terraform and Ansible with this project.  
The _run.sh_ script may be faster, but it requires Bash
The _run.py_ script requires Python3, but is more portable and has more features.

## Requirements

Running ansible and the _run.py_ script require installing some dependencies via pip.
All requirements are listed in the _requirements.txt_ file.  
Even when using the _run.sh_ script, it is recommended to install the dependencies, as they include _ansible_.  
The installation can be either system-wide or in a virtual environment.

```shell
pip3 install -r requirements.txt
```

## Commands

For a more in depth explanation of the commands, run the script with the _-h_ flag.

````shell
# Show the help
./run.py -h

```shell
# Run all the commands in sequence to create the infrastructure
./run.py all -p <provider>
````

### Single commands

```shell
# Create the infrastructure
./run.py terraform init -p <provider>
```

```shell
# Create the infrastructure
./run.py terraform apply -p <provider>
```

```shell
# Destroy the infrastructure
./run.py terraform destroy -p <provider>
```

```shell
# Using the outputs from Terraform to configure
# hosts and private keys
./run.py terraform out -p <provider>
```

```shell
# Adds all the remote hosts to the known hosts
./run.py connect fingerprint
```

```shell
# Starts the setup process on all the hosts
./run.py ansible playbook
```

```shell
# Bootstraps wireguard on all the hosts
./run.py ansible up
```

```shell
# Shuts down wireguard on all the hosts
./run.py ansible down
```

## Examples

### Single step

```shell
# Create the infrastructure on AWS
./run.py terraform apply -p aws
# Add the terraform outputs,
# including ips and private keys,
# to the ansible inventory
./run.py terraform out -p aws
# Add the hosts to the known hosts
./run.py connect fingerprint
# Run the ansible playbook
./run.py ansible playbook
```

### All in one

```shell
./run.py all -p aws
```

## Manual setup

Although the _run.sh_ script is the recommended way to use this project, it is possible to use Terraform and Ansible manually.
Make sure the working directory is the correct one before running the commands.
