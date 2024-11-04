resource "google_storage_bucket_object" "index" {
  name   = "index.html"
  bucket = google_storage_bucket.jenkins_page.name
  source = "index.html"
  content_type = "text/html"
}
