#!/bin/bash
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [OPTIONS] action [additional arguments]
#%
#% DESCRIPTION
#%    Handles all the steps to setup the infrastructure.
#%
#% ARGUMENTS
#%    action                        The action to perform. Valid options are: [apply, destroy, output, setup]
#%    [additional arguments]        Additional arguments to pass to the invoked action
#%
#% OPTIONS
#%
#%  GENERAL
#%    -h, --help                    Help section
#%    -v, --version                 Script information
#%    -y, --yes                     Automatically answer yes to any questions. Use with caution!
#%    -n, --no-color                Disble color output
#%
#%  TERRAFORM
#%    -p  --provider <PROVIDER>     The provider to use. Valid options are: [aws].
#%
#%  ANSIBLE
#%    --ask-vault-pass              Ansible will ask for a password to decrypt the vault with
#%    --vault-password-file <FILE>  Ansible will use the provided file to decrypt the vault with
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
function parse_args
{
    # Local variable
    local param
    # Positional args
    local args=()

    # Named args
    yes=0
    ask_vault_pass=""
    vault_pass_file=""
    provider=""
    terraform_yes=""
    router_key="router.pem"
    server_key="server.pem"

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
            --ask-vault-pass )
                ask_vault_pass="--ask-vault-pass"
            ;;
            --vault-pass-file )
                vault_pass_file="--vault-pass-file $1"
                shift
            ;;
            -y | --yes)
                yes=1
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
    action="${args[0]}"
    additional_args="${args[@]:1}"

    # Validate required args
    if [[ -z "${action}" ]]; then
        >&2 echo "ERROR: Missing action"
        usage
        exit 1
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
    if ! [[ "${provider}" =~ ^(aws|azure|gcp)$ ]]; then
        >&2 echo "ERROR: Invalid provider '${provider}'"
        usage
        exit 1
    fi
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

# DESC: Parse multiple keys from the terraform output
# ARGS: $1 array to popolate with each key
#       $2 list of keys generated by the terraform output
# OUT:  Array of vulnbox keys as the first parameter
function parse_vulnbox_keys() {
    local -n keys=$1
    local current_key=""
    while read -r line; do
        if [[ $line == *"-----BEGIN OPENSSH PRIVATE KEY-----"* ]]; then
            current_key="-----BEGIN OPENSSH PRIVATE KEY-----
"
        elif [[ $line == *"-----END OPENSSH PRIVATE KEY-----"* ]]; then
            current_key+="-----END OPENSSH PRIVATE KEY-----"
            if [[ $current_key != "" ]]; then
                keys+=("$current_key")
            fi
        else
            current_key+="$line
"
        fi
    done <<< "$2"
}

function fun_terraform_outputs() {
    validate_provider "${provider}"

    pushd "${script_dir}/terraform/${provider}"
    private_key_router=$(terraform output -raw private_key_router)
    private_key_vulnbox=$(terraform output private_key_vulnbox)
    private_key_server=$(terraform output -raw private_key_server)

    router_public_ip=$(terraform output -raw public_ip_router)
    vulnbox_private_ip=$(terraform output private_ip_vulnbox)
    server_private_ip=$(terraform output -raw private_ip_server)
    popd

    parse_vulnbox_keys vulnbox_keys "${private_key_vulnbox}"

    pushd "${script_dir}/ansible"
    for (( j=0; j<${#vulnbox_keys[@]}; j++ )); do
        let "vulnbox_id = $j + 1"
        echo "${vulnbox_keys[$j]}" > "keys/vulnbox${vulnbox_id}.pem"
        chmod 600 "keys/vulnbox${vulnbox_id}.pem"
    done

    # Update the inventory file with the public ip of the router
    sed -ri "s/(ansible_host: *)[^#\n]+(# router)/\1${router_public_ip} \2/g" inventory.yml
    # sub any ipv4 address with the router public ip in the ProxyCommand line
    sed -ri "s/(ProxyCommand[^@]+@)[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(.+)/\1${router_public_ip}\2/g" inventory.yml
    # Update the inventory file with the private ip of the server
    sed -ri "s/(ansible_host: *)[^#\n]+(# server)/\1${server_private_ip} \2/g" inventory.yml

    mkdir -p "keys"
    # Create the key for the router
    echo "${private_key_router}" > "keys/${router_key}"
    chmod 600 "keys/${router_key}"
    # Create the key for the server
    echo "${private_key_server}" > "keys/${server_key}"
    chmod 600 "keys/${server_key}"
    popd
}

# DESC: Create the infrastructure using Terraform
function fun_terraform_apply() {
    validate_provider "${provider}"

    pushd "${script_dir}/terraform/${provider}"
    echo "Start terraform apply"
    terraform apply $additional_args $terraform_yes
    popd
}

# DESC: Destroy all the infrastructure created by terraform
function fun_terraform_destroy() {
    validate_provider "${provider}"

    pushd "${script_dir}/terraform/${provider}"
    echo "Start terraform destroy"
    terraform destroy $additional_args $terraform_yes
    popd
}

# DESC: Use Ansible to install and configure wireguard on the server
function fun_ansible() {
    confirm "Start wireguard installation. "
    pushd "${script_dir}/ansible"
    ansible-playbook main.yml -i inventory.yml ${ask_vault_pass} ${vault_pass_file} $additional_args 
    popd
}

# DESC: Use Ansible to start wireguard
function fun_wireguard() {
    confirm "Start wireguard installation. "
    pushd "${script_dir}/ansible"
    ansible-playbook wireguard_start.yml -i inventory.yml ${ask_vault_pass} ${vault_pass_file} $additional_args 
    popd
}

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
function main() {
    script_init "$@"
    parse_args "$@"

    if [[ -z "${no_color}" ]]; then
        color_init
    fi

    case "${action}" in
        apply )
            fun_terraform_apply
        ;;
        destroy )
            fun_terraform_destroy
        ;;
        outputs )
            fun_terraform_outputs
        ;;
        setup )
            fun_ansible
        ;;
        wireguard )
            fun_wireguard
        ;;
        * )
            >&2 echo "ERROR: Invalid action '${action}'"
            usage
            exit 1
    esac
}

# Invoke main with args if not sourced
if ! (return 0 2> /dev/null); then
    main "$@"
fi
