#!/bin/bash
set -euo pipefail

# Bootstrap for Ansible over SSM (Nginx is configured by Ansible, not here).
dnf install -y python3 amazon-ssm-agent
systemctl enable --now amazon-ssm-agent
