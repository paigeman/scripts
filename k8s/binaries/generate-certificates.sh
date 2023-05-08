# if certificates is expired
# you should run this script again
cd
mkdir -p k8s-cert && cd k8s-cert
cat > ca-config.json << EOF
{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ],
        "expiry": "876000h"
      }
    }
  }
}
EOF
cat > ca-csr.json << EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names":[{
    "C": "CN",
    "ST": "JiangXi",
    "L": "GanZhou",
    "O": "FadeDemo",
    "OU": "FadeDemo"
  }]
}
EOF
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
cat > etcd-csr.json << EOF
{
  "CN": "etcd",
  "hosts": [
    "192.168.52.136",
    "192.168.52.138"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names":[{
    "C": "CN",
    "ST": "JiangXi",
    "L": "GanZhou",
    "O": "FadeDemo",
    "OU": "FadeDemo"
  }]
}
EOF
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem \
     --config=ca-config.json -profile=kubernetes \
     etcd-csr.json | cfssljson -bare etcd
cat > kubernetes-csr.json << EOF
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "192.168.52.136",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names":[{
    "C": "CN",
    "ST": "JiangXi",
    "L": "GanZhou",
    "O": "FadeDemo",
    "OU": "FadeDemo"
  }]
}
EOF
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem \
     --config=ca-config.json -profile=kubernetes \
     kubernetes-csr.json | cfssljson -bare kubernetes
cat > kube-proxy-csr.json << EOF
{
  "CN": "kube-proxy",
  "hosts": [
    "192.168.52.138"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names":[{
    "C": "CN",
    "ST": "JiangXi",
    "L": "GanZhou",
    "O": "FadeDemo",
    "OU": "FadeDemo"
  }]
}
EOF
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem \
     --config=ca-config.json -profile=kubernetes \
     kube-proxy-csr.json | cfssljson -bare kube-proxy