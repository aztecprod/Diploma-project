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

### Список серверов с их ip адресами:

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/20a58c0b-f5e3-446f-bb1a-3ce0315f4a7d)

Примечание: для доступа по ssh к серверам используем ключи RSA (Ссылка на публичный и приватный ключ ниже)

https://github.com/aztecprod/Diploma-project/tree/main/id_rsa



## Сайт
На первом этапе разворачиваем серверы nginx и балансировщик, создаем "Tagget group", "Backend group", "HTTP router" и "Application load balancer" (ALB). Данным элементам соответствуют блоки кода "Web Server 1", "Web Server 2", "Target group for ALB", "Backend group for ALB", "ALB router", "ALB virtual host", "ALB" в основном конфигурационном файле terraform main.tf, листинг которого доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/terraform/main.tf

Листинг метаданных веб-серверов web1.srv и web2.srv доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/meta-data/web

Также создаем базовые настройки сети - блок кода "Network" в основном файле конфигурации терраформ main.tf, при этом веб-сервера размещаем в разных зонах согласно Заданию.

#### Карта балансировки:
![image](https://github.com/aztecprod/Diploma-project/assets/25949605/f3c7c326-ccb1-4983-8f57-5ae9a56f01d2)


#### Application load balancer:
![image](https://github.com/aztecprod/Diploma-project/assets/25949605/d9085796-ab6f-466e-b535-80ea729be825)

#### HTTP router:
![image](https://github.com/aztecprod/Diploma-project/assets/25949605/111b3290-43b2-4794-8e95-884c23c705f7)

#### Backend Group:
![image](https://github.com/aztecprod/Diploma-project/assets/25949605/dcb5934c-689f-49da-a87d-ec227ff37e8d)

#### Target Group:
![image](https://github.com/aztecprod/Diploma-project/assets/25949605/247fb85b-1bd9-49c3-9b42-61fc89aeed63)

## Мониторинг
asdasd
## Логи
Добавляем в основной файл конфигурации терраформ main.tf блок кода "Elasticsearch Server", отвечающий за развертывыние сервера elasticserch .
Также добавляем в main.tf блок кода "Kibana Server", отвечающий за развертывание сервера визуализации логов kibana.

Листинг метаданных elasticsearch и кибана доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/meta-data/elastic


https://github.com/aztecprod/Diploma-project/blob/main/meta-data/kibana

Листинг файла конфигурации elasticsearch доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/ELK/elasticsearch/elasticsearch.yml

Листинги файлов конфигурации kibana - по ссылке


https://github.com/aztecprod/Diploma-project/blob/main/ELK/kibana/kibana.yml

Кроме того, в файлы terraform-конфигураций метаданных веб-серверов  добавлен код установки агента filebeat - поставщика данных для стека ELK.

Листинг файла конфигурации агента filebeat доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/ELK/filebeat/filebeat.yml

Доступ к веб-серверу кибана :  http://158.160.113.108:5601/


Как видно из рисунка ниже,логи от обоих веб-серверов приходят:

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/5d88cf03-1638-4b13-a72f-e5bcd5185a37)


## Сеть
Создаем виртуальную машину sshgw.srv, доступ на которую будет осуществляться по протоколу ssh, и с которой можно будет получить доступ к остальным серверам инфраструктуры. Для этого добавляем соответсвующий блок кода "Gateway Server" в конфигурационный файл main.tf. Листинг метаданных сервера sshgw доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/meta-data/default

Создаем группы безопасности, конфигурацию которых для наглядности помещаем в отдельный конфигурационный файл sg.tf, листинг которого доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/terraform/sg.tf

Всего создаем 4 группы безопасности: sg-balancer - для балансировщика, sg-sshgw - для сервера sshgw, sg-private - для группы серверов, досуп к которым не разрешен из сети Интернет, sg-public - для группы серверов, доступ к которым возможен из сети интернет по определеным портам, соответствующим публикуемым сервисам.

В группу безопасности sg-private включаем сервера web1.srv, web2.srv  и elastic.srv
В группу безопасности sg-public - сервера zabbix.srv и kibana.srv

Включение сервера в определенную группу безопасности осуществляется заданием параметра security_group_ids в блоке network_interface, описывающем сетевую конфигурацию каждого сервера в файле конфигурации main.tf

Собираем инфраструктуру в терраформ и в консоли управления Yandex Cloud смотрим информацию о группах безопасности 

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/3a0ec3a8-36f1-4dc9-b37c-a13acf1ae632)

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/428042da-9c3d-4db5-b35d-424bc7477f32)

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/881fc533-9fbe-40fd-8ca6-a9ba1fcdd7e1)


![image](https://github.com/aztecprod/Diploma-project/assets/25949605/408ef125-155c-4fca-9502-649283bacc22)


![image](https://github.com/aztecprod/Diploma-project/assets/25949605/3dbe1189-3ff2-4b6c-b6e2-3ab59b8c1946)





## Резервное копирование
Создаем файл конфигурации backup.tf, содержащий код расписания, по которому будут создаваться снапшоты дисков всех виртуальных машин, входящих в инфраструктуру. Листинг файла backup.tf доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/terraform/backup.tf

В соответствии с Заданием определяем snapshot_count = 1, expression = "0 0 * * SUN" (т.е. снапшоты дисков будут создаваться каждое воскресенье в полночь).

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/6588b9f5-bd62-4134-b74d-5ffe09f3e16b)

