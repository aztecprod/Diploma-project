terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider yandex {
  service_account_key_file = "../../../secrets/key.json"
  cloud_id		   = var.yandex_cloud_id
  folder_id 		   = var.yandex_folder_id
  zone			   = "ru-central1-a"
}

# Web Server 1

resource "yandex_compute_instance" "web1" {

  name     = "web1"
  zone     = "ru-central1-b"
  hostname = "web1.srv."

  scheduling_policy {
    preemptible = true
  }

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd84jc4fbfvm9sdelteh"
      size     = 12
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

    user-data = "${file("./meta-web1.yml")}"
  }
}

# Web Server 2

resource "yandex_compute_instance" "web2" {

  name     = "web2"
  zone     = "ru-central1-a"
  hostname = "web2.srv."

  scheduling_policy {
    preemptible = true
  }

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd84jc4fbfvm9sdelteh"
      size     = 12
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

    user-data = "${file("./meta-web2.yml")}"
  }
}


# Prometheus Server

resource "yandex_compute_instance" "prometheus" {

  name     = "prometheus"
  zone     = "ru-central1-a"
  hostname = "prometheus.srv."

  scheduling_policy {
    preemptible = true
  }

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd84jc4fbfvm9sdelteh"
      size     = 12
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-prometheus.id}"
    dns_record {
      fqdn = "prometheus.srv."
    ttl = 300
    }
    nat = true
    security_group_ids = [yandex_vpc_security_group.sg-private.id]
  }

  metadata = {

    user-data = "${file("./meta-prometheus.yml")}"
  }
}

# Grafana Server

resource "yandex_compute_instance" "grafana" {

  name     = "grafana"
  zone     = "ru-central1-b"
  hostname = "grafana.srv."

  scheduling_policy {
    preemptible = true
  }

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd84jc4fbfvm9sdelteh"
      size     = 12
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-grafana.id}"
    dns_record {
      fqdn = "gtafana.srv."
    ttl = 300
    }
    nat = true
    security_group_ids = [yandex_vpc_security_group.sg-public.id]
  }

  metadata = {

    user-data = "${file("./meta-grafana.yml")}"
  }
}

# ElasticSearch Server

resource "yandex_compute_instance" "elasticsearch" {

  name     = "elasticsearch"
  zone     = "ru-central1-b"
  hostname = "elasticsearch.srv."

  scheduling_policy {
    preemptible = true
  }

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd84jc4fbfvm9sdelteh"
      size     = 14
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

    user-data = "${file("./meta-elasticsearch.yml")}"
  }
}

# Kibana server

resource "yandex_compute_instance" "kibana" {

  name     = "kibana"
  zone     = "ru-central1-b"
  hostname = "kibana.srv."

  scheduling_policy {
    preemptible = true
  }

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd84jc4fbfvm9sdelteh"
      size     = 14
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

    user-data = "${file("./meta-kibana.yml")}"
  }
}

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
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd84jc4fbfvm9sdelteh"
      size     = 12
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

    user-data = "${file("./meta-sshgw.yml")}"
  }
}

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

# Subnet prometheus

resource "yandex_vpc_subnet" "subnet-prometheus" {

  name           = "subnet-prometheus"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.3.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

# Subnet grafana

resource "yandex_vpc_subnet" "subnet-grafana" {

  name           = "subnet-grafana"
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


# Output

output "internal-web1" {
  value = yandex_compute_instance.web1.network_interface.0.ip_address
}

output "internal-web2" {
  value = yandex_compute_instance.web2.network_interface.0.ip_address
}

output "internal-prometheus" {
  value = yandex_compute_instance.prometheus.network_interface.0.ip_address
}

output "internal-grafana" {
  value = yandex_compute_instance.grafana.network_interface.0.ip_address
}
output "external-grafana" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}

output "internal-elastic" {
  value = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
}

output "internal-kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
}
output "external-kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "internal-sshgw" {
  value = yandex_compute_instance.sshgw.network_interface.0.ip_address
}
output "external-sshgw" {
  value = yandex_compute_instance.sshgw.network_interface.0.nat_ip_address
}

#output "external-alb" {
#  value = yandex_alb_load_balancer.alb-1.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
#}

output "external-alb" {
  value = yandex_vpc_address.addr-1.external_ipv4_address[0].address
}
