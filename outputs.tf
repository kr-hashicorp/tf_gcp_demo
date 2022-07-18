output "internal_ip" {
 # value = google_compute_instance.demo.network_interface.0.access_config.0.nat_ip

  value = var.gpu_use == true ? google_compute_instance.gpu[0].network_interface.0.network_ip : google_compute_instance.non_gpu[0].network_interface.0.network_ip

}
