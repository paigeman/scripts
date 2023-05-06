kubeadm init \
--apiserver-advertise-address=192.168.52.130 \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.27.1 \
--service-cidr=10.96.0.0/12 \
--pod-network-cidr=10.244.0.0/16 \
--cri-socket=unix:///var/run/cri-dockerd.sock
# for root user
cd
cat >> .bash_profile << EOF
export KUBECONFIG=/etc/kubernetes/admin.conf
EOF
source .bash_profile
kubectl get nodes