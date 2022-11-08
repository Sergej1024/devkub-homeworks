# Домашнее задание к занятию "12.5 Сетевые решения CNI"

После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.

## Задание 1: установить в кластер CNI плагин Calico

Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования:

* установка производится через ansible/kubespray;

Установил связкой [terraform + kubespray + ansible](./12-kubernetes-04-install-part-2/terraform/) из предыдущего задания.

```shell
user@home 08:24:20 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:2 ?:1 ✗| →  kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 -r 2
deployment.apps/hello-node created
user@home 08:33:49 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:2 ?:2 ✗| →  kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   2/2     2            2           11s
user@home 08:34:00 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:2 ?:2 ✗| →  kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
hello-node-697897c86-98pww   1/1     Running   0          20s
hello-node-697897c86-tlwpk   1/1     Running   0          20s
user@home 08:34:09 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:2 ?:2 ✗| →  kubectl get nodes -o wide
NAME            STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION                CONTAINER-RUNTIME
prod-cp-0       Ready    control-plane   28m   v1.25.3   10.1.0.22     <none>        CentOS Linux 7 (Core)   3.10.0-1160.66.1.el7.x86_64   containerd://1.6.9
prod-worker-0   Ready    <none>          27m   v1.25.3   10.1.0.17     <none>        CentOS Linux 7 (Core)   3.10.0-1160.66.1.el7.x86_64   containerd://1.6.9
prod-worker-1   Ready    <none>          27m   v1.25.3   10.1.0.13     <none>        CentOS Linux 7 (Core)   3.10.0-1160.66.1.el7.x86_64   containerd://1.6.9
prod-worker-2   Ready    <none>          27m   v1.25.3   10.1.0.29     <none>        CentOS Linux 7 (Core)   3.10.0-1160.66.1.el7.x86_64   containerd://1.6.9
prod-worker-3   Ready    <none>          27m   v1.25.3   10.1.0.8      <none>        CentOS Linux 7 (Core)   3.10.0-1160.66.1.el7.x86_64   containerd://1.6.9
user@home 08:34:51 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:2 ?:2 ✗| →  kubectl get deploy -o wide
NAME         READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                      SELECTOR
hello-node   2/2     2            2           73s   echoserver   k8s.gcr.io/echoserver:1.4   app=hello-node
user@home 08:35:03 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:2 ?:2 ✗| →  kubectl get pods -o wide
NAME                         READY   STATUS    RESTARTS   AGE   IP              NODE            NOMINATED NODE   READINESS GATES
hello-node-697897c86-98pww   1/1     Running   0          90s   10.233.104.1    prod-worker-2   <none>           <none>
hello-node-697897c86-tlwpk   1/1     Running   0          90s   10.233.77.129   prod-worker-0   <none>           <none>
user@home 08:35:20 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:2 ?:2 ✗| →  kubectl get services -o wide
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE   SELECTOR
kubernetes   ClusterIP   10.233.0.1   <none>        443/TCP   29m   <none>
user@home 08:44:41 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  kubectl expose deployment hello-node --type=LoadBalancer --port=8080
service/hello-node exposed
user@home 08:45:14 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  kubectl get services -o wide
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE   SELECTOR
hello-node   LoadBalancer   10.233.49.38   <pending>     8080:31911/TCP   3s    app=hello-node
kubernetes   ClusterIP      10.233.0.1     <none>        443/TCP          39m   <none> 
```

* после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

Добавил две политики:

* [communication-accept-pods](./12-kubernetes-05-cni/manifest/communication-accept-pods.yml) - разрешает хождение трафика между репликами hello-node
* [default-deny-ingress](./12-kubernetes-05-cni/manifest/default-deny-ingress.yml) - запрещает прочие коммуникации

Проверяем доступ без политик

* Доступ от одного пода к другому - работает

```shell
user@home 08:41:54 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  kubectl exec hello-node-697897c86-98pww -- curl -m 1 -s http://10.233.77.129:8080
CLIENT VALUES:
client_address=10.233.104.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://10.233.77.129:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=10.233.77.129:8080
user-agent=curl/7.47.0
BODY:
-no body in request-
user@home 08:43:48 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  kubectl exec hello-node-697897c86-tlwpk -- curl -m 1 -s http://10.233.104.1:8080
CLIENT VALUES:
client_address=10.233.77.129
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://10.233.104.1:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=10.233.104.1:8080
user-agent=curl/7.47.0
BODY:
-no body in request-
user@home 08:44:06 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  
```

* Доступ извне - работает

```shell
user@home 08:45:16 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  curl -s -m 1 http://158.160.39.15:31911
CLIENT VALUES:
client_address=10.233.68.0
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://158.160.39.15:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=158.160.39.15:31911
user-agent=curl/7.82.0
BODY:
-no body in request-
user@home 08:46:12 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  
```

Применяем политики

```shell
user@home 08:46:12 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  kubectl apply -f ./manifest/communication-accept-pods.yml 
networkpolicy.networking.k8s.io/accept-pods-communication created
user@home 08:47:15 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  kubectl apply -f ./manifest/default-deny-ingress.yml 
networkpolicy.networking.k8s.io/default-deny-ingress created
user@home 08:47:29 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  kubectl get netpol -A
NAMESPACE   NAME                        POD-SELECTOR     AGE
default     accept-pods-communication   app=hello-node   66s
default     default-deny-ingress        app=hello-node   52s
user@home 08:48:21 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →
```

* Доступ от одного пода к другому - по-прежнему работает

```shell
user@home 08:48:21 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  kubectl exec hello-node-697897c86-tlwpk -- curl -m 1 -s http://10.233.104.1:8080
CLIENT VALUES:
client_address=10.233.77.129
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://10.233.104.1:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=10.233.104.1:8080
user-agent=curl/7.47.0
BODY:
-no body in request-
user@home 08:49:08 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  kubectl exec hello-node-697897c86-98pww -- curl -m 1 -s http://10.233.77.129:8080
CLIENT VALUES:
client_address=10.233.104.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://10.233.77.129:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=10.233.77.129:8080
user-agent=curl/7.47.0
BODY:
-no body in request-
```

* Доступ извне - не работает.

```shell
user@home 08:49:19 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  curl -s -m 1 http://158.160.39.15:31911
user@home 08:49:27 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  curl -s -v -m 1 http://158.160.39.15:31911
*   Trying 158.160.39.15:31911...
* Connection timed out after 1000 milliseconds
* Closing connection 0
user@home 08:49:55 ~/git_store/devkub-homeworks/12-kubernetes-05-cni |main → origin U:3 ?:2 ✗| →  
```

## Задание 2: изучить, что запущено по умолчанию

Самый простой способ — проверить командой calicoctl get `type`. Для проверки стоит получить список нод, ipPool и profile.
Требования:

* установить утилиту calicoctl;

```shell
curl -s https://raw.githubusercontent.com/BigKAA/youtube/master/net/02-calico/01-install-calicoctl.sh | bash
```

```shell
curl -s https://raw.githubusercontent.com/BigKAA/youtube/master/net/02-calico/02-calicoctl.cfg -o /etc/calico/calicoctl.cfg 
```

Правим конфиг

```shell
user@home 09:27:48 ~ →  sudo cat /etc/calico/calicoctl.cfg
apiVersion: projectcalico.org/v3
kind: CalicoAPIConfig
metadata:
spec:
  datastoreType: "kubernetes"
  kubeconfig: "/home/user/.kube/config"
```

* получить 3 вышеописанных типа в консоли.

```shell
user@home 09:26:25 ~ →  calicoctl get profile
NAME                                                 
projectcalico-default-allow                          
kns.default                                          
kns.kube-node-lease                                  
kns.kube-public                                      
kns.kube-system                                      
ksa.default.default                                  
ksa.kube-node-lease.default                          
ksa.kube-public.default                              
ksa.kube-system.attachdetach-controller              
ksa.kube-system.bootstrap-signer                     
ksa.kube-system.calico-kube-controllers              
ksa.kube-system.calico-node                          
ksa.kube-system.certificate-controller               
ksa.kube-system.clusterrole-aggregation-controller   
ksa.kube-system.coredns                              
ksa.kube-system.cronjob-controller                   
ksa.kube-system.daemon-set-controller                
ksa.kube-system.default                              
ksa.kube-system.deployment-controller                
ksa.kube-system.disruption-controller                
ksa.kube-system.dns-autoscaler                       
ksa.kube-system.endpoint-controller                  
ksa.kube-system.endpointslice-controller             
ksa.kube-system.endpointslicemirroring-controller    
ksa.kube-system.ephemeral-volume-controller          
ksa.kube-system.expand-controller                    
ksa.kube-system.generic-garbage-collector            
ksa.kube-system.horizontal-pod-autoscaler            
ksa.kube-system.job-controller                       
ksa.kube-system.kube-proxy                           
ksa.kube-system.namespace-controller                 
ksa.kube-system.node-controller                      
ksa.kube-system.nodelocaldns                         
ksa.kube-system.persistent-volume-binder             
ksa.kube-system.pod-garbage-collector                
ksa.kube-system.pv-protection-controller             
ksa.kube-system.pvc-protection-controller            
ksa.kube-system.replicaset-controller                
ksa.kube-system.replication-controller               
ksa.kube-system.resourcequota-controller             
ksa.kube-system.root-ca-cert-publisher               
ksa.kube-system.service-account-controller           
ksa.kube-system.service-controller                   
ksa.kube-system.statefulset-controller               
ksa.kube-system.token-cleaner                        
ksa.kube-system.ttl-after-finished-controller        
ksa.kube-system.ttl-controller                       

user@home 09:27:07 ~ →  calicoctl get nodes
NAME            
prod-cp-0       
prod-worker-0   
prod-worker-1   
prod-worker-2   
prod-worker-3   

user@home 09:27:37 ~ →  calicoctl get ippool
NAME           CIDR             SELECTOR   
default-pool   10.233.64.0/18   all()      

user@home 09:27:48 ~ →  
```
