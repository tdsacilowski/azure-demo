variable "region" {
  default = "global"
}

variable "datacenter" {
  default = "global"
}

variable "nginx_count" {
  default = "1"
}

variable "nginx_image" {
  default = "hashidemo/nginx:latest"
}

variable "nodejs_count" {
  default = "3"
}

variable "nodejs_image" {
  default = "hashidemo/nodejs:latest"
}

module "web" {
  source = "./web"

  region       = "${var.region}"
  datacenter   = "${var.datacenter}"
  nginx_count  = "${var.nginx_count}"
  nginx_image  = "${var.nginx_image}"
  nodejs_count = "${var.nodejs_image}"
  nodejs_image = "${var.nodejs_image}"
}

output "cmd" {
  value = <<CMD
echo "Creating job files"

echo "Creating web example job files"

cat > /opt/nomad/jobs/web.nomad <<EOF
${module.web.job}
EOF

echo "Finished creating job files"
CMD
}
