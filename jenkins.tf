resource "google_compute_firewall" "config-externalssh" {
  name    = "config-externalssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "config-jenkins" {
  name    = "config-jenkins"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["50000", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["config-jenkins"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "n1-standard-8"

  tags = ["config-jenkins", "ssh"]

  boot_disk {
    initialize_params {
      image = "centos-8"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  #metadata_startup_script = file("${path.module}/startup.sh")

  // provisioner "file" {
  //   source     = "${path.module}/jenkins-config.sh"
  //   destination = "/tmp/jenkins-config.sh"
  // }

  // provisioner "remote-exec" {
  //        inline = [
  //          "chmod +x /tmp/jenkins-config.sh",
  //          "sudo /tmp/jenkins-config.sh",
  //        ]
  // }

  // connection {
  //   type        = "ssh"
  //   host        = self.network_interface[0].access_config[0].nat_ip
  //   user        = "${var.user}"
  //   timeout	    = "5m"
  //   private_key = file(var.prv_key)
  // }

    provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' ansible/site.yaml"
  }

  metadata = {
    ssh-keys = "${var.user}:${file(var.pub_key)}\""
  }

}



