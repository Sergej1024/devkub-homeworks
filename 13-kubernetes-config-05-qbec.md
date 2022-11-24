# Домашнее задание к занятию "13.5 поддержка нескольких окружений на примере Qbec"

Приложение обычно существует в нескольких окружениях. Для удобства работы следует использовать соответствующие инструменты, например, Qbec.

## Задание 1: подготовить приложение для работы через qbec

Приложение следует упаковать в qbec. Окружения должно быть 2: stage и production.

Требования:

* stage окружение должно поднимать каждый компонент приложения в одном экземпляре;
* production окружение — каждый компонент в трёх экземплярах;
* для production окружения нужно добавить endpoint на внешний адрес.

### Упакованное приложение

[qbec application](./13-kubernetes-config-05-qbec/first/):

* [components](./13-kubernetes-config-05-qbec/first/components)
  * [back.jsonnet](./13-kubernetes-config-05-qbec/first/components/back.jsonnet)
  * [statefulset.jsonnet](./13-kubernetes-config-05-qbec/first/components/statefulset.jsonnet)
  * [front.jsonnet](./13-kubernetes-config-05-qbec/first/components/front.jsonnet)
  * [pvc.jsonnet](./13-kubernetes-config-05-qbec/first/components/pvc.jsonnet)
  * [endpoint.jsonnet](./13-kubernetes-config-05-qbec/first/components/endpoint.jsonnet)

* [environments](./13-kubernetes-config-05-qbec/first/components/)
  * [base.libsonnet](./13-kubernetes-config-05-qbec/first/environments/base.libsonnet)
  * [prod.libsonnet](./13-kubernetes-config-05-qbec/first/environments/prod.libsonnet)
  * [stage.libsonnet](./13-kubernetes-config-05-qbec/first/environments/stage.libsonnet)
* [params.libsonnet](./13-kubernetes-config-05-qbec/first/params.libsonnet)
* [qbec.yaml](./13-kubernetes-config-05-qbec/first/qbec.yaml)

```shell
edora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:1 ?:1 ✗|
→ kubectl create namespace stage
namespace/stage created

fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:1 ?:1 ✗|
→ kubectl create namespace prod
namespace/prod created
```

### Проверка

Проверка, что файлы валидны с помощью `qbec validate`:

```shell
fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:1 ?:1 ✗|
→ qbec validate stage
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
cluster metadata load took 429ms
5 components evaluated in 43ms
✔ deployments backend -n stage (source back) is valid
✔ services frontend -n stage (source services) is valid
✔ statefulsets db -n stage (source statefulset) is valid
✔ deployments frontend -n stage (source front) is valid
✔ persistentvolumeclaims pvc -n stage (source pvc) is valid
✔ services backend -n stage (source services) is valid
✔ services db -n stage (source services) is valid
---
stats:
  valid: 7

command took 2.08s

fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:1 ?:1 ✗|
→ 
```

```shell
fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:1 ?:1 ✗|
→ qbec validate prod
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
cluster metadata load took 380ms
5 components evaluated in 28ms
✔ deployments backend -n prod (source back) is valid
✔ services frontend -n prod (source services) is valid
✔ statefulsets db -n prod (source statefulset) is valid
✔ deployments frontend -n prod (source front) is valid
✔ persistentvolumeclaims pvc -n prod (source pvc) is valid
✔ services db -n prod (source services) is valid
✔ services backend -n prod (source services) is valid
---
stats:
  valid: 7

command took 1.3s

fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:1 ?:1 ✗|
→ 
```

### Деплой

* [`stage`](./13-kubernetes-config-05-qbec/stage.yml)

```shell
fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:2 ?:1 ✗|
→ qbec apply stage
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
cluster metadata load took 357ms
5 components evaluated in 14ms

will synchronize 7 object(s)

Do you want to continue [y/n]: y
5 components evaluated in 9ms
create persistentvolumeclaims static-storage-pvc -n stage (source pvc)
create deployments backend -n stage (source back)
create deployments frontend -n stage (source front)
create statefulsets db -n stage (source statefulset)
create services backend -n stage (source services)
create services db -n stage (source services)
create services frontend -n stage (source services)
server objects load took 654ms
---
stats:
  created:
  - persistentvolumeclaims static-storage-pvc -n stage (source pvc)
  - deployments backend -n stage (source back)
  - deployments frontend -n stage (source front)
  - statefulsets db -n stage (source statefulset)
  - services backend -n stage (source services)
  - services db -n stage (source services)
  - services frontend -n stage (source services)

waiting for readiness of 3 objects
  - deployments backend -n stage
  - deployments frontend -n stage
  - statefulsets db -n stage

✓ 0s    : statefulsets db -n stage :: 1 new pods updated (2 remaining)
  0s    : deployments frontend -n stage :: 0 of 1 updated replicas are available
  0s    : deployments backend -n stage :: 0 of 1 updated replicas are available
✓ 12s   : deployments frontend -n stage :: successfully rolled out (1 remaining)
✓ 48s   : deployments backend -n stage :: successfully rolled out (1 remaining)

✓ 48s: rollout complete
command took 51.5s

fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:2 ?:1 ✗|
→ 
```

```shell
fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:2 ?:1 ✗|
→ kubectl -n stage get po,pv,pvc
NAME                            READY   STATUS    RESTARTS   AGE
pod/backend-8bb8fd667-qtggz     1/1     Running   0          2m30s
pod/db-0                        1/1     Running   0          9m17s
pod/frontend-5f67bcc8d4-kxxdj   1/1     Running   0          9m17s

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                      STORAGECLASS   REASON   AGE
persistentvolume/pvc-ed78aa3c-9daa-42d4-9888-eec77c818796   100Mi      RWX            Delete           Bound    stage/static-storage-pvc   nfs                     9m17s

NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/static-storage-pvc   Bound    pvc-ed78aa3c-9daa-42d4-9888-eec77c818796   100Mi      RWX            nfs            9m18s

fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:2 ?:1 ✗|
→ 
```

* [`production`](./13-kubernetes-config-05-qbec/prod.yml)

```shell
fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:2 ?:1 ✗|
→ qbec apply prod
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
cluster metadata load took 339ms
5 components evaluated in 15ms

will synchronize 7 object(s)

Do you want to continue [y/n]: y
5 components evaluated in 9ms
create persistentvolumeclaims static-storage-pvc -n prod (source pvc)
create deployments backend -n prod (source back)
create deployments frontend -n prod (source front)
create statefulsets db -n prod (source statefulset)
create services backend -n prod (source services)
create services db -n prod (source services)
create services frontend -n prod (source services)
server objects load took 679ms
---
stats:
  created:
  - persistentvolumeclaims static-storage-pvc -n prod (source pvc)
  - deployments backend -n prod (source back)
  - deployments frontend -n prod (source front)
  - statefulsets db -n prod (source statefulset)
  - services backend -n prod (source services)
  - services db -n prod (source services)
  - services frontend -n prod (source services)

waiting for readiness of 3 objects
  - deployments backend -n prod
  - deployments frontend -n prod
  - statefulsets db -n prod

  0s    : statefulsets db -n prod :: 1 of 3 updated
  0s    : deployments frontend -n prod :: 0 of 3 updated replicas are available
  0s    : deployments backend -n prod :: 0 of 3 updated replicas are available
  2s    : statefulsets db -n prod :: 2 of 3 updated
  12s   : deployments frontend -n prod :: 1 of 3 updated replicas are available
  12s   : deployments frontend -n prod :: 2 of 3 updated replicas are available
  13s   : deployments backend -n prod :: 1 of 3 updated replicas are available
✓ 49s   : deployments frontend -n prod :: successfully rolled out (2 remaining)
  49s   : deployments backend -n prod :: 2 of 3 updated replicas are available
✓ 57s   : deployments backend -n prod :: successfully rolled out (1 remaining)
✓ 1m3s  : statefulsets db -n prod :: 3 new pods updated (0 remaining)

✓ 1m3s: rollout complete
command took 1m7.28s

fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:2 ?:1 ✗|
→ 
```

```shell
fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:2 ?:1 ✗|
→ kubectl -n prod get po,pv,pvc,ep
NAME                            READY   STATUS    RESTARTS   AGE
pod/backend-8bb8fd667-5jbwk     1/1     Running   0          16m
pod/backend-8bb8fd667-8xtcx     1/1     Running   0          16m
pod/backend-8bb8fd667-s26v4     1/1     Running   0          16m
pod/db-0                        1/1     Running   0          16m
pod/db-1                        1/1     Running   0          16m
pod/db-2                        1/1     Running   0          15m
pod/frontend-5f67bcc8d4-lhn4d   1/1     Running   0          16m
pod/frontend-5f67bcc8d4-p497k   1/1     Running   0          16m
pod/frontend-5f67bcc8d4-z6kxl   1/1     Running   0          16m

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                      STORAGECLASS   REASON   AGE
persistentvolume/pvc-7847b65d-74b0-47f1-ba1e-0106e2870d35   100Mi      RWX            Delete           Bound    prod/static-storage-pvc    nfs                     16m
persistentvolume/pvc-ed78aa3c-9daa-42d4-9888-eec77c818796   100Mi      RWX            Delete           Bound    stage/static-storage-pvc   nfs                     27m

NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/static-storage-pvc   Bound    pvc-7847b65d-74b0-47f1-ba1e-0106e2870d35   100Mi      RWX            nfs            16m

NAME                     ENDPOINTS                                                AGE
endpoints/backend        10.233.66.70:9000,10.233.81.131:9000,10.233.82.68:9000   16m
endpoints/db             10.233.66.69:5432,10.233.81.133:5432,10.233.82.69:5432   16m
endpoints/external-api   158.160.46.9:443                                         25s
endpoints/frontend       10.233.66.68:80,10.233.81.132:80,10.233.82.67:80         16m

fedora:  ~/GIT_SORE/devkub-homeworks/13-kubernetes-config-05-qbec/first  |main → origin U:2 ?:1 ✗|

```
