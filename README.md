# Дипломная работа профессии Системный администратор - Александр Шевцов

#### Задание: https://github.com/netology-code/sys-diplom/tree/diplom-zabbix

#### Решение:

В облаке развертываются следующие сервера:

web1.srv, web2.srv - веб-серверы nginx, на которых установлены сервисы zabbix-agent и filebeat, позволяющие передавать информацию мониторинга и содержимом логов на серверы zabbix и elasticsearch соответственно;

zabbix.srv - сервер визуализации информации, собираемой сервером мониторинга zabbix;

elastic.srv - сервер сбора логов, на котором подняты сервис elasticsearch, входящий в стек ELK;

kibana.srv - сервер визуализации логов (также из стека ELK);

sshgw.srv - (ssh gateway), сервер, позволяющий получить доступ к остальным серверам инфраструктуры по протоколу ssh.

Создание инфрастукткры в terraform осуществлялось путем последовательного добавления блоков кода в конфигурационные файлы с последующей сборкой-разборкой инфраструктуры и отладкой добавляемых блоков кода.

### Список серверов с их ip адресами:

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/1a75e134-a57d-4775-8d2c-9d32ff256a0b)


Примечание: для доступа по ssh к серверам используем ключи RSA 


## Сайт
На первом этапе разворачиваем серверы nginx и балансировщик, создаем "Tagget group", "Backend group", "HTTP router" и "Application load balancer" (ALB). Данным элементам соответствуют блоки кода "Web Server 1", "Web Server 2", "Target group for ALB", "Backend group for ALB", "ALB router", "ALB virtual host", "ALB" в основном конфигурационном файле terraform main.tf, листинг которого доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/terraform/main.tf

Листинг метаданных веб-серверов web1.srv и web2.srv доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/meta-data/web

Также создаем базовые настройки сети - блок кода "Network" в основном файле конфигурации терраформ main.tf, при этом веб-сервера размещаем в разных зонах согласно Заданию.

#### Карта балансировки:
![image](https://github.com/aztecprod/Diploma-project/assets/25949605/52402f3f-aa31-408f-83e0-1f2a254dd88a)



#### Application load balancer:
![image](https://github.com/aztecprod/Diploma-project/assets/25949605/405c4df6-3b4f-451a-9785-254296897ec3)


#### HTTP router:
![image](https://github.com/aztecprod/Diploma-project/assets/25949605/87613b00-6b3e-4d0c-8de9-e495ae3c4a43)



#### Backend Group:
![image](https://github.com/aztecprod/Diploma-project/assets/25949605/1f643794-0fb9-4621-a186-e80841e0b404)



#### Target Group:
![image](https://github.com/aztecprod/Diploma-project/assets/25949605/1db41232-d961-47e7-aff8-128268d5b6a6)


#### Проверяем работу балансировщика,сделав к нему запрос через curl -v <публичный IP балансера>:80 

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/3edd2f65-fae7-4f7c-98ca-da8b927c1331)

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/324a57f7-46ef-46c7-992d-9227a6a8b6b2)

 

Как видим backend ip меняется с web1 на web2,значит балансировщик распеределяет трафик между веб-серверами

## Мониторинг
Добавляем сервер Zabbix (блок кода "Zabbix Server" в конфигурационном файле main.tf). Листинг файла terraform-конфигурации zabbix доступен по ссылке

https://github.com/aztecprod/Diploma-project/blob/main/terraform/main.tf

Плейбук установки zabbix-server и zabbix-agent через ansible - по ссылке

https://github.com/aztecprod/Diploma-project/tree/main/ansible

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/3ab70430-be8f-4b5b-a630-f8b5b4c573d5)


Доступ к веб-серверу zabbix

#### http://158.160.14.187:8080/

Логин: Admin

Пароль: zabbix

Доступность zabbix-агентов

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/e8de5931-4600-4bfc-b46f-13327a87aa02)



Созданный дашбоард:

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/7feb5d8c-9653-41a0-b7cc-170b22aae0c3)

## Логи
Добавляем в основной файл конфигурации терраформ main.tf блок кода "Elasticsearch Server", отвечающий за развертывыние сервера elasticserch .
Также добавляем в main.tf блок кода "Kibana Server", отвечающий за развертывание сервера визуализации логов kibana.

Плейбук установки elasticsearch и kibana через ansible - по ссылке

https://github.com/aztecprod/Diploma-project/tree/main/ansible

Плейбук установки filebeat - по ссылке

https://github.com/aztecprod/Diploma-project/tree/main/ansible

Доступ к веб-серверу кибана :  http://51.250.86.194:5601/


Как видно из рисунка ниже,логи от обоих веб-серверов приходят:

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/1dfc2a83-8eb6-4ae5-9c9c-2695a3395230)




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

В соответствии с Заданием определяем snapshot_count = 7, expression = "0 5 ? * *" (т.е. снапшоты дисков будут создаваться один раз в сутки в 5:00).

![image](https://github.com/aztecprod/Diploma-project/assets/25949605/bc92183e-3666-4664-99b3-fb2e64bb55ed)



