#!/bin/bash
# Generates the SSH keypair the controller uses to authenticate to remote agents.
set -e

mkdir -p ssh-keys
if [ -f ssh-keys/id_rsa ]; then
  echo "ssh-keys/id_rsa already exists — skipping generation."
else
  ssh-keygen -t rsa -b 4096 -f ssh-keys/id_rsa -N "" -C "jenkins-agent-key"
  chmod 600 ssh-keys/id_rsa
  echo "Keypair generated in ./ssh-keys/"
fi

echo ""
echo "Before running docker-compose up, export the public key so the agent"
echo "containers can bake it in as an authorized key:"
echo ""
echo "  export SSH_PUBKEY=\$(cat ssh-keys/id_rsa.pub)"
echo "  docker-compose up --build"
