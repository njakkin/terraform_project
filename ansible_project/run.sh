#!/bin/bash
ansible-playbook -i ./hosts ec2_setup.yaml && ansible-playbook -i ./hosts ec2_python.yaml