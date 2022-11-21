# Домашнее задание к занятию "13.4 инструменты для упрощения написания конфигурационных файлов. Helm и Jsonnet"

В работе часто приходится применять системы автоматической генерации конфигураций. Для изучения нюансов использования разных инструментов нужно попробовать упаковать приложение каждым из них.

## Задание 1: подготовить helm чарт для приложения

Необходимо упаковать приложение в чарт для деплоя в разные окружения. Требования:

* каждый компонент приложения деплоится отдельным deployment’ом/statefulset’ом;
* в переменных чарта измените образ приложения для изменения версии.

[Чарт](./13-kubernetes-config-04-helm/first/):

* [deployment | back](./13-kubernetes-config-04-helm/first/templates/deployments/backend.yml)
* [deployment | front](./13-kubernetes-config-04-helm/first/templates/deployments/frontend.yml)
* [statefulset | db](./13-kubernetes-config-04-helm/first/templates/statefulsets/db.yml)
* [service | back](./13-kubernetes-config-04-helm/first/templates/services/back.yml)
* [service | front](./13-kubernetes-config-04-helm/first/templates/services/front.yml)
* [service | db](./13-kubernetes-config-04-helm/first/templates/services/db.yml)

## Задание 2: запустить 2 версии в разных неймспейсах

Подготовив чарт, необходимо его проверить. Попробуйте запустить несколько копий приложения:

* одну версию в namespace=app1;
* вторую версию в том же неймспейсе;
* третью версию в namespace=app2.

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-04-helm [±|main → origin U:2 ?:1 ✗|] $ kubectl create namespace app1
namespace/app1 created
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-04-helm [±|main → origin U:2 ?:1 ✗|] $ kubectl create namespace app2
namespace/app2 created
```

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-04-helm [±|main → origin U:2 ?:1 ✗|] $ helm install -n app1 vv1 first
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/sergej/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/sergej/.kube/config
NAME: vv1
LAST DEPLOYED: Mon Nov 21 15:01:14 2022
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-04-helm [±|main → origin U:2 ?:1 ✗|] $ helm install -n app1 vv2 first
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/sergej/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/sergej/.kube/config
NAME: vv2
LAST DEPLOYED: Mon Nov 21 15:03:45 2022
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-04-helm [±|main → origin U:2 ?:1 ✗|] $ helm install -n app2 vv3 first
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/sergej/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/sergej/.kube/config
NAME: vv3
LAST DEPLOYED: Mon Nov 21 15:04:10 2022
NAMESPACE: app2
STATUS: deployed
REVISION: 1
TEST SUITE: None
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-04-helm [±|main → origin U:2 ?:1 ✗|] $ 
```

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-04-helm [±|main → origin U:2 ?:1 ✗|] $ kubectl get po,svc,pv -o wide -A | grep app
app1          pod/backend-vv1-7dcc77848-6gl6g               1/1     Running   0             6m1s    10.233.81.130   stage-worker-2   <none>           <none>
app1          pod/backend-vv2-788695c8d5-r4rwl              1/1     Running   0             3m30s   10.233.66.67    stage-worker-1   <none>           <none>
app1          pod/db-vv1-0                                  1/1     Running   0             6m1s    10.233.82.65    stage-worker-0   <none>           <none>
app1          pod/db-vv2-0                                  1/1     Running   0             3m30s   10.233.81.131   stage-worker-2   <none>           <none>
app1          pod/frontend-vv1-67b7d46968-fksq4             1/1     Running   0             6m1s    10.233.66.66    stage-worker-1   <none>           <none>
app1          pod/frontend-vv2-5f8fdcf85f-4m2rh             1/1     Running   0             3m30s   10.233.82.66    stage-worker-0   <none>           <none>
app2          pod/backend-vv3-5bb8fc9f86-zdmvf              1/1     Running   0             3m6s    10.233.66.68    stage-worker-1   <none>           <none>
app2          pod/db-vv3-0                                  1/1     Running   0             3m6s    10.233.81.132   stage-worker-2   <none>           <none>
app2          pod/frontend-vv3-598dd7576b-rv4nk             1/1     Running   0             3m6s    10.233.82.67    stage-worker-0   <none>           <none>
app1          service/backend-vv1    ClusterIP   10.233.49.8     <none>        9000/TCP                 6m3s    app=backend-vv1
app1          service/backend-vv2    ClusterIP   10.233.42.52    <none>        9000/TCP                 3m32s   app=backend-vv2
app1          service/db-vv1         ClusterIP   10.233.52.38    <none>        5432/TCP                 6m3s    app=db-vv1
app1          service/db-vv2         ClusterIP   10.233.3.163    <none>        5432/TCP                 3m32s   app=db-vv2
app1          service/frontend-vv1   ClusterIP   10.233.22.187   <none>        80/TCP                   6m3s    app=frontend-vv1
app1          service/frontend-vv2   ClusterIP   10.233.55.67    <none>        80/TCP                   3m32s   app=frontend-vv2
app2          service/backend-vv3    ClusterIP   10.233.39.35    <none>        9000/TCP                 3m8s    app=backend-vv3
app2          service/db-vv3         ClusterIP   10.233.24.224   <none>        5432/TCP                 3m8s    app=db-vv3
app2          service/frontend-vv3   ClusterIP   10.233.23.34    <none>        80/TCP                   3m8s    app=frontend-vv3
kube-system   service/coredns        ClusterIP   10.233.0.3      <none>        53/UDP,53/TCP,9153/TCP   31m     k8s-app=kube-dns
            persistentvolume/pv-vv1   2Gi        RWX            Retain           Bound    app1/pvc-vv1   nfs                     6m3s    Filesystem
            persistentvolume/pv-vv2   2Gi        RWX            Retain           Bound    app1/pvc-vv2   nfs                     3m32s   Filesystem
            persistentvolume/pv-vv3   2Gi        RWX            Retain           Bound    app2/pvc-vv3   nfs                     3m8s    Filesystem
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-04-helm [±|main → origin U:2 ?:1 ✗|] $ 
```

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-04-helm [±|main → origin U:2 ?:1 ✗|] $ kubectl port-forward -n app1 service/frontend-vv1 :80
Forwarding from 127.0.0.1:39331 -> 80
Forwarding from [::1]:39331 -> 80
Handling connection for 39331

```

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-01-objects/manifests [±|main → origin U:2 ?:1 ✗|] $ curl 127.0.0.1:39331
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-01-objects/manifests [±|main → origin U:2 ?:1 ✗|] $ 
```

## Задание 3 (*): повторить упаковку на jsonnet

Для изучения другого инструмента стоит попробовать повторить опыт упаковки из задания 1, только теперь с помощью инструмента jsonnet.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
