resource "helm_release" "codefresh" {
  name       = "codefresh"
  namespace  = "codefresh" # Replace with your desired namespace
  repository = "https://charts.codefresh.io" # Codefresh Helm repo URL
  chart      = "codefresh" # Replace with the chart name

  # Specify your values
  #set {
  #  name  = "property_name"
  #  value = "property_value"
  #}

  # Additional settings can be configured here
}
