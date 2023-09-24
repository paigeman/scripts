# token will expire after 24 hours, use command below will regenerate token
# kubeadm token create --print-join-command
kubeadm join 192.168.52.130:6443 --token lywd19.qu6gf7cput2lzwfx \
--discovery-token-ca-cert-hash sha256:c629b27aced8429d3e5560c18dde2008a62b6b4eb23c20f7ea47f6a8ba99d919 \
--cri-socket=unix:///var/run/cri-dockerd.sock