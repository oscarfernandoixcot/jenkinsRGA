provider "google" {
  project = "radiant-land-440421-h0"
  region  = "us-central1"
}

# 1. Storage Bucket for HTML File
resource "google_storage_bucket" "my_jenkins_bucket" {
  name                     = "demo-jenkinsbucket-001"
  project                  = "radiant-land-440421-h0"
  location                 = "US"
  force_destroy            = true
  public_access_prevention = "enforced"
}

# 2. Download `index.html` from GitHub
resource "null_resource" "download_index" {
  provisioner "local-exec" {
    command = "curl -o ./index.html https://raw.githubusercontent.com/oscarfernandoixcot/jenkinsRGA/main/index.html"
  }

  # Trigger this only if the URL changes (or force re-run)
  triggers = {
    file_version = sha256("https://raw.githubusercontent.com/oscarfernandoixcot/jenkinsRGA/main/index.html")
  }
}

# 3. Upload `index.html` to GCS Bucket
resource "google_storage_bucket_object" "index" {
  name          = "index.html"
  bucket        = google_storage_bucket.my_jenkins_bucket.name
  source        = "./index.html"
  content_type  = "text/html"

  # Ensure the file is downloaded before uploading to GCS
  depends_on = [null_resource.download_index]
}

# 4. Reserve a Global IP for the Load Balancer
resource "google_compute_global_address" "lb_ip" {
  name = "jenkins-lb-ip"
}

# 5. Backend Bucket for the Load Balancer
resource "google_compute_backend_bucket" "jenkins_backend" {
  name        = "jenkins-backend-bucket"
  bucket_name = google_storage_bucket.my_jenkins_bucket.name
}

# 6. URL Map to Route Traffic
resource "google_compute_url_map" "jenkins_url_map" {
  name            = "jenkins-url-map"
  default_service = google_compute_backend_bucket.jenkins_backend.self_link
}

# 7. HTTP Proxy for the Load Balancer
resource "google_compute_target_http_proxy" "jenkins_http_proxy" {
  name    = "jenkins-http-proxy"
  url_map = google_compute_url_map.jenkins_url_map.self_link
}

# 8. Forwarding Rule to Direct Traffic to Proxy
resource "google_compute_global_forwarding_rule" "jenkins_http_forwarding_rule" {
  name       = "jenkins-http-forwarding-rule"
  ip_address = google_compute_global_address.lb_ip.address
  port_range = "80"
  target     = google_compute_target_http_proxy.jenkins_http_proxy.self_link
}
