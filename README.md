# Дипломная работа профессии Системный администратор - Александр Шевцов

Задание: https://github.com/netology-code/sys-diplom/tree/diplom-zabbix

Решение:

В облаке развертываются следующие сервера:

web1.srv, web2.srv - веб-серверы nginx, на которых установлены сервисы zabbix-agent и filebeat, позволяющие передавать информацию мониторинга и содержимом логов на серверы zabbix и elasticsearch соответственно;

zabbix.srv - сервер визуализации информации, собираемой сервером мониторинга zabbix;

elastic.srv - сервер сбора логов, на котором подняты сервисы esasticsearch и logstash, входяшие в стек ELK;

kibana.srv - сервер визуализации логов (также из стека ELK);

sshgw.srv - (ssh gateway), сервер, позволяющий получить доступ к остальным серверам инфраструктуры по протоколу ssh.

Создание инфрастукткры в terraform осуществлялось путем последовательного добавления блоков кода в конфигурационные файлы с последующей сборкой-разборкой инфраструктуры и отладкой добавляемых блоков кода.

## Сайт

## Мониторинг

## Логи


