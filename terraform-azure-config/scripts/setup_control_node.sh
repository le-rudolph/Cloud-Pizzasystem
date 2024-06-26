#!/bin/bash
set -e

myip="$(ip a | grep -A 3 eth0 | grep "inet " | egrep '[0-9]+\.[0-9]+\.[0-9]+.[0-9+\]' -o | head -1)"
remote="10.0.2.4"
remoteUser="pizza"

if [ "$myip" = "$remote" ]; then
  remote="10.0.2.5"
fi

echo "This machine: $myip"
echo "Other machine: $remote"

echo "0. Preparing SSH"

regex="<ns1:CustomData>(.+)</ns1:CustomData>"
customData="$(</var/lib/waagent/ovf-env.xml)"
if [[ $customData =~ $regex ]]; then
  mkdir ~/.ssh 2> /dev/null || true
  echo "${BASH_REMATCH[1]}" | base64 -d > ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
else
  echo "Error: No SSH private key provisioned, cannot set up other machine."
  exit 1
fi

echo "1. Installing K3S on this node."
curl -sfL https://get.k3s.io | sh -
kubectl version

echo "2. Installing K3S on other node."
token="$(cat /var/lib/rancher/k3s/server/node-token)"
touch ~/.ssh/known_hosts
ssh -o StrictHostKeyChecking=accept-new "${remoteUser}@${remote}" "curl -sfL https://get.k3s.io | K3S_URL=https://${myip}:6443 K3S_TOKEN=${token} sh -"
kubectl get nodes

echo "3. Deploying Pizza."
apt install -y git
if [ -e Cloud-Pizzasystem ]; then
  rm -rf Cloud-Pizzasystem
fi
git clone https://github.com/le-rudolph/Cloud-Pizzasystem
kubectl apply -f "Cloud-Pizzasystem/*.yaml"

kubectl get pods
kubectl get services

echo "4. Exposing Pizza."

sleep 20
if ! kubectl get service produktservice-extern; then
  kubectl expose deployment produktservice --type=LoadBalancer --name=produktservice-extern
fi
kubectl get service produktservice-extern

if ! kubectl get service bestellservice-extern; then
  kubectl expose deployment bestellservice --type=LoadBalancer --name=bestellservice-extern
fi
kubectl get service bestellservice-extern
