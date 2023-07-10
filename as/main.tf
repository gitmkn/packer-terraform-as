data "tencentcloud_images" "my_favorate_image" {
  image_type = ["PRIVATE_IMAGE"]
  image_name_regex    = "^PackerTest-*"
}

resource "tencentcloud_vpc" "vpc" {
  name       = "tf-as-vpc"
  cidr_block = "10.2.0.0/16"
}

resource "tencentcloud_subnet" "subnet" {
  vpc_id            = tencentcloud_vpc.vpc.id
  name              = "tf-as-subnet"
  cidr_block        = "10.2.11.0/24"
  availability_zone = var.availability_zone
}

resource "tencentcloud_as_scaling_config" "launch_configuration" {
  configuration_name = "tf-as-configuration"
  image_id           = data.tencentcloud_images.my_favorate_image.images[0].image_id
  instance_types     = [var.instance_type]
  project_id         = 0
  system_disk_type   = "CLOUD_PREMIUM"
  system_disk_size   = "50"

  data_disk {
    disk_type = "CLOUD_PREMIUM"
    disk_size = 50
  }

  internet_charge_type       = "TRAFFIC_POSTPAID_BY_HOUR"
  internet_max_bandwidth_out = 10
  public_ip_assigned         = true
  password                   = "test123#"
  enhanced_security_service  = false
  enhanced_monitor_service   = false
  user_data                  = "test"

  instance_tags = {
    tag = "as"
  }
}


resource "tencentcloud_clb_instance" "internal_clb" {
  address_ip_version           = "ipv4"
  clb_name                     = "packer-jenkins"
  internet_bandwidth_max_out   = 5
  internet_charge_type         = "TRAFFIC_POSTPAID_BY_HOUR"
  load_balancer_pass_to_target = true
  network_type                 = "OPEN"
  project_id                   = 0
  target_region_info_region    = "ap-guangzhou"
  target_region_info_vpc_id    = tencentcloud_vpc.vpc.id
  vpc_id                       = tencentcloud_vpc.vpc.id
}

resource "tencentcloud_clb_listener" "HTTP_listener" {
  clb_id                     = tencentcloud_clb_instance.internal_clb.id
  health_check_health_num    = 3
  health_check_interval_time = 5
  health_check_switch        = true
  health_check_time_out      = 2
  health_check_type          = "TCP"
  health_check_unhealth_num  = 3
  listener_name              = "packer-jerkins-listener"
  port                       = 8080
  protocol                   = "TCP"
  scheduler                  = "WRR"
#  sni_switch                 = false
  target_type                = "NODE"
}

resource "tencentcloud_as_scaling_group" "scaling_group" {
  scaling_group_name   = "tf-as-scaling-group"
  configuration_id     = tencentcloud_as_scaling_config.launch_configuration.id
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_id               = tencentcloud_vpc.vpc.id
  subnet_ids           = [tencentcloud_subnet.subnet.id]
  project_id           = 0
  default_cooldown     = 400
  desired_capacity     = var.desired_capacity
  termination_policies = ["NEWEST_INSTANCE"]
  retry_policy         = "INCREMENTAL_INTERVALS"

  forward_balancer_ids {
    load_balancer_id = tencentcloud_clb_instance.internal_clb.id
    listener_id      = tencentcloud_clb_listener.HTTP_listener.listener_id
    target_attribute {
      port   = 8080
      weight = 90
    }
  }

  tags = {
    "test" = "test"
  }
}
