#!/bin/bash
set -e

display_usage() {
    echo -e "\nYou can override some variables from in .env file using the \n"
    echo -e "following paramters."
    echo -e "\nUsage: $0 -i [image version] -v [source vm] -r [resource group]  \n"
    echo -e "Example: $0 -i 1.0.0 -v myvm -r vm-rg \n"
    echo -e "Use -f or --confirm to run without confirmation.\n"
}

current_dir=$(pwd)
script_name=$(basename "${BASH_SOURCE[0]}")
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
script_dir_name=$(basename $script_dir)
ansible_dir=$script_dir/ansible

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -i|--imageversion)
    IMAGEVERSION="$2"
    shift # past argument
    shift # past value
    ;;
    -v|--vm)
    VMNAME="$2"
    shift # past argument
    shift # past value
    ;;
    -r|--resourcegroup)
    RESOURCEGROUP="$2"
    shift # past argument
    shift # past value
    ;;
    -h|--help)
    HELP="yes"
    shift # past argument
    ;;
    -f|--confirm)
    CONFIRM="yes"
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "$HELP" == "yes" ]
then
  display_usage
  exit 1
fi

if [ -z $azure_sig_resource_group_name ]
then
  echo -e "\nIt seems that you have not sourced your environment variables, yet.\n"
  echo -e "Please run first: source .env\n"
  exit 1
fi

if ! [ -z ${IMAGEVERSION} ]
then
    # display_usage
    # exit 1
    export azure_sig_image_version_name=${IMAGEVERSION}
fi

if ! [ -z ${VMNAME} ]
then
    # display_usage
    # exit 1
    export azure_source_vm_name=${VMNAME}
fi

if ! [ -z ${RESOURCEGROUP} ]
then
    # display_usage
    # exit 1
    export azure_source_resource_group_name=${RESOURCEGROUP}
fi

echo "--------------------"
echo "version: $azure_sig_image_version_name"
echo "vm: $azure_source_vm_name"
echo "resource group: $azure_source_resource_group_name"
echo "--------------------"


if [ "$CONFIRM" == "yes" ]
then
  echo "starting..."
  cd $ansible_dir
  ansible-playbook -i inventory playbook.yml
  cd $current_dir

else
  read -p "Are you sure (y)? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "starting..."
    cd $ansible_dir
    ansible-playbook -i inventory playbook.yml
    cd $current_dir
  else
    echo "canceled."
  fi
fi
