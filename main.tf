resource "google_storage_bucket" "my-jenkinsbucket" {
  name                     = "demo-jenkinsbucket-001"
  project                  = "radiant-land-440421-h0"
  location                 = "US"
  force_destroy            = true
  public_access_prevention = "enforced"
}
