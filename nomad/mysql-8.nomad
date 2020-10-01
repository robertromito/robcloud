job "mysql-8" {
  datacenters = ["robcloud"]
  type        = "service"

  group "mysql-server" {
    count = 1

    volume "mysql" {
      type      = "host"
      read_only = false
      source    = "mysql"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "mysql-server" {
      driver = "docker"

      volume_mount {
        volume      = "mysql"
        destination = "/var/lib/mysql"
        read_only   = false
      }

      template {
        data = <<EOH
MYSQL_ROOT_PASSWORD = "{{key "mysql/root_password"}}"
EOH
        destination = "secrets/config.env"
        env = true
      }

      config {
        image = "mysql:8"

        port_map {
          db = 3306
        }
      }

      resources {
        cpu    = 500
        memory = 1024

        network {
          port "db" {
            static = 3306
          }
        }
      }

      service {
        name = "mysql-server"
        port = "db"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}