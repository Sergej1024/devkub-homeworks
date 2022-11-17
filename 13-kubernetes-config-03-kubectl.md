# Домашнее задание к занятию "13.3 работа с kubectl"

## Задание 1: проверить работоспособность каждого компонента

Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:

* сделайте запросы к бекенду;
* сделайте запросы к фронту;
* подключитесь к базе данных.

* exec

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:1 ✗|] $ kubectl exec -n production frontend-867df49788-dkdm9  -- curl -s -m 1 backend:9000/api/news/
[{"id":1,"title":"title 0","short_description":"small text 0small text 0small text 0small text 0small text 0small text 0small text 0small text 0small text 0small text 0","preview":"/static/image.png"},{"id":2,"title":"title 1","short_description":"small text 1small text 1small text 1small text 1small text 1small text 1small text 1small text 1small text 1small text 1","preview":"/static/image.png"},{"id":3,"title":"title 2","short_description":"small text 2small text 2small text 2small text 2small text 2small text 2small text 2small text 2small text 2small text 2","preview":"/static/image.png"},{"id":4,"title":"title 3","short_description":"small text 3small text 3small text 3small text 3small text 3small text 3small text 3small text 3small text 3small text 3","preview":"/static/image.png"},{"id":5,"title":"title 4","short_description":"small text 4small text 4small text 4small text 4small text 4small text 4small text 4small text 4small text 4small text 4","preview":"/static/image.png"},{"id":6,"title":"title 5","short_description":"small text 5small text 5small text 5small text 5small text 5small text 5small text 5small text 5small text 5small text 5","preview":"/static/image.png"},{"id":7,"title":"title 6","short_description":"small text 6small text 6small text 6small text 6small text 6small text 6small text 6small text 6small text 6small text 6","preview":"/static/image.png"},{"id":8,"title":"title 7","short_description":"small text 7small text 7small text 7small text 7small text 7small text 7small text 7small text 7small text 7small text 7","preview":"/static/image.png"},{"id":9,"title":"title 8","short_description":"small text 8small text 8small text 8small text 8small text 8small text 8small text 8small text 8small text 8small text 8","preview":"/static/image.png"},{"id":10,"title":"title 9","short_description":"small text 9small text 9small text 9small text 9small text 9small text 9small text 9small text 9small text 9small text 9","preview":"/static/image.png"},{"id":11,"title":"title 10","short_description":"small text 10small text 10small text 10small text 10small text 10small text 10small text 10small text 10small text 10small text 10","preview":"/static/image.png"},{"id":12,"title":"title 11","short_description":"small text 11small text 11small text 11small text 11small text 11small text 11small text 11small text 11small text 11small text 11","preview":"/static/image.png"},{"id":13,"title":"title 12","short_description":"small text 12small text 12small text 12small text 12small text 12small text 12small text 12small text 12small text 12small text 12","preview":"/static/image.png"},{"id":14,"title":"title 13","short_description":"small text 13small text 13small text 13small text 13small text 13small text 13small text 13small text 13small text 13small text 13","preview":"/static/image.png"},{"id":15,"title":"title 14","short_description":"small text 14small text 14small text 14small text 14small text 14small text 14small text 14small text 14small text 14small text 14","preview":"/static/image.png"},{"id":16,"title":"title 15","short_description":"small text 15small text 15small text 15small text 15small text 15small text 15small text 15small text 15small text 15small text 15","preview":"/static/image.png"},{"id":17,"title":"title 16","short_description":"small text 16small text 16small text 16small text 16small text 16small text 16small text 16small text 16small text 16small text 16","preview":"/static/image.png"},{"id":18,"title":"title 17","short_description":"small text 17small text 17small text 17small text 17small text 17small text 17small text 17small text 17small text 17small text 17","preview":"/static/image.png"},{"id":19,"title":"title 18","short_description":"small text 18small text 18small text 18small text 18small text 18small text 18small text 18small text 18small text 18small text 18","preview":"/static/image.png"},{"id":20,"title":"title 19","short_description":"small text 19small text 19small text 19small text 19small text 19small text 19small text 19small text 19small text 19small text 19","preview":"/static/image.png"},{"id":21,"title":"title 20","short_description":"small text 20small text 20small text 20small text 20small text 20small text 20small text 20small text 20small text 20small text 20","preview":"/static/image.png"},{"id":22,"title":"title 21","short_description":"small text 21small text 21small text 21small text 21small text 21small text 21small text 21small text 21small text 21small text 21","preview":"/static/image.png"},{"id":23,"title":"title 22","short_description":"small text 22small text 22small text 22small text 22small text 22small text 22small text 22small text 22small text 22small text 22","preview":"/static/image.png"},{"id":24,"title":"title 23","short_description":"small text 23small text 23small text 23small text 23small text 23small text 23small text 23small text 23small text 23small text 23","preview":"/static/image.png"},{"id":25,"title":"title 24","short_description":"small text 24small text 24small text 24small text 24small text 24small text 24small text 24small text 24small text 24small text 24","preview":"/static/image.png"}]sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:1 ✗|] $ 
```

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ kubectl exec -n production backend-7987fc7b4d-lmsqr  -- curl -s -m 1 frontend:80
Defaulted container "backend" out of: backend, wait-for-db (init)
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
</html>sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ 
```

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:1 ✗|] $ kubectl exec -n production -ti db-0  -- psql -U postgres news
psql (13.9)
Type "help" for help.

news=# 
```

* port-forward

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ kubectl port-forward -n production service/frontend 8000:80
Forwarding from 127.0.0.1:8000 -> 80
Forwarding from [::1]:8000 -> 80
Handling connection for 8000

```

```shell
sergej@fedora:~ $ curl localhost:8000
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
</html>sergej@fedora:~ $ 
```

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ kubectl port-forward -n production service/backend 7000:9000
Forwarding from 127.0.0.1:7000 -> 9000
Forwarding from [::1]:7000 -> 9000
Handling connection for 7000
Handling connection for 7000

```

```shell
sergej@fedora:~ $ curl localhost:7000/api/news/
[{"id":1,"title":"title 0","short_description":"small text 0small text 0small text 0small text 0small text 0small text 0small text 0small text 0small text 0small text 0","preview":"/static/image.png"},{"id":2,"title":"title 1","short_description":"small text 1small text 1small text 1small text 1small text 1small text 1small text 1small text 1small text 1small text 1","preview":"/static/image.png"},{"id":3,"title":"title 2","short_description":"small text 2small text 2small text 2small text 2small text 2small text 2small text 2small text 2small text 2small text 2","preview":"/static/image.png"},{"id":4,"title":"title 3","short_description":"small text 3small text 3small text 3small text 3small text 3small text 3small text 3small text 3small text 3small text 3","preview":"/static/image.png"},{"id":5,"title":"title 4","short_description":"small text 4small text 4small text 4small text 4small text 4small text 4small text 4small text 4small text 4small text 4","preview":"/static/image.png"},{"id":6,"title":"title 5","short_description":"small text 5small text 5small text 5small text 5small text 5small text 5small text 5small text 5small text 5small text 5","preview":"/static/image.png"},{"id":7,"title":"title 6","short_description":"small text 6small text 6small text 6small text 6small text 6small text 6small text 6small text 6small text 6small text 6","preview":"/static/image.png"},{"id":8,"title":"title 7","short_description":"small text 7small text 7small text 7small text 7small text 7small text 7small text 7small text 7small text 7small text 7","preview":"/static/image.png"},{"id":9,"title":"title 8","short_description":"small text 8small text 8small text 8small text 8small text 8small text 8small text 8small text 8small text 8small text 8","preview":"/static/image.png"},{"id":10,"title":"title 9","short_description":"small text 9small text 9small text 9small text 9small text 9small text 9small text 9small text 9small text 9small text 9","preview":"/static/image.png"},{"id":11,"title":"title 10","short_description":"small text 10small text 10small text 10small text 10small text 10small text 10small text 10small text 10small text 10small text 10","preview":"/static/image.png"},{"id":12,"title":"title 11","short_description":"small text 11small text 11small text 11small text 11small text 11small text 11small text 11small text 11small text 11small text 11","preview":"/static/image.png"},{"id":13,"title":"title 12","short_description":"small text 12small text 12small text 12small text 12small text 12small text 12small text 12small text 12small text 12small text 12","preview":"/static/image.png"},{"id":14,"title":"title 13","short_description":"small text 13small text 13small text 13small text 13small text 13small text 13small text 13small text 13small text 13small text 13","preview":"/static/image.png"},{"id":15,"title":"title 14","short_description":"small text 14small text 14small text 14small text 14small text 14small text 14small text 14small text 14small text 14small text 14","preview":"/static/image.png"},{"id":16,"title":"title 15","short_description":"small text 15small text 15small text 15small text 15small text 15small text 15small text 15small text 15small text 15small text 15","preview":"/static/image.png"},{"id":17,"title":"title 16","short_description":"small text 16small text 16small text 16small text 16small text 16small text 16small text 16small text 16small text 16small text 16","preview":"/static/image.png"},{"id":18,"title":"title 17","short_description":"small text 17small text 17small text 17small text 17small text 17small text 17small text 17small text 17small text 17small text 17","preview":"/static/image.png"},{"id":19,"title":"title 18","short_description":"small text 18small text 18small text 18small text 18small text 18small text 18small text 18small text 18small text 18small text 18","preview":"/static/image.png"},{"id":20,"title":"title 19","short_description":"small text 19small text 19small text 19small text 19small text 19small text 19small text 19small text 19small text 19small text 19","preview":"/static/image.png"},{"id":21,"title":"title 20","short_description":"small text 20small text 20small text 20small text 20small text 20small text 20small text 20small text 20small text 20small text 20","preview":"/static/image.png"},{"id":22,"title":"title 21","short_description":"small text 21small text 21small text 21small text 21small text 21small text 21small text 21small text 21small text 21small text 21","preview":"/static/image.png"},{"id":23,"title":"title 22","short_description":"small text 22small text 22small text 22small text 22small text 22small text 22small text 22small text 22small text 22small text 22","preview":"/static/image.png"},{"id":24,"title":"title 23","short_description":"small text 23small text 23small text 23small text 23small text 23small text 23small text 23small text 23small text 23small text 23","preview":"/static/image.png"},{"id":25,"title":"title 24","short_description":"small text 24small text 24small text 24small text 24small text 24small text 24small text 24small text 24small text 24small text 24","preview":"/static/image.png"}]sergej@fedora:~ $ 
```

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ kubectl port-forward -n production service/db 5432:5432
Forwarding from 127.0.0.1:5432 -> 5432
Forwarding from [::1]:5432 -> 5432
Handling connection for 5432

```

```shell
sergej@fedora:~ $ psql -h localhost -Upostgres -b news
psql (14.3, сервер 13.9)
Введите "help", чтобы получить справку.

news=# 
```

## Задание 2: ручное масштабирование

При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe, kubectl get pods -o wide). После уменьшите количество копий до 1.

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ kubectl get po,svc -n production -o wide
NAME                            READY   STATUS    RESTARTS   AGE   IP              NODE             NOMINATED NODE   READINESS GATES
pod/backend-7987fc7b4d-lmsqr    1/1     Running   0          26m   10.233.66.66    stage-worker-1   <none>           <none>
pod/db-0                        1/1     Running   0          26m   10.233.81.129   stage-worker-2   <none>           <none>
pod/frontend-867df49788-dkdm9   1/1     Running   0          26m   10.233.81.130   stage-worker-2   <none>           <none>

NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
service/backend    ClusterIP   10.233.12.162   <none>        9000/TCP   26m   app=backend
service/db         ClusterIP   10.233.61.240   <none>        5432/TCP   26m   app=db
service/frontend   ClusterIP   10.233.46.40    <none>        80/TCP     26m   app=frontend
```

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ kubectl scale --replicas=3 deployment/frontend -n production
deployment.apps/frontend scaled
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ kubectl scale --replicas=3 deployment/backend -n production
deployment.apps/backend scaled
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $
```

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ kubectl get po -n production -o wide
NAME                        READY   STATUS            RESTARTS   AGE   IP              NODE             NOMINATED NODE   READINESS GATES
backend-7987fc7b4d-7blcq    1/1     Running           0          46s   10.233.81.131   stage-worker-2   <none>           <none>
backend-7987fc7b4d-lmsqr    1/1     Running           0          28m   10.233.66.66    stage-worker-1   <none>           <none>
backend-7987fc7b4d-sf6wv    1/1     Running           0          46s   10.233.82.68    stage-worker-0   <none>           <none>
db-0                        1/1     Running           0          28m   10.233.81.129   stage-worker-2   <none>           <none>
frontend-867df49788-dc7ww   1/1     Running           0          67s   10.233.66.67    stage-worker-1   <none>           <none>
frontend-867df49788-dkdm9   1/1     Running           0          28m   10.233.81.130   stage-worker-2   <none>           <none>
frontend-867df49788-nfjjx   1/1     Running           0          67s   10.233.82.67    stage-worker-0   <none>           <none>
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ 
```

возвращаем обратно

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ kubectl scale --replicas=1 deployment/frontend -n production
deployment.apps/frontend scaled
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ kubectl scale --replicas=1 deployment/backend -n production
deployment.apps/backend scaled
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ kubectl get po -n production -o wide
NAME                        READY   STATUS        RESTARTS   AGE     IP              NODE             NOMINATED NODE   READINESS GATES
backend-7987fc7b4d-7blcq    1/1     Terminating   0          2m24s   10.233.81.131   stage-worker-2   <none>           <none>
backend-7987fc7b4d-lmsqr    1/1     Running       0          30m     10.233.66.66    stage-worker-1   <none>           <none>
backend-7987fc7b4d-sf6wv    1/1     Terminating   0          2m24s   10.233.82.68    stage-worker-0   <none>           <none>
db-0                        1/1     Running       0          30m     10.233.81.129   stage-worker-2   <none>           <none>
frontend-867df49788-dkdm9   1/1     Running       0          30m     10.233.81.130   stage-worker-2   <none>           <none>
sergej@fedora:~/GIT_SORE/devkub-homeworks/13-kubernetes-config-02-mounts/manifests [±|main → origin U:2 ✗|] $ 
```
