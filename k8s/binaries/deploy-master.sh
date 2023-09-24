K8S_DIR=/root/kubernetes/server
CERT_DIR=/root/k8s-cert
systemctl stop k8s-apiserver
systemctl disable k8s-apiserver
systemctl stop k8s-controller-manager
systemctl disable k8s-controller-manager
systemctl stop k8s-scheduler
systemctl disable k8s-scheduler
cd ${K8S_DIR}
mkdir -p conf
cat > conf/token.csv << EOF
$(head -c 16 /dev/urandom | od -An -t x | tr -d ' '),kubelet-bootstrap,10001,"system:node-bootstrapper"
EOF
cat > conf/api-server.conf << EOF
API_SERVER_OPTS="--v=2  \\
      --allow-privileged=true  \\
      --bind-address=192.168.52.136  \\
      --secure-port=6443  \\
      --advertise-address=192.168.52.136 \\
      --service-cluster-ip-range=10.96.0.0/12  \\
      --service-node-port-range=30000-42767  \\
      --etcd-servers=https://192.168.52.136:2379,https://192.168.52.138:2379 \\
      --etcd-cafile=${CERT_DIR}/ca.pem  \\
      --etcd-certfile=${CERT_DIR}/etcd.pem  \\
      --etcd-keyfile=${CERT_DIR}/etcd-key.pem  \\
      --client-ca-file=${CERT_DIR}/ca.pem  \\
      --tls-cert-file=${CERT_DIR}/kubernetes.pem  \\
      --tls-private-key-file=${CERT_DIR}/kubernetes-key.pem  \\
      --kubelet-client-certificate=${CERT_DIR}/kubernetes.pem  \\
      --kubelet-client-key=${CERT_DIR}/kubernetes-key.pem  \\
      --service-account-key-file=${CERT_DIR}/ca.pem  \\
      --service-account-signing-key-file=${CERT_DIR}/ca-key.pem \\
      --service-account-issuer=api \\
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  \\
      --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota  \\
      --authorization-mode=Node,RBAC  \\
      --enable-bootstrap-token-auth=true  \\
      --token-auth-file=${K8S_DIR}/conf/token.csv \\
      --audit-log-maxage=30 \\
      --audit-log-maxbackup=3 \\
      --audit-log-maxsize=100 \\
      --audit-log-path=${K8S_DIR}/log"
EOF
cat > conf/controller-manager.conf << EOF
CONTROLLER_MANAGER_OPTS="--v=2 \\
      --master=https://192.168.52.136:6443 \\
      --service-cluster-ip-range=10.96.0.0/12 \\
      --root-ca-file=${CERT_DIR}/ca.pem \\
      --cluster-signing-cert-file=${CERT_DIR}/ca.pem \\
      --cluster-signing-key-file=${CERT_DIR}/ca-key.pem \\
      --service-account-private-key-file=${CERT_DIR}/ca-key.pem \\
      --leader-elect=true \\
      --allocate-node-cidrs=true \\
      --cluster-cidr=10.244.0.0/16"
EOF
cat > conf/scheduler.conf << EOF
SCHEDULER_OPTS="--v=2 \\
      --master=https://192.168.52.136:6443 \\
      --leader-elect=true"
EOF
mkdir -p services
cat > services/k8s-apiserver.service << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Wants=docker.service
 
[Service]
EnvironmentFile=-${K8S_DIR}/conf/api-server.conf
ExecStart=${K8S_DIR}/bin/kube-apiserver \$API_SERVER_OPTS
Restart=on-failure
RestartSec=5
Type=notify
LimitNOFILE=65536
 
[Install]
WantedBy=multi-user.target
EOF
cat > services/k8s-controller-manager.service << EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
[Service]
EnvironmentFile=-${K8S_DIR}/conf/controller-manager.conf
ExecStart=${K8S_DIR}/bin/kube-controller-manager \$CONTROLLER_MANAGER_OPTS
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF
cat > services/k8s-scheduler.service << EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes
 
[Service]
EnvironmentFile=-${K8S_DIR}/conf/scheduler.conf
ExecStart=${K8S_DIR}/bin/kube-scheduler \$SCHEDULER_OPTS
Restart=on-failure
RestartSec=5
 
[Install]
WantedBy=multi-user.target
EOF
cp services/* /usr/lib/systemd/system
systemctl daemon-reload
systemctl start k8s-apiserver
systemctl enable k8s-apiserver
systemctl start k8s-controller-manager
systemctl enable k8s-controller-manager
systemctl start k8s-scheduler
systemctl enable k8s-scheduler
cp bin/kubectl /usr/local/bin
kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap
