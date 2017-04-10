job "inventory" {
  region      = "global"
  datacenters = ["checkout-dc1", "inventory-east", "inventory-west"]
  type        = "system"
  priority    = 50

  constraint {
    attribute = "${node.datacenter}"
    regexp    = "(checkout-dc1|inventory-east|inventory-west)"
  }

  update {
    stagger      = "1s"
    max_parallel = 10
  }

  group "inventory" {
    restart {
      interval = "1m"
      attempts = 10
      delay    = "5s"
      mode     = "delay"
    }

    task "inventory" {
      driver       = "exec"
      kill_timeout = "5s"

      config {
        command = "go-inventory"
      }

      artifact {
        source = "https://s3.amazonaws.com/hashicorp-consul-nomad-demo/bin/go-inventory"
      }

      resources {
        cpu    = 20
        memory = 15
        disk   = 10

        network {
          mbits = 1

          port "inventory" {
            static = 8000
          }
        }
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      env {
        NODE_DATACENTER = "${node.datacenter}"
        REDIS_ADDRESS   = "redis.query.consul:6379"
      }

      service {
        name = "inventory"
        port = "inventory"
        tags = ["nomad", "checkout-dc1", "inventory-east", "inventory-west"]

        check {
          name     = "Inventory alive"
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
