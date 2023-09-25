resource "yandex_compute_snapshot_schedule" "default" {
  name = "default"

  schedule_policy {
    expression = "@weekly"
  }

  snapshot_count = 1

  snapshot_spec {
    description = "daily"
  }

  disk_ids = [yandex_compute_instance.web1.boot_disk[0].disk_id, 
              yandex_compute_instance.web2.boot_disk[0].disk_id, 
              yandex_compute_instance.prometheus.boot_disk[0].disk_id, 
              yandex_compute_instance.grafana.boot_disk[0].disk_id, 
              yandex_compute_instance.elasticsearch.boot_disk[0].disk_id, 
              yandex_compute_instance.kibana.boot_disk[0].disk_id, 
              yandex_compute_instance.sshgw.boot_disk[0].disk_id]
}
