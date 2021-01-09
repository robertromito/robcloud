job "varnish" {
  datacenters = ["robcloud"]
  type        = "service"

  group "varnish" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "varnish" {

      driver = "docker"

      config {
        image = "varnish:stable"
        volumes = [
          "local/varnish.vcl:/etc/varnish/default.vcl:ro",
        ]
      }

      template {
        data = <<EOF
vcl 4.0;

backend default {
  .host = "r2d2.home";
  .port = "32400";
}
EOF
        destination = "local/varnish.vcl"
      }

      resources {
        cpu    = 500
        memory = 1024

        network {
          port "http" {
            static = 80
          }
        }
      }

      service {
        name = "varnish-server"
        port = "http"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }            
    }
  }
}