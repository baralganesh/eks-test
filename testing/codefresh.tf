# Add the Codefresh Helm repository
resource "helm_repository" "codefresh" {
  name = "codefresh"
  url  = "https://charts.codefresh.io"
}

# Install Codefresh
resource "helm_release" "codefresh" {
  name       = "codefresh"
  chart      = "codefresh/codefresh"
  repository = helm_repository.codefresh.metadata[0].name
  namespace  = "codefresh" # Use the desired namespace
  create_namespace = true

  # Specify your values
  set {
    name  = "property_name"
    value = "property_value"
  }

  # Specify additional configurations as needed
}