terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "y0_AgAAAAAe5bzAAATuwQAAAADegFtPgh5mgJFKSmmN3h_gtGKaIoQD6b8"
  cloud_id  = "b1glk6l56hkqpmajlhbc"
  folder_id = "b1g5bbvvnkqn9t7h7j08"
  zone      = "ru-central1-a"
}

#WEB server nginx 1 в зоне ru-central1-b

resource "yandex_compute_instance" "web1" {

  name = "web1"
  platform_id = "standard-v3"
  zone = "ru-central1-b"
  hostname = "web1.srv."

  resources {
    core_fraction = 20
    cores  = 2
    memory = 2
  }

boot_disk {
    initialize_params {
    image_id = "fd830gae25ve4glajdsj"
    size = 15
    }
  }

network_interface {
  subnet_id = "${yandex_vpc_subnet.subnet-web1.id}"
    dns_record {
      fqdn = "web1.srv."
    ttl = 300
    }
    nat = true
    security_group_ids = [yandex_vpc_security_group.sg-private.id]
  }

metadata = {
 user-data = file("./web.yaml")
  }


}
########################################################
#WEB server nginx 2 в зоне ru-central1-a

resource "yandex_compute_instance" "web2" {

  name = "web2"
  platform_id = "standard-v3"
  zone = "ru-central1-a"
  hostname = "web2.srv."

  resources {
    core_fraction = 20
    cores  = 2
    memory = 2
  }

boot_disk {
    initialize_params {
    image_id = "fd830gae25ve4glajdsj"
    size = 15
    }
  }

network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-web2.id}"
    dns_record {
      fqdn = "web2.srv."
    ttl = 300
    }
    nat = true
    security_group_ids = [yandex_vpc_security_group.sg-private.id]
  }

metadata = {
 user-data = file("./web.yaml")
  }

}
###################################################################
#  Zabbix server

resource "yandex_compute_instance" "zabbix" {

  name = "zabbix"
  platform_id = "standard-v3"
  zone = "ru-central1-b"
   hostname = "zabbix.srv."

  resources {
    core_fraction = 20
    cores  = 2
    memory = 3
  }

boot_disk {
    initialize_params {
    image_id = "fd830gae25ve4glajdsj"
    size = 10
    }
  }


network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-zabbix.id}"
    dns_record {
      fqdn = "zabbix.srv."
    ttl = 300
    }
    nat = true
    security_group_ids = [yandex_vpc_security_group.sg-public.id]
  }
metadata = {
 user-data = file("./zabbix.yaml")
  }

}
########################################################

#Elasticsearch server

resource "yandex_compute_instance" "elasticsearch" {

  name = "elasticsearch"
  platform_id = "standard-v3"
  zone = "ru-central1-a"
  hostname = "elasticsearch.srv."

  resources {
    core_fraction = 20
    cores  = 4
    memory = 8
  }

boot_disk {
    initialize_params {
    image_id = "fd830gae25ve4glajdsj"
    size = 10
    }
  }


network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-elastic.id}"
    dns_record {
      fqdn = "elastic.srv."
    ttl = 300
    }
    nat = true
    security_group_ids = [yandex_vpc_security_group.sg-private.id]
  }


metadata = {
 user-data = file("./elasticsearch.yaml")
  }

}
########################################################


# Kibana  Server

resource "yandex_compute_instance" "kibana" {

  name = "kibana"
  platform_id = "standard-v3"
  zone = "ru-central1-a"
  hostname = "kibana.srv."

  resources {
    core_fraction = 20
    cores  = 4
    memory = 8
  }

boot_disk {
    initialize_params {
    image_id = "fd830gae25ve4glajdsj"
    size = 10
    }
  }

network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-kibana.id}"
    dns_record {
      fqdn = "kibana.srv."
    ttl = 300
    }
    nat = true
    security_group_ids = [yandex_vpc_security_group.sg-public.id]
  }

metadata = {
 user-data = file("./kibana.yaml")
  }

}
#########################################


# Gateway Server

resource "yandex_compute_instance" "sshgw" {

  name     = "sshgw"
  zone     = "ru-central1-b"
  hostname = "sshgw.srv."

  scheduling_policy {
    preemptible = true
  }

  resources {
    core_fraction = 20
    cores  = 2
    memory = 2
  }

boot_disk {
    initialize_params {
    image_id = "fd830gae25ve4glajdsj"
    size = 15
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-sshgw.id}"
    dns_record {
      fqdn = "ssgw.srv."
    ttl = 300
    }
    nat = true
    security_group_ids = [yandex_vpc_security_group.sg-sshgw.id]
  }

metadata = {
 user-data = file("./default.yaml")
  }
}

#########################################
# Network

resource "yandex_vpc_network" "network-1" {

name = "network-1"
}

# Subnet web1

resource "yandex_vpc_subnet" "subnet-web1" {

  name           = "subnet-web1"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.1.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

# Subnet web2

resource "yandex_vpc_subnet" "subnet-web2" {

  name           = "subnet-web2"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.2.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}


# Subnet zabbix

resource "yandex_vpc_subnet" "subnet-zabbix" {

  name           = "subnet-zabbix"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.4.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

# Subnet elasticsearch

resource "yandex_vpc_subnet" "subnet-elastic" {

  name           = "subnet-elastic"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.5.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

# Subnet kibana

resource "yandex_vpc_subnet" "subnet-kibana" {

  name           = "subnet-kibana"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.6.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

# Subnet sshgw

resource "yandex_vpc_subnet" "subnet-sshgw" {

  name           = "subnet-sshgw"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.7.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

# alb address

resource "yandex_vpc_address" "addr-1" {
  name = "addr-1"

  external_ipv4_address {
    zone_id                  = "ru-central1-a"
  }
}

# Target group for ALB

resource "yandex_alb_target_group" "tg-1" {
  name = "tg-1"

  target { 
    subnet_id  = yandex_compute_instance.web1.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.web1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_compute_instance.web2.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.web2.network_interface.0.ip_address
  }
}

# Backend group for ALB

resource "yandex_alb_backend_group" "bg-1" {
  name = "bg-1"

  http_backend {
    name             = "backend-1"
    weight           = 1
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.tg-1.id}"]
    
    load_balancing_config {
      panic_threshold = 9
    }
    healthcheck {
      timeout  = "5s"
      interval = "2s"     
      healthy_threshold    = 2
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

# ALB router

resource "yandex_alb_http_router" "router-1" {
  name = "router-1"
}

# ALB virtual host

resource "yandex_alb_virtual_host" "vh-1" {
  name           = "vh-1"
  http_router_id = yandex_alb_http_router.router-1.id

  route {
    name = "route-1"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.bg-1.id
        timeout          = "3s"
      }
    }
  }  
}

# ALB

resource "yandex_alb_load_balancer" "alb-1" {
  name               = "alb-1"
  network_id         = yandex_vpc_network.network-1.id
  security_group_ids = [yandex_vpc_security_group.sg-balancer.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-web2.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-web1.id
    }
  }

  listener {
    name = "listener-1"
    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.addr-1.external_ipv4_address[0].address
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.router-1.id 
      }
    }
  }
}
