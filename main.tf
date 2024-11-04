provider "google" {
  project = "radiant-land-440421-h0"
  region  = "us-central1"
}

esource "google_storage_bucket" "my_jenkins_bucket" {
  name                     = "demo-jenkinsbucket-001"
  project                  = "radiant-land-440421-h0"
  location                 = "US"
  force_destroy            = true
  public_access_prevention = "enforced"
}

resource "null_resource" "download_index" {
  provisioner "local-exec" {
    command = "curl -o ./index.html https://raw.githubusercontent.com/oscarfernandoixcot/jenkinsRGA/main/index.html"
  }

  triggers = {
    file_version = sha256("https://raw.githubusercontent.com/oscarfernandoixcot/jenkinsRGA/main/index.html")
  }
}

resource "google_storage_bucket_object" "index" {
  name          = "index.html"
  bucket        = google_storage_bucket.my_jenkins_bucket.name
  source        = "./index.html"
  content_type  = "text/html"

}

resource "google_compute_global_address" "lb_ip" {
  name = "jenkins-lb-ip"
}

resource "google_compute_backend_bucket" "jenkins_backend" {
  name        = "jenkins-backend-bucket"
  bucket_name = google_storage_bucket.my_jenkins_bucket.name
}

resource "google_compute_url_map" "jenkins_url_map" {
  name            = "jenkins-url-map"
  default_service = google_compute_backend_bucket.jenkins_backend.self_link
}

resource "google_compute_target_http_proxy" "jenkins_http_proxy" {
  name    = "jenkins-http-proxy"
  url_map = google_compute_url_map.jenkins_url_map.self_link
}

resource "google_compute_global_forwarding_rule" "jenkins_http_forwarding_rule" {
  name       = "jenkins-http-forwarding-rule"
  ip_address = google_compute_global_address.lb_ip.address
  port_range = "80"
  target     = google_compute_target_http_proxy.jenkins_http_proxy.self_link
}
