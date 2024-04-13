resource "google_compute_address" "static_ip" {
  name = var.ip_name
}


output "show_ip" {
  value = google_compute_address.static_ip.address
}