#!/bin/bash
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [OPTIONS] command action [additional arguments]
#%
#% DESCRIPTION
#%    Handles all the steps to setup the infrastructure.
#%
#% ARGUMENTS
#%   command                      The command to perform. It requires to specify an action. Valid options are: [terraform, ansible, connect]
#%   action                       The action to perform. Depends on the command specified.
#%   [additional arguments]       Additional arguments to pass to the invoked action
#%
#% OPTIONS
#%   -h, --help                   Help section
#%   -v, --version                Script information
#%   -y, --yes                    Automatically answer yes to any questions. Use with caution!
#%   -n, --no-color               Disable color output
#%   -i --inventory <FILE>        Inventory file where to store the terraform outputs or where to get the information from. Defaults to inventory.yml
#%   --router_key <FILE>          Path to the private key to use to connect to the router instance. Defaults to router.pem
#%   --server_key <FILE>          Path to the private key to use to connect to the server instance. Defaults to server.pem
#%
#% terraform
#%   ACTIONS:
#%     init                       Initialise the Terraform working directory
#%     apply                      Apply the changes required to reach the desired state of the configuration
#%     destroy                    Destroy the Terraform-managed infrastructure
#%     out                        Gather the terraform outputs and saves them in the ansible inventory files, to be used later
#%   OPTIONS:
#%     -p  --provider <PROVIDER>  The provider to use. Valid options are: [aws, azure, openstack].
#%
#% connect
#%   ACTIONS:
#%     router                     Connect to the router instance via SSH. Requires the outputs to be gathered first
#%     server                     Connect to the server instance via SSH. Requires the outputs to be gathered first
#%     1-n                        Connect to the n-th vulnbox instance via SSH. Requires the outputs to be gathered first
#%     fingerprint                Stores the fingerprint of all remote instances in the known_hosts file. Requires the outputs to be gathered first
#%   OPTIONS:
#%     -p  --provider <PROVIDER>  The provider to use. Valid options are: [aws, azure, openstack].
#%
#% ansible
#%   ACTIONS:
#%     playbook                   Run the playbook on the remote instances. Requires the outputs to be gathered first
#%     start                      Start wireguard on the remote instances. Requires the outputs to be gathered first
#%     stop                       Stop wireguard on the remote instances. Requires the outputs to be gathered first
#%   OPTIONS:
#%     --ask-vault-pass              Ansible will ask for a password to decrypt the vault with
#%     --vault-password-file <FILE>  Ansible will use the provided file to decrypt the vault with
#%
#% EXAMPLES
#%    ${SCRIPT_NAME} apply
#%
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} 0.0.1
#-    author          TendTo
#-    copyright       Copyright (c) https://github.com/TendTo
#-    license         GNU General Public License
#-
#================================================================
# END_OF_HEADER
#================================================================


# DESC: Usage help and version info
# ARGS: None
# OUTS: None
# NOTE: Used to document the usage of the script
#       and to display its version when requested or
#       if some arguments are not valid
usage() { printf "Usage: "; head -${script_headsize:-99} ${0} | grep -e "^#+" | sed -e "s/^#+[ ]*//g" -e "s/\${SCRIPT_NAME}/${script_name}/g" ; }
usagefull() { head -${script_headsize:-99} ${0} | grep -e "^#[%+-]" | sed -e "s/^#[%+-]//g" -e "s/\${SCRIPT_NAME}/${script_name}/g" ; }
scriptinfo() { head -${script_headsize:-99} ${0} | grep -e "^#-" | sed -e "s/^#-//g" -e "s/\${SCRIPT_NAME}/${script_name}/g"; }

# DESC: Generic script initialisation
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: $orig_cwd: The current working directory when the script was run
#       $script_path: The full path to the script
#       $script_dir: The directory path of the script
#       $script_name: The file name of the script
#       $script_params: The original parameters provided to the script
#       $ta_none: The ANSI control code to reset all text attributes
# NOTE: $script_path only contains the path that was used to call the script
#       and will not resolve any symlinks which may be present in the path.
#       You can use a tool like realpath to obtain the "true" path. The same
#       caveat applies to both the $script_dir and $script_name variables.
function script_init() {
    # Useful variables
    readonly orig_cwd="$PWD"
    readonly script_params="$*"
    readonly script_path="${BASH_SOURCE[0]}"
    script_dir="$(dirname "$script_path")"
    script_name="$(basename "$script_path")"
    readonly script_dir script_name
    readonly ta_none="$(tput sgr0 2> /dev/null || true)"
    readonly script_headsize=$(head -200 ${0} |grep -n "^# END_OF_HEADER" | cut -f1 -d:)
}

# DESC: Initialise colour variables
# OUTS: Read-only variables with ANSI control codes
# NOTE: If --no-color was set the variables will be empty. The output of the
#       $ta_none variable after each tput is redundant during normal execution,
#       but ensures the terminal output isn't mangled when running with xtrace.
function color_init() {
    # Text attributes
    readonly ta_bold="$(tput bold 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_uscore="$(tput smul 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_blink="$(tput blink 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_reverse="$(tput rev 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_conceal="$(tput invis 2> /dev/null || true)"
    printf '%b' "$ta_none"

    # Foreground codes
    readonly fg_black="$(tput setaf 0 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_blue="$(tput setaf 4 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_cyan="$(tput setaf 6 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_green="$(tput setaf 2 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_magenta="$(tput setaf 5 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_red="$(tput setaf 1 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_white="$(tput setaf 7 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_yellow="$(tput setaf 3 2> /dev/null || true)"
    printf '%b' "$ta_none"

    # Background codes
    readonly bg_black="$(tput setab 0 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_blue="$(tput setab 4 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_cyan="$(tput setab 6 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_green="$(tput setab 2 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_magenta="$(tput setab 5 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_red="$(tput setab 1 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_white="$(tput setab 7 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_yellow="$(tput setab 3 2> /dev/null || true)"
    printf '%b' "$ta_none"
}

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
function parse_args() {
    # Local variable
    local param
    # Positional args
    local args=()

    # Named args
    yes=''
    ask_vault_pass=''
    vault_pass_file=''
    provider=''
    terraform_yes=''
    router_key='router.pem'
    server_key='server.pem'
    inventory_file='inventory.yml'

    # nNmed args
    while [ $# -gt 0 ]; do
        param="$1"
        shift
        case "$param" in
            -h )
                usage
                exit 0
            ;;
            --help )
                usagefull
                exit 0
            ;;
            -v | --version )
                scriptinfo
                exit 0
            ;;
            -n | --no-color)
                no_color=1
            ;;
            -p | --provider )
                provider="$1"
                shift
            ;;
            -i | --inventory )
                inventory_file="$1"
                shift
            ;;
            --router-key )
                router_key="$1"
                shift
            ;;
            --server-key )
                server_key="$1"
                shift
            ;;
            --ask-vault-pass )
                ask_vault_pass="--ask-vault-pass"
            ;;
            --vault-pass-file )
                vault_pass_file="--vault-pass-file $1"
                shift
            ;;
            -y | --yes)
                yes='1'
                terraform_yes="-auto-approve"
            ;;
            * )
                args+=("$param")
            ;;
        esac
    done

    # Restore positional args
    set -- "${args[@]}"

    # set positionals to vars
    command="${args[0]}"
    action="${args[1]}"
    additional_args="${args[@]:2}"
}

# DESC: Verify the user wants to continue asking (y/n)
# ARGS: $1: Message to display
function confirm() {
    local message="$1"
    if [[ -z "${yes}" ]]; then
        read -p "${message}${ta_bold}Continue?${ta_none} ${ta_uscore}[y/N]${ta_none} " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            >&2 echo "Operation aborted by user"
            exit 1
        fi
    fi
}

# DESC: Validate provider
# ARGS: $1: Provider
function validate_provider() {
    local provider="$1"
    if [[ -z "${provider}" ]]; then
        >&2 echo "ERROR: Missing provider"
        usage
        exit 1
    fi
    if [[ ! -d "${script_dir}/terraform/${provider}" ]]; then
        >&2 echo "ERROR: Provider '${provider}' folder not found.
        Make sure the path exists: '${script_dir}/terraform/${provider}'"
        usage
        exit 1
    fi
}

# DESC: Parse multiple keys from the terraform output
# ARGS: $1 array to popolate with each key
#       $2 list of keys generated by the terraform output
# OUT:  Array of vulnbox keys as the first parameter
function parse_vulnbox_keys() {
    local -n keys=$1
    local current_key=""
    while read -r line; do
        if [[ $line == *"-----BEGIN"* ]]; then
            current_key=$line$'\n'
        elif [[ $line == *"-----END"* ]]; then
            current_key+=$line
            if [[ $current_key != "" ]]; then
                keys+=("$current_key")
            fi
        else
            current_key+=$line$'\n'
        fi
    done <<< "$2"
}

# DESC: Parse multiple IPs from the terraform output
# ARGS: $1 array to popolate with each ip
#       $2 list of ips generated by the terraform output
# OUT:  Array of vulnbox ips as the first parameter
function parse_vulnbox_ips() {
    local -n ips=$1
    local current_key=""
    while read -r line; do
        if [[ $line == *',' ]]; then
            str="${line#*\"}"
            str="${str%\"*} "
            ips+=($str)
        fi
    done <<< "$2"
}

# DESC: Create the infrastructure using Terraform
function fun_terraform_init() {
    pushd "${script_dir}/terraform/${provider}"
    echo "Start terraform init"
    terraform init $additional_args $terraform_yes
    popd
}

# DESC: Create the infrastructure using Terraform
function fun_terraform_apply() {
    pushd "${script_dir}/terraform/${provider}"
    echo "Start terraform apply"
    terraform apply $additional_args $terraform_yes
    popd
}

# DESC: Destroy all the infrastructure created by terraform
function fun_terraform_destroy() {
    pushd "${script_dir}/terraform/${provider}"
    echo "Start terraform destroy"
    terraform destroy $additional_args $terraform_yes
    popd
}

# DESC: Gather the outputs from terraform and prepare the ansible inventory
function fun_terraform_out() {
    pushd "${script_dir}/terraform/${provider}"
    local private_key_router=$(terraform output -raw private_key_router)
    local private_key_vulnbox=$(terraform output private_key_vulnbox)
    local private_key_server=$(terraform output -raw private_key_server)

    local router_public_ip=$(terraform output -raw public_ip_router)
    local vulnbox_private_ip=$(terraform output private_ip_vulnbox)
    local server_private_ip=$(terraform output -raw private_ip_server)
    local router_private_ip=$(terraform output -raw private_ip_router)
    popd

    parse_vulnbox_keys vulnbox_keys "${private_key_vulnbox}"
    parse_vulnbox_ips vulnbox_ips "${vulnbox_private_ip}"

    pushd "${script_dir}/ansible"

    # Update the inventory file with the public ip of the router
    sed -ri "s/(ansible_host:)[^#]*(# router)/\1 ${router_public_ip} \2/g" ${inventory_file}
    # Update any ipv4 address with the router public ip in the ProxyCommand line
    sed -ri "s/(ProxyCommand[^@]+@)[^ \"']*(.+)/\1${router_public_ip}\2/g" ${inventory_file}
    # Update the inventory file with the private ip of the router
    sed -ri "s/(private_ip:)[^#]*/\1 ${router_private_ip}/g" ${inventory_file}
    # Update the inventory file with the private ip of the server
    sed -ri "s/(ansible_host:)[^#]*(# server)/\1 ${server_private_ip} \2/g" ${inventory_file}
    # Update the inventory file with the private ips of all the vuonboxes
    for (( j=0; j<${#vulnbox_ips[@]}; j++ )); do
        let "vulnbox_id = $j + 1"
        sed -ri "s/(ansible_host:)[^#]*(# vulnbox$vulnbox_id)/\1 ${vulnbox_ips[$j]} \2/g" ${inventory_file}
    done

    mkdir -p "keys"
    # Create the key for the router
    echo "${private_key_router}" > "keys/${router_key}"
    chmod 600 "keys/${router_key}"
    # Create the key for the server
    echo "${private_key_server}" > "keys/${server_key}"
    chmod 600 "keys/${server_key}"
    # Create the key for each vulnbox
    for (( j=0; j<${#vulnbox_keys[@]}; j++ )); do
        let "vulnbox_id = $j + 1"
        echo "${vulnbox_keys[$j]}" > "keys/vulnbox${vulnbox_id}.pem"
        chmod 600 "keys/vulnbox${vulnbox_id}.pem"
    done

    popd
}

# DESC: Use Ansible to setup all the remote machines
function fun_ansible_playbook() {
    confirm "Start wireguard installation. "
    pushd "${script_dir}/ansible"
    ansible-playbook main.yml -i ${inventory_file} ${ask_vault_pass} ${vault_pass_file} $additional_args 
    popd
}

# DESC: Use Ansible to start wireguard
function fun_ansible_up() {
    confirm "Start wireguard. "
    pushd "${script_dir}/ansible"
    ansible-playbook wireguard_start.yml -i ${inventory_file} ${ask_vault_pass} ${vault_pass_file} $additional_args 
    popd
}

# DESC: Use Ansible to stop wireguard
function fun_ansible_down() {
    confirm "Stop wireguard. "
    pushd "${script_dir}/ansible"
    ansible-playbook wireguard_stop.yml -i ${inventory_file} ${ask_vault_pass} ${vault_pass_file} $additional_args 
    popd
}

# DESC: Connect to the router via ssh
function fun_connect_router() {
    pushd "${script_dir}/ansible"
    local router_ip=$(grep -oP '(?<=ansible_host: ) *[^# ]+(?= *# router)' ${inventory_file} | xargs)
    ssh -i "keys/${router_key}" ubuntu@$router_ip
    popd
}

# DESC: Connect to the server via ssh
function fun_connect_server() {
    pushd "${script_dir}/ansible"
    local server_ip=$(grep -oP '(?<=ansible_host: ) *[^# ]+(?= *# server)' ${inventory_file} | xargs)
    local router_ip=$(grep -oP '(?<=ansible_host: ) *[^# ]+(?= *# router)' ${inventory_file} | xargs)
    ssh -i "keys/${server_key}" -o ProxyCommand="ssh -i keys/${router_key} -W %h:%p ubuntu@$router_ip" ubuntu@$server_ip
    popd
}

# DESC: Connect to the i-th vulnbox via ssh
function fun_connect_vulnbox() {
    pushd "${script_dir}/ansible"
    local vulnbox_ip=$(grep -oP "(?<=ansible_host: ) *[^# ]+(?= *# vulnbox${action})" ${inventory_file} | xargs)
    local router_ip=$(grep -oP '(?<=ansible_host: ) *[^# ]+(?= *# router)' ${inventory_file} | xargs)
    ssh -i "keys/vulnbox${action}.pem" -o ProxyCommand="ssh -i keys/${router_key} -W %h:%p ubuntu@$router_ip" ubuntu@$vulnbox_ip
    popd
}

# DESC: Add the fingerprints of the remote machines to the known_hosts file
function fun_connect_fingerprint() {
    pushd "${script_dir}/ansible"
    local server_ip=$(grep -oP '(?<=ansible_host: ) *[^# ]+(?= *# server)' ${inventory_file} | xargs)
    local router_ip=$(grep -oP '(?<=ansible_host: ) *[^# ]+(?= *# router)' ${inventory_file} | xargs)
    local vulnbox_ips=$(grep -oP "(?<=ansible_host: ) *[^# ]+(?= *# vulnbox)" ${inventory_file} | xargs)
    # Get the fingerprint of the router
    ssh-keyscan $router_ip >> ~/.ssh/known_hosts
    # Use the bastion host to get the fingerprint of the server and the vulnboxes
    ssh -i "keys/${router_key}" ubuntu@$router_ip "ssh-keyscan -t rsa $server_ip $vulnbox_ips" >> ~/.ssh/known_hosts
    popd
}

# DESC: terraform sub command
function sub_command_terraform() {
    validate_provider "${provider}"

    case "${action}" in
        init )
            fun_terraform_init
        ;;
        apply )
            fun_terraform_apply
        ;;
        destroy )
            fun_terraform_destroy
        ;;
        out )
            fun_terraform_out
        ;;
        * )
            if [[ -z "${action}" ]]; then
                >&2 echo "ERROR: Missing sub-command for terraform"
            else
                >&2 echo "ERROR: Invalid sub-command '${action}' for terraform"
            fi
            usage
            exit 1
    esac
}

# DESC: connect sub command
function sub_command_connect() {
    case "${action}" in
        router )
            fun_connect_router
        ;;
        server )
            fun_connect_server
        ;;
        fingerprint )
            fun_connect_fingerprint
        ;;
        [0-9] )
            fun_connect_vulnbox
        ;;
        [0-9][0-9] )
            fun_connect_vulnbox
        ;;
        [0-9][0-9][0-9] )
            fun_connect_vulnbox
        ;;
        * )
            if [[ -z "${action}" ]]; then
                >&2 echo "ERROR: Missing sub-command for connect"
            else
                >&2 echo "ERROR: Invalid sub-command '${action}' for connect"
            fi
            usage
            exit 1
    esac
}

# DESC: ansible sub command
function sub_command_ansible() {
    case "${action}" in
        playbook )
            fun_ansible_playbook
        ;;
        up )
            fun_ansible_up
        ;;
        down )
            fun_ansible_down
        ;;
        * )
            if [[ -z "${action}" ]]; then
                >&2 echo "ERROR: Missing sub-command for ansible"
            else
                >&2 echo "ERROR: Invalid sub-command '${action}' for ansible"
            fi
            usage
            exit 1
    esac
}

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
function main() {
    script_init "$@"
    parse_args "$@"

    if [[ -z "${no_color}" ]]; then
        color_init
    fi

    case "${command}" in
        terraform )
            sub_command_terraform
        ;;
        connect )
            sub_command_connect
        ;;
        ansible )
            sub_command_ansible
        ;;
        * )
            if [[ -z "${command}" ]]; then
                >&2 echo "ERROR: Missing command"
            else
                >&2 echo "ERROR: Invalid command '${command}'"
            fi
            usage
            exit 1
    esac
}

# Invoke main with args if not sourced
if ! (return 0 2> /dev/null); then
    main "$@"
fi
