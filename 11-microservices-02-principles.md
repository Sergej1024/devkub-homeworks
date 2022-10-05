
# Домашнее задание к занятию "11.02 Микросервисы: принципы"

Вы работаете в крупной компанию, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps специалисту необходимо выдвинуть предложение по организации инфраструктуры, для разработки и эксплуатации.

## Задача 1: API Gateway 

Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.

Решение должно соответствовать следующим требованиям:
- Маршрутизация запросов к нужному сервису на основе конфигурации
- Возможность проверки аутентификационной информации в запросах
- Обеспечение терминации HTTPS

Обоснуйте свой выбор.

||NGINX Plus|HAProxy|Spring Cloud|Kong|KrakenD|
|:---|:---:|:---:|:---:|:---:|:---:|
|Маршрутизация запросов|LUA|LUA|yml, code|Plugins|json|
|Аутентификация в запросах|+|+|+|+|+|
|Терминация HTTPS|+|+|+|+|+|

Для перечисленных требований в качестве решения можно использовать любой продукт из таблицы. Nginx Plus, HAProxy являются стабильными, надежными решениями, их функционала будет достаточно для обеспечения балансировки, проксирования соединений, установки как внешних так и внутренних лимитов сторости/времени подключения. Так же оба продукта могут обеспечить терминацию https трафика пользователей.

Kong, KrakenD являются полноценнми программынми API шлюзами, они способны предложить владельцу расширенный функционал авторизации, единый протокол API для всех клиентов, продвинутые функции администрирования и мониторинга состояния. Множество интересных функций к сожалению доступны только в Enterprise версии.
Исходя из информации, полученной из открытых источников, могу сделать вывод: в случае развертываения инфраструктуры в облаке лучшим инструментом являются шлюзы, предоставляеме постащиком услуг (Sbercloud API gateway, Yandex.cloud API gateway и т.д.) по причине наилучшей интерграции с другими сервисами, но эти сервисы конфгурируются через веб-интерфейс.

В случае необходимости использования стороннего шлюза наиболе подходящими под требования задания считаю Kong по следующим причинам:
- бесплатное решение;
- платформо-независимость;
- наличие готовых сборок для Kubernetes, Docker Swarm, Mesos 
- можно запускать на bare metal серверах;
- есть динамический алгоритм балансировки трафика;
- есть различные механизмы авторизации пользователя;
- широкий выбор LUA-модулей, расширяющих возможности.


## Задача 2: Брокер сообщений

Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.

Решение должно соответствовать следующим требованиям:
- Поддержка кластеризации для обеспечения надежности
- Хранение сообщений на диске в процессе доставки
- Высокая скорость работы
- Поддержка различных форматов сообщений
- Разделение прав доступа к различным потокам сообщений
- Протота эксплуатации

Обоснуйте свой выбор.

| |RabbitMQ|Kafka|PULSAR|
|:---|:---:|:---:|:---:|
|Поддержка кластеризации|+|+|+|
|Хранение на диске|+|+|+|
|Скорость работы|~38 MB/s|~605 MB/s|~305 MB/s|
|Различные форматы сообщений|AMQP, MQTT, STOMP|Binary через TCP Socket|Binary через TCP Socket|
|Разграничение прав доступа|+|+|+|
|Простота эксплуатации|+|+|-|

На основании данных о брокерах сообщений считаю, что лучшим выбором для этого задания будет Kafka, т.к. он позволяет реализовать распределенную очередь с высокой пропускной способностью и длительное хранение больших объемов данных, достаточно широко распространён, хорошо масштабируется и имеет хорошую документацию.

## Задача 3: API Gateway * (необязательная)

### Есть три сервиса:

**minio**
- Хранит загруженные файлы в бакете images
- S3 протокол

**uploader**
- Принимает файл, если он картинка сжимает и загружает его в minio
- POST /v1/upload

**security**
- Регистрация пользователя POST /v1/user
- Получение информации о пользователе GET /v1/user
- Логин пользователя POST /v1/token
- Проверка токена GET /v1/token/validation

### Необходимо воспользоваться любым балансировщиком и сделать API Gateway:

**POST /v1/register**
- Анонимный доступ.
- Запрос направляется в сервис security POST /v1/user

**POST /v1/token**
- Анонимный доступ.
- Запрос направляется в сервис security POST /v1/token

**GET /v1/user**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис security GET /v1/user

**POST /v1/upload**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис uploader POST /v1/upload

**GET /v1/user/{image}**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис minio  GET /images/{image}

### Ожидаемый результат

Результатом выполнения задачи должен быть docker compose файл запустив который можно локально выполнить следующие команды с успешным результатом.
Предполагается что для реализации API Gateway будет написан конфиг для NGinx или другого балансировщика нагрузки который будет запущен как сервис через docker-compose и будет обеспечивать балансировку и проверку аутентификации входящих запросов.
Авторизаци
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token

**Загрузка файла**

curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @yourfilename.jpg http://localhost/upload

**Получение файла**
curl -X GET http://localhost/images/4e6df220-295e-4231-82bc-45e4b1484430.jpg

---

#### [Дополнительные материалы: как запускать, как тестировать, как проверить](https://github.com/netology-code/devkub-homeworks/tree/main/11-microservices-02-principles)

---

```shell
sergej@fedora:~/GIT_SORE/devkub-homeworks/11-microservices-02-principles [±|main → origin U:2 ?:1 ✗|] $ curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @1.1.png http://localhost/upload
{"filename":"705be922-9fb3-48e8-9d3e-074a920fafba.png"}
sergej@fedora:~/GIT_SORE/devkub-homeworks/11-microservices-02-principles [±|main → origin U:2 ?:1 ✗|] $ curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I
sergej@fedora:~/GIT_SORE/devkub-homeworks/11-microservices-02-principles [±|main → origin U:2 ?:2 ✗|] $ curl localhost/images/705be922-9fb3-48e8-9d3e-074a920fafba.png > 705be922-9fb3-48e8-9d3e-074a920fafba.png
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   351  100   351    0     0    99k      0 --:--:-- --:--:-- --:--:--  114k
sergej@fedora:~/GIT_SORE/devkub-homeworks/11-microservices-02-principles [±|main → origin U:2 ?:3 ✗|] $ ls -l
итого 104
-rw-r--r-- 1 sergej sergej 74382 окт  3 08:06 1.1.png
-rw-r--r-- 1 sergej sergej   351 окт  5 11:41 705be922-9fb3-48e8-9d3e-074a920fafba.png
-rw-r--r-- 1 sergej sergej  1662 окт  3 14:07 docker-compose.yaml
drwxr-xr-x 2 sergej sergej  4096 окт  3 14:07 gateway
drwxr-xr-x 2 sergej sergej  4096 окт  5 11:35 img
-rw-r--r-- 1 sergej sergej  1719 окт  3 14:07 readme.md
drwxr-xr-x 3 sergej sergej  4096 окт  3 14:07 security
drwxr-xr-x 3 sergej sergej  4096 окт  3 14:07 uploader
sergej@fedora:~/GIT_SORE/devkub-homeworks/11-microservices-02-principles [±|main → origin U:2 ?:3 ✗|] $ 
```

[nginx-gateway](./11-microservices-02-principles/gateway/nginx.conf)

<details><summary>Скрины</summary>

![](./11-microservices-02-principles/img/3.1.png)
![](./11-microservices-02-principles/img/3.2.png)

</details>
