terraform {
  required_providers {
    apstra = {
      source = "Juniper/apstra"
    }
  }
}

provider "apstra" {
  # URL and credentials can be supplied using the "url" parameter in this file.
  url = "https://admin@apstra-03b20175-67d1-4ae4-811f-6a062e592dac.aws.apstra.com/"
  #
  # ...or using the environment variable APSTRA_URL.
  #
  # If Username or Password are not embedded in the URL, the provider will look
  # for them in the APSTRA_USER and APSTRA_PASS environment variables.
  #
  tls_validation_disabled = true  # CloudLabs doesn't present a valid TLS cert
  blueprint_mutex_enabled = false # Don't attempt worry about competing clients
}
