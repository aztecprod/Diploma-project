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
На первом этапе разворачиваем серверы nginx и балансировщик, создаем "Tagget group", "Backend group", "HTTP router" и "Application load balancer" (ALB). Данным элементам соответствуют блоки кода "Web Server 1", "Web Server 2", "Target group for ALB", "Backend group for ALB", "ALB router", "ALB virtual host", "ALB" в основном конфигурационном файле terraform main.tf, листинг которого доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/terraform/main.tf

Листинг метаданных веб-серверов web1.srv и web2.srv доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/meta-data/web

Также создаем базовые настройки сети - блок кода "Network" в основном файле конфигурации терраформ main.tf, при этом веб-сервера размещаем в разных зонах согласно Заданию.

Примечание: для доступа по ssh к серверам используем ключи RSA (Ссылка на публичный и приватный ключ ниже)

https://github.com/aztecprod/Diploma-project/tree/main/id_rsa

## Мониторинг
asdasd
## Логи
Добавляем в основной файл конфигурации терраформ main.tf блок кода "Elasticsearch Server", отвечающий за развертывыние сервера elasticserch .
Также добавляем в main.tf блок кода "Kibana Server", отвечающий за развертывание сервера визуализации логов kibana.

Листинг файла terraform-конфигурации сервера elasticsearch и кибана доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/meta-data/elastic

https://github.com/aztecprod/Diploma-project/blob/main/meta-data/kibana

Листинг файла конфигурации elasticsearch доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/ELK/elasticsearch/elasticsearch.yml

Листинги файлов конфигурации kibana - по ссылке
https://github.com/aztecprod/Diploma-project/blob/main/ELK/kibana/kibana.yml

Кроме того, в файлы terraform-конфигураций метаданных веб-серверов  добавлен код установки агента filebeat - поставщика данных для стека ELK.

Листинг файла конфигурации агента filebeat доступен поссылке
https://github.com/aztecprod/Diploma-project/blob/main/ELK/filebeat/filebeat.yml

## Сеть
Создаем виртуальную машину sshgw.srv, доступ на которую будет осуществляться по протоколу ssh, и с которой можно будет получить доступ к остальным серверам инфраструктуры. Для этого добавляем соответсвующий блок кода "Gateway Server" в конфигурационный файл main.tf. Листинг terraform-конфигурации сервера sshgw доступен по ссылке

https://github.com/sdsdsL/sys-diplom/blob/main/sshgw/meta-sshgw.yml

Создаем группы безопасности, конфигурацию которых для наглядности помещаем в отдельный конфигурационный файл sg.tf, листинг которого доступен по ссылке

https://github.com/sdsdsL/sys-diplom/blob/main/config/sg.tf

Всего создаем 4 группы безопасности: sg-balancer - для балансировщика, sg-sshgw - для сервера sshgw, sg-private - для группы серверов, досуп к которым не разрешен из сети Интернет, sg-public - для группы серверов, доступ к которым возможен из сети интернет по определеным портам, соответствующим публикуемым сервисам.

В группу безопасности sg-private включаем сервера web1.srv, web2.srv  и elastic.srv
В группу безопасности sg-public - сервера zabbix.srv и kibana.srv

Включение сервера в определенную группу безопасности осуществляется заданием параметра security_group_ids в блоке network_interface, описывающем сетевую конфигурацию каждого сервера в файле конфигурации main.tf

Собираем инфраструктуру в терраформ и в консоли управления yandex Cloud смотрим информацию о группах безопасности 
## Резервное копирование
