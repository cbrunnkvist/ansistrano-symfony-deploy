#!/bin/sh
# quick hack: must be invoked while standing in the root of the of the project
ANSIBLE_CONFIG=tests/ansible.cfg ansible-playbook -i tests/inventory tests/test.yml
