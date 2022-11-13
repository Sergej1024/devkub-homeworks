# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"

Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения

Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:

* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.

Приложения запущены в отдельном неймспейсе `stage`. Манифесты:

* [deployment фронтенд и бекенд](./13-kubernetes-config-01-objects/manifests/stage/app.yml)
* [statefulset БД](./13-kubernetes-config-01-objects/manifests/stage/db.yml)

```shell
user@home 11:52:23 ~/git_store/devkub-homeworks/13-kubernetes-config-01-objects/manifests |main → origin U:2 ✗| →  kubectl create namespace stage
namespace/stage created
user@home 11:53:11 ~/git_store/devkub-homeworks/13-kubernetes-config-01-objects/manifests |main → origin U:2 ✗| →  kubectl apply -f stage/
deployment.apps/front-back created
statefulset.apps/db created
service/db created
user@home 11:56:06 ~/git_store/devkub-homeworks/13-kubernetes-config-01-objects/manifests |main → origin U:2 ✗| →  kubectl get po,deployment,svc,ep -n stage
NAME                              READY   STATUS              RESTARTS   AGE
pod/db-0                          0/1     ContainerCreating   0          4s
pod/front-back-6f4465cf46-27xg8   0/2     Init:0/1            0          5s
pod/front-back-6f4465cf46-86brf   0/2     Init:0/1            0          5s
pod/front-back-6f4465cf46-dptm5   0/2     Init:0/1            0          5s
pod/front-back-6f4465cf46-zx74n   0/2     Init:0/1            0          5s

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/front-back   0/4     4            0           5s

NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/db   ClusterIP   10.233.38.98   <none>        5432/TCP   4s

NAME           ENDPOINTS   AGE
endpoints/db   <none>      4s
user@home 11:57:49 ~/git_store/devkub-homeworks/13-kubernetes-config-01-objects/manifests |main → origin U:2 ✗| →  kubectl get po,deployment,svc,ep -n stage
NAME                              READY   STATUS    RESTARTS   AGE
pod/db-0                          1/1     Running   0          106s
pod/front-back-6f4465cf46-27xg8   2/2     Running   0          107s
pod/front-back-6f4465cf46-86brf   2/2     Running   0          107s
pod/front-back-6f4465cf46-dptm5   2/2     Running   0          107s
pod/front-back-6f4465cf46-zx74n   2/2     Running   0          107s

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/front-back   4/4     4            4           107s

NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/db   ClusterIP   10.233.38.98   <none>        5432/TCP   107s

NAME           ENDPOINTS           AGE
endpoints/db   10.233.66.67:5432   107s
user@home 11:58:08 ~/git_store/devkub-homeworks/13-kubernetes-config-01-objects/manifests |main → origin U:2 ✗| →  
```

## Задание 2: подготовить конфиг для production окружения

Следующим шагом будет запуск приложения в production окружении. Требования сложнее:

* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.

Приложения запущены в отдельном неймспейсе `production`. Манифесты:

* [deployment фронтенд](./13-kubernetes-config-01-objects/manifests/prod/front.yml)
* [deployment бекенд](./13-kubernetes-config-01-objects/manifests/prod/back.yml)
* [statefulset БД](./13-kubernetes-config-01-objects/manifests/prod/db.yml)

```shell
user@home 11:58:08 ~/git_store/devkub-homeworks/13-kubernetes-config-01-objects/manifests |main → origin U:2 ✗| →  kubectl create namespace production
namespace/production created
user@home 12:03:01 ~/git_store/devkub-homeworks/13-kubernetes-config-01-objects/manifests |main → origin U:2 ✗| →  kubectl apply -f prod/
deployment.apps/backend created
service/backend created
statefulset.apps/db created
service/db created
deployment.apps/frontend created
service/frontend created
user@home 12:04:54 ~/git_store/devkub-homeworks/13-kubernetes-config-01-objects/manifests |main → origin U:6 ✗| →  kubectl get po,deployment,svc,ep -n production
NAME                            READY   STATUS    RESTARTS   AGE
pod/backend-f767cfbdb-qkq27     1/1     Running   0          17s
pod/db-0                        1/1     Running   0          17s
pod/frontend-6d4f9768d6-9v9vd   1/1     Running   0          17s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend    1/1     1            1           17s
deployment.apps/frontend   1/1     1            1           17s

NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/backend    ClusterIP   10.233.5.3      <none>        9000/TCP   17s
service/db         ClusterIP   10.233.62.41    <none>        5432/TCP   17s
service/frontend   ClusterIP   10.233.59.183   <none>        80/TCP     16s

NAME                 ENDPOINTS           AGE
endpoints/backend    10.233.82.67:9000   17s
endpoints/db         10.233.66.68:5432   17s
endpoints/frontend   10.233.82.68:80     16s
user@home 12:05:10 ~/git_store/devkub-homeworks/13-kubernetes-config-01-objects/manifests |main → origin U:6 ✗| →  
```

## Задание 3 (*): добавить endpoint на внешний ресурс api

Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:

* добавлен endpoint до внешнего api (например, геокодер).
