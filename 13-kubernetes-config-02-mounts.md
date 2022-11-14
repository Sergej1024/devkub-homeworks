# Домашнее задание к занятию "13.2 разделы и монтирование"

Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):

* установить helm: curl <https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3> | bash
* добавить репозиторий чартов: helm repo add stable <https://charts.helm.sh/stable> && helm repo update
* установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner

В конце установки будет выдан пример создания PVC для этого сервера.

```shell
user@home 06:28:45 ~ →  curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11156  100 11156    0     0  23145      0 --:--:-- --:--:-- --:--:-- 23193
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/user/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/user/.kube/config
Helm v3.10.2 is available. Changing from version v3.10.0.
Downloading https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
[sudo] пароль для user: 
helm installed into /usr/local/bin/helm
user@home 06:30:04 ~ →  helm repo add stable https://charts.helm.sh/stable && helm repo update
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/user/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/user/.kube/config
"stable" has been added to your repositories
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/user/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/user/.kube/config
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "gitlab" chart repository (https://charts.gitlab.io):
	Get "https://charts.gitlab.io/index.yaml": read tcp 192.168.1.20:48242->35.185.44.232:443: read: connection reset by peer
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈Happy Helming!⎈
user@home 06:30:19 ~ →  helm install nfs-server stable/nfs-server-provisioner
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/user/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/user/.kube/config
WARNING: This chart is deprecated
NAME: nfs-server
LAST DEPLOYED: Sun Nov 13 18:30:35 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The NFS Provisioner service has now been installed.

A storage class named 'nfs' has now been created
and is available to provision dynamic volumes.

You can use this storageclass by creating a `PersistentVolumeClaim` with the
correct storageClassName attribute. For example:

    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: test-dynamic-volume-claim
    spec:
      storageClassName: "nfs"
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi
user@home 06:30:38 ~ →  
```

## Задание 1: подключить для тестового конфига общую папку

В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:

* в поде подключена общая папка между контейнерами (например, /static);
* после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

Приложения запущены в отдельном неймспейсе `stage`. Манифесты:

* [deployment фронтенд и бекенд](./13-kubernetes-config-02-mounts/manifests/stage/app.yml)
* [statefulset БД](./13-kubernetes-config-02-mounts/manifests/stage/db.yml)

```shell
user@home 06:55:27 ~/git_store/devkub-homeworks/13-kubernetes-config-02-mounts/manifests |main → origin U:3 ?:1 ✗| →  kubectl create namespace stage
namespace/stage created
user@home 06:55:47 ~/git_store/devkub-homeworks/13-kubernetes-config-02-mounts/manifests |main → origin U:3 ?:1 ✗| →  kubectl apply -f stage/
deployment.apps/front-back created
statefulset.apps/db created
service/db created
user@home 06:56:01 ~/git_store/devkub-homeworks/13-kubernetes-config-02-mounts/manifests |main → origin U:3 ?:1 ✗| →  kubectl get po,deployment,svc,ep -n stage
NAME                              READY   STATUS    RESTARTS   AGE
pod/db-0                          1/1     Running   0          117s
pod/front-back-6f766bd774-gpqng   2/2     Running   0          117s
pod/front-back-6f766bd774-m5mw8   2/2     Running   0          117s

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/front-back   2/2     2            2           117s

NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/db   ClusterIP   10.233.41.99   <none>        5432/TCP   117s

NAME           ENDPOINTS           AGE
endpoints/db   10.233.82.66:5432   117s
user@home 07:00:20 ~/git_store/devkub-homeworks/13-kubernetes-config-02-mounts/manifests |main → origin U:3 ?:1 ✗| →  kubectl exec pod/front-back-6f766bd774-gpqng -c frontend -- sh -c 'echo "Hi, World!" > /tmp/cache/test.txt'
Error from server (NotFound): pods "front-back-6f766bd774-gpqng" not found
user@home 07:01:05 ~/git_store/devkub-homeworks/13-kubernetes-config-02-mounts/manifests |main → origin U:3 ?:1 ✗| →  kubectl exec -n stage pod/front-back-6f766bd774-gpqng -c frontend -- sh -c 'echo "Hi, World!" > /tmp/cache/test.txt'
user@home 07:01:41 ~/git_store/devkub-homeworks/13-kubernetes-config-02-mounts/manifests |main → origin U:3 ?:1 ✗| →  kubectl exec -n stage pod/front-back-6f766bd774-gpqng -c backend -- sh -c 'cat /data/static/test.txt'
Hi, World!
user@home 07:03:15 ~/git_store/devkub-homeworks/13-kubernetes-config-02-mounts/manifests |main → origin U:3 ?:1 ✗| →  kubectl exec -n stage pod/front-back-6f766bd774-gpqng -c backend -- ls -l /data/static/
total 4
-rw-r--r--. 1 root root 11 Nov 13 14:01 test.txt
user@home 07:03:55 ~/git_store/devkub-homeworks/13-kubernetes-config-02-mounts/manifests |main → origin U:3 ?:1 ✗| →  
```

## Задание 2: подключить общую папку для прода

Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:

* все бекенды подключаются к одному PV в режиме ReadWriteMany;
* фронтенды тоже подключаются к этому же PV с таким же режимом;
* файлы, созданные бекендом, должны быть доступны фронту.

Приложения запущены в отдельном неймспейсе `production`. Манифесты:

* [deployment фронтенд](./13-kubernetes-config-02-mounts/manifests/prod/front.yml)
* [deployment бекенд](./13-kubernetes-config-02-mounts/manifests/prod/back.yml)
* [statefulset БД](./13-kubernetes-config-02-mounts/manifests/prod/db.yml)

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:3 ✗|] $ kubectl create namespace production
namespace/production created
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:3 ✗|] $ kubectl apply -f ./prod
deployment.apps/backend created
service/backend created
statefulset.apps/db created
service/db created
deployment.apps/frontend created
service/frontend created
persistentvolumeclaim/static-storage-pvc created
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:3 ✗|] $ kubectl get po,pv,pvc -n production -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP              NODE             NOMINATED NODE   READINESS GATES
pod/backend-7987fc7b4d-b4r84    1/1     Running   0          2m54s   10.233.81.130   stage-worker-2   <none>           <none>
pod/db-0                        1/1     Running   0          2m53s   10.233.82.65    stage-worker-0   <none>           <none>
pod/frontend-867df49788-ckppd   1/1     Running   0          2m52s   10.233.82.66    stage-worker-0   <none>           <none>

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                           STORAGECLASS   REASON   AGE   VOLUMEMODE
persistentvolume/pvc-e2efb401-8271-427b-97b4-8acaf67d2245   100Mi      RWX            Delete           Bound    production/static-storage-pvc   nfs                     72s   Filesystem

NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE     VOLUMEMODE
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:3 ✗|] $ kubectl exec -n production frontend-867df49788-ckppd -c frontend -- sh -c "echo 'This is test prod' > /tmp/cache/prod-file.txt"
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:3 ✗|] $ kubectl exec -n production backend-7987fc7b4d-b4r84 -c backend -- sh -c "cat /data/static/prod-file.txt"
This is test prod
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:3 ✗|] $ kubectl exec -n production backend-7987fc7b4d-b4r84  -- ls -l /data/static/
Defaulted container "backend" out of: backend, wait-for-db (init)
total 4
-rw-r--r--. 1 root root 18 Nov 14 07:26 prod-file.txt
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:3 ✗|] $ 
```

```shell
[root@stage-worker-2 ~]# find / -type f -name "prod-file.txt"
/var/lib/kubelet/pods/531aaf94-1726-4523-af84-61daa6394ed9/volumes/kubernetes.io~nfs/pvc-e2efb401-8271-427b-97b4-8acaf67d2245/prod-file.txt
[root@stage-worker-2 ~]# cat /var/lib/kubelet/pods/531aaf94-1726-4523-af84-61daa6394ed9/volumes/kubernetes.io~nfs/pvc-e2efb401-8271-427b-97b4-8acaf67d2245/prod-file.txt
This is test prod
[root@stage-worker-2 ~]#
```

```shell
root@stage-worker-0 ansible]# find / -type f -name "prod-file.txt"
/var/lib/kubelet/pods/9a2a91d0-7da6-4a77-93fd-2024b0dd5285/volumes/kubernetes.io~nfs/pvc-e2efb401-8271-427b-97b4-8acaf67d2245/prod-file.txt
[root@stage-worker-0 ansible]# cat /var/lib/kubelet/pods/9a2a91d0-7da6-4a77-93fd-2024b0dd5285/volumes/kubernetes.io~nfs/pvc-e2efb401-8271-427b-97b4-8acaf67d2245/prod-file.txt
This is test prod
[root@stage-worker-0 ansible]# 
```
