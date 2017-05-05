job "checkout" {
  region      = "global"
  datacenters = ["consul-checkout-westus2"]
  type        = "service"
  priority    = 50

  constraint {
    attribute = "${node.datacenter}"
    regexp    = "(consul-checkout-westus2)"
  }

  update {
    stagger      = "1s"
    max_parallel = 10
  }

  group "checkout" {
    count = 10

    restart {
      interval = "1m"
      attempts = 10
      delay    = "5s"
      mode     = "delay"
    }

    task "checkout" {
      driver       = "exec"
      kill_timeout = "5s"

      config {
        command = "go-checkout"
      }

      artifact {
        source = "https://s3.amazonaws.com/hashicorp-consul-nomad-demo/bin/go-checkout"
      }

      resources {
        cpu    = 20
        memory = 15
        disk   = 10

        network {
          mbits = 1

          port "checkout" {
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
        REQUEST_ADDRESS = "http://inventory.query.consul:8000/"
      }

      service {
        name = "checkout"
        port = "checkout"
        tags = ["nomad", "consul-checkout-westus2"]
      }
    }
  }
}
