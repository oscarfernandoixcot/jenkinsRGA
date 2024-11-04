resource "google_storage_bucket" "my_jenkins_bucket" {
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

