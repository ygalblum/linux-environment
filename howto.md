## SSH Remove Host
```bash
ssh-keygen -R <hostname or IP address>
```

## K8S Manual Installation

### Centos

```bash
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum makecache fast
yum install -y docker-ce-18.09.4-3.el7.x86_64
systemctl enable docker
systemctl start docker
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
export KUBE_VERSION=1.14.3
yum -y install kubelet-$KUBE_VERSION-0.x86_64 kubeadm-$KUBE_VERSION-0.x86_64 kubectl-$KUBE_VERSION-0.x86_64
```

### Fedora

#### Fedora 28 QCOW2 image
https://download.fedoraproject.org/pub/fedora/linux/releases/28/Cloud/x86_64/images/Fedora-Cloud-Base-28-1.1.x86_64.qcow2
Docker version: docker-ce.x86_64:18.06.1.ce-3.fc28
https://dl.fedoraproject.org/pub/fedora/linux/releases/27/CloudImages/x86_64/images/Fedora-Cloud-Base-27-1.6.x86_64.qcow2
Docker version: docker-ce.x86_64:18.06.1.ce-3.fc28

#### Manual Installation
```bash
sudo su
dnf remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
dnf -y install docker-ce-18.06.1.ce-3.fc28.x86_64
systemctl enable docker
systemctl start docker
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
export KUBE_VERSION=1.13.4
dnf -y install kubelet-$KUBE_VERSION-0.x86_64 kubeadm-$KUBE_VERSION-0.x86_64 kubectl-$KUBE_VERSION-0.x86_64
hostnamectl set-hostname host-10-0-0-8.symphony

kubeadm alpha phase certs all --config /tmp/kubeadm-config.yaml
kubeadm alpha phase kubelet config write-to-disk --config /tmp/kubeadm-config.yaml
kubeadm alpha phase kubelet write-env-file --config /tmp/kubeadm-config.yaml
kubeadm alpha phase kubeconfig kubelet --config /tmp/kubeadm-config.yaml
systemctl start kubelet
kubeadm alpha phase etcd local --config /tmp/kubeadm-config.yaml
export CP0_IP=192.168.30.100
export CP0_HOSTNAME=host-192-168-30-100.symphony
export CP1_IP=192.168.30.102
export CP1_HOSTNAME=host-192-168-30-102.symphony
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl exec -n kube-system etcd-${CP0_HOSTNAME} -- etcdctl --ca-file /etc/kubernetes/pki/etcd/ca.crt --cert-file /etc/kubernetes/pki/etcd/peer.crt --key-file /etc/kubernetes/pki/etcd/peer.key --endpoints=https://${CP0_IP}:2379 member add ${CP1_HOSTNAME} https://${CP1_IP}:2380
kubeadm alpha phase kubeconfig all --config /tmp/kubeadm-config.yaml
kubeadm alpha phase controlplane all --config /tmp/kubeadm-config.yaml
kubeadm alpha phase kubelet config annotate-cri --config /tmp/kubeadm-config.yaml
kubeadm alpha phase mark-master --config /tmp/kubeadm-config.yaml
```

### K8S Simple K8S Deploy Yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

### Create deployment and expose service
```bash
kubectl run my-nginx --image=nginx --replicas=2 --port=80
kubectl expose deployment my-nginx --port=80 --type=NodePort
kubectl describe service my-nginx
```

### Keep Running Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: fedora
spec:
  containers:
  - name: fedora
    image: registry.fedoraproject.org/fedora:38
    # Just spin & wait forever
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "while true; do sleep 30; done;" ]
```


## Get Image list for version:
```bash
kubeadm config images list --kubernetes-version $KUBE_VERSION
```

## etcd metrics
```bash
curl -k -cacert /etc/kubernetes/pki/etcd/ca.crt --key /etc/kubernetes/pki/etcd/peer.key --cert /etc/kubernetes/pki/etcd/peer.crt https://127.0.0.1:2379/metrics
```

## Docker Cleanup
```bash
docker volume ls -qf dangling=true | xargs -r --no-run-if-empty docker volume rm
```

## Skipper

### Upadate Docker image
---------------------------
```bash
skipper build <Image Name>
skipper push <Image Name>
```
and update `skipper.yaml` after pushing with new hash that you currentrly pushed


## Look for listening TCP ports on Linux
```bash
netstat -tulpn
```

## git Stuff

### Change date on commit to now
```bash
git commit --amend --date="$(date -R)"
```

### Rename branch with remote
```bash
git branch -m new-name
git push origin :old-name new-name
git push origin -u new-name
```

### Delete local branches without remote
```bash
git remote prune origin
git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -D
```

### Git clean
```bash
git clean -fxd
```

## Extend qcow image size
On the host machine:
``` bash
sudo qemu-img resize <Image file> +10G
```

In the guest machine:
```bash
sudo dnf -y install cloud-utils-growpart gdisk
sudo growpart /dev/vda 1
sudo xfs_growfs /
```

## Enabling nested virtualization in KVM

https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/


## Command line loop
```bash
for f in `git status | grep modified  | awk '{print $2}'`; do echo $f; done
```

```bash
for f in `git log --raw -1  | grep 100644 | awk '{print $6}' | grep -v docs |  grep -v "e2e\/quadlet\/"`; do gofmt -s -w $f; done
```

## Cleanup none images
```bash
podman image list | grep none | awk '{print $3}' | xargs podman image rm
```

## SELinux
```bash
ausearch -m avc
```

## SShuttle
```bash
sshuttle --dns -vr root@helios03.lab.eng.tlv2.redhat.com 192.168.111.0/24
```

## Create VM from qcow2 and cloud-init
```bash
virt-install --name localcloud1 --memory 2048 --noreboot --os-variant detect=on,name=rhel7.9 --cloud-init user-data=/home/images/rhel-7/userdata.yaml --disk=size=10,backing_store=/home/images/rhel-7/rhel-server-7.9-x86_64-kvm.qcow2
```

For networking in user mode add: `--network=bridge=virbr0` (replace virbr0 with actual bridge)

If using bridge use following to find IP address:
```bash
arp -n | grep `virsh domiflist --domain <DomainName> | grep bridge | awk '{print $5}'` | awk '{print $1}'
```

## Update SELinux labels on qcow2 image
```bash
virt-customize -a <IMAGE> --selinux-relabel
```


## Go Format

Format all files in last commit:
```bash
git log --raw -1 | grep 100644 | awk '{print $6}' | grep "\.go" | xargs gofmt -s -w
```

## Running command in Container namespace
Find container namespaces
```bash
podman ps --namespace
```

Run command in network namespace of pid 16882:
```bash
sudo nsenter -t 16882 -n ip link show
```

## Upgrade Fedora from Command Line
```bash
sudo dnf upgrade --refresh
reboot
sudo dnf install dnf-plugin-system-upgrade
sudo dnf system-upgrade download --releasever=40
```


## Create an image file
```
dd if=/dev/null of=example.img bs=1M seek=1024
mkfs.ext4 -F example.img
mkdir /mnt/example
mount -t ext4 -o loop example.img /mnt/example
```

## Vault

### Add txt file
```bash
vault kv put kv/some/path contents=@filename_goes_here
```

## By pass HSTS

`thisisunsafe`


## Get OCP Service CA Certificate
```bash
oc get configmaps kube-root-ca.crt -o json | jq -r .data.\"ca.crt\" > kube-ca.crt
```

## OCP - Reduce storage consumption
### CNV
For some reason I can't edit the `importsToKeep` field of the `hyperconverged.status.dataImportCronTemplates.spec`.
For now, make sure to manually remove the DataVolumes in `openshift-virtualization-os-images` namespace

### Monitoring
Create or Edit the configmap:

```bash
oc edit configmap -n openshift-monitoring cluster-monitoring-config
```

to:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    prometheusK8s:
      retention: "3d"
      volumeClaimTemplate:
        metadata:
          name: prometheusdb
        spec:
          storageClassName: nfs-client
          resources:
            requests:
              storage: 20Gi
    alertmanagerMain:
      volumeClaimTemplate:
        metadata:
          name: alertmanager
        spec:
          storageClassName: nfs-client
          resources:
            requests:
              storage: 20Gi
```
Without setting the volumeClaimTemplate it will use a host path a kill the node.
Make sure to set the PVC size to something you are comfortable with. Note that two of each is created
Reduce the retention period to reduce consumption


Ontap Simulator
---------------
<Type><Number of Disks><Rack>
Stop before boot
Run:
setenv bootarg.vm.sim.vdevinit "31:14:0,31:14:1,31:14:2"
setenv bootarg.sim.vdevinit "31:14:0,31:14:1,31:14:2"
boot

Setup using WebUI

Connect via SSH using admin and password set in previous stage
storage disk assign -all -node local

Removing a stuck namespace
--------------------------
```bash
(
NAMESPACE=your-rogue-namespace
kubectl proxy &
kubectl get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' >temp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
)
```