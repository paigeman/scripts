ETCD_VER=v3.4.25

cd
# node1
cat > etcd-config.yaml << EOF
name: node1
data-dir: /etcd-data
advertise-client-urls: https://192.168.52.136:2379
listen-client-urls: https://0.0.0.0:2379
initial-advertise-peer-urls: https://192.168.52.136:2380
listen-peer-urls: https://0.0.0.0:2380
initial-cluster: node1=https://192.168.52.136:2380,node2=https://192.168.52.138:2380
initial-cluster-state: new
client-transport-security:
  # Path to the client server TLS cert file.
  cert-file: /etc/etcd/etcd.pem

  # Path to the client server TLS key file.
  key-file: /etc/etcd/etcd-key.pem

  # Enable client cert authentication.
  client-cert-auth: true

  # Path to the client server TLS trusted CA cert file.
  trusted-ca-file: /etc/etcd/ca.pem

  # Client TLS using generated certificates
  auto-tls: true
peer-transport-security:
  # Path to the peer server TLS cert file.
  cert-file: /etc/etcd/etcd.pem

  # Path to the peer server TLS key file.
  key-file: /etc/etcd/etcd-key.pem

  # Enable peer client cert authentication.
  client-cert-auth: true

  # Path to the peer server TLS trusted CA cert file.
  trusted-ca-file: /etc/etcd/ca.pem

  # Peer TLS using generated certificates.
  auto-tls: true
EOF

# node1
docker run -d --name etcd1 \
  -p 2379:2379 -p 2380:2380 \
  --volume /root/etcd-config.yaml:/etc/etcd/etcd-config.yaml \
  --volume /root/k8s-cert/etcd.pem:/etc/etcd/etcd.pem \
  --volume /root/k8s-cert/etcd-key.pem:/etc/etcd/etcd-key.pem \
  --volume /root/k8s-cert/ca.pem:/etc/etcd/ca.pem \
  --restart always \
  quay.io/coreos/etcd:${ETCD_VER} \
  /usr/local/bin/etcd \
  --config-file /etc/etcd/etcd-config.yaml
