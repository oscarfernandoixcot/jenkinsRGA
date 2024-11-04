resource "google_storage_bucket" "my-jenkinsbucket" {
  name                     = "demo-jenkinsbucket-001"
  project                  = "radiant-land-440421-h0"
  location                 = "US"
  force_destroy            = true
  public_access_prevention = "enforced"
}

resource "google_storage_bucket_object" "index" {
  name          = "index.html"
  bucket        = google_storage_bucket.my_jenkins_bucket.name
  source        = "path/to/your/local/index.html" # Change to the actual path of your index.html file
  content_type  = "text/html"
}
