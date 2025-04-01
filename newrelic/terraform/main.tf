# Configure terraform
terraform {
  required_version = "~> 1.0"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
    }
  }
}

variable "cluster_name" {
  type    = string
  description = "The name of the k8s cluster used to run the OpenTelemetry demo."
}

variable "account_id" {
  type = number
  description = "The account to apply the changes to."
}

# Configure the New Relic provider
provider "newrelic" {
  account_id = var.account_id
}

# Create a workload with all entities deployed to the demo cluster 
resource "newrelic_workload" "otel-demo-all-entities" {
    name = "OpenTelemetry Demo - All Entities"
    account_id = var.account_id

    entity_search_query {
      query = "tags.clusterName = '${var.cluster_name}' OR tags.k8s.cluster.name = '${var.cluster_name}' OR tags.displayName = '${var.cluster_name}'"
    }

    scope_account_ids =  [var.account_id]
}


# Get the entity guid for the AdService OTel service
data "newrelic_entity" "ad-entity" {
  name = "ad"
  tag {
    key = "accountID"
    value = "${var.account_id}"
  }
}

# Get the entity guid for the ProductCatalog OTel service
data "newrelic_entity" "productcatalog-entity" {
  name = "product-catalog"
  tag {
    key = "accountID"
    value = "${var.account_id}"
  }
}

# Get the entity guid for the ProductCatalog OTel service
data "newrelic_entity" "checkout-entity" {
  name = "checkout"
  tag {
    key = "accountID"
    value = "${var.account_id}"
  }
}

# Get the entity guid for the ProductCatalog OTel service
data "newrelic_entity" "payment-entity" {
  name = "payment"
  tag {
    key = "accountID"
    value = "${var.account_id}"
  }
}

# # Create a service level for Ad
# resource "newrelic_service_level" "adservice-service-level" {
#     guid = data.newrelic_entity.adservice-entity.id
#     name = "Ad Service Level"
#     description = "Proportion of successful requests."

#     events {
#         account_id = var.account_id
#         valid_events {
#             from = "Span"
#             where = "entity.guid='${data.newrelic_entity.adservice-entity.id}' AND (span.kind IN ('server', 'consumer') OR kind IN ('server', 'consumer'))"
#         }
#         bad_events {
#             from = "Span"
#             where = "entity.guid='${data.newrelic_entity.adservice-entity.id}' AND (span.kind IN ('server', 'consumer') OR kind IN ('server', 'consumer')) AND otel.status_code = 'ERROR'"
#         }
#     }

#     objective {
#         target = 99.25
#         time_window {
#             rolling {
#                 count = 1
#                 unit = "DAY"
#             }
#         }
#     }
# }


# Create a service level for Checkout 
resource "newrelic_service_level" "checkout-service-level" {
    guid = data.newrelic_entity.checkout-entity.id
    name = "Checkout Service Level"
    description = "Proportion of successful requests."

    events {
        account_id = var.account_id
        valid_events {
            from = "Span"
            where = "entity.guid='${data.newrelic_entity.checkout-entity.id}' AND (span.kind IN ('server', 'consumer') OR kind IN ('server', 'consumer'))"
        }
        bad_events {
            from = "Span"
            where = "entity.guid='${data.newrelic_entity.checkout-entity.id}' AND (span.kind IN ('server', 'consumer') OR kind IN ('server', 'consumer')) AND otel.status_code = 'ERROR'"
        }
    }

    objective {
        target = 99.25
        time_window {
            rolling {
                count = 1
                unit = "DAY"
            }
        }
    }
}

# Create a service level for Product Catalog 
resource "newrelic_service_level" "productcatalog-service-level" {
    guid = data.newrelic_entity.productcatalog-entity.id
    name = "Product Catalog Service Level"
    description = "Proportion of successful requests."

    events {
        account_id = var.account_id
        valid_events {
            from = "Span"
            where = "entity.guid='${data.newrelic_entity.productcatalog-entity.id}' AND (span.kind IN ('server', 'consumer') OR kind IN ('server', 'consumer'))"
        }
        bad_events {
            from = "Span"
            where = "entity.guid='${data.newrelic_entity.productcatalog-entity.id}' AND (span.kind IN ('server', 'consumer') OR kind IN ('server', 'consumer')) AND otel.status_code = 'ERROR'"
        }
    }

    objective {
        target = 99.25
        time_window {
            rolling {
                count = 1
                unit = "DAY"
            }
        }
    }
}

# Create a service level for Ad Service 
resource "newrelic_service_level" "ad-service-level" {
    guid = data.newrelic_entity.ad-entity.id
    name = "Ad Service Level"
    description = "Proportion of successful requests."

    events {
        account_id = var.account_id
        valid_events {
            from = "Span"
            where = "entity.guid='${data.newrelic_entity.ad-entity.id}' AND (span.kind IN ('server', 'consumer') OR kind IN ('server', 'consumer'))"
        }
        bad_events {
            from = "Span"
            where = "entity.guid='${data.newrelic_entity.ad-entity.id}' AND (span.kind IN ('server', 'consumer') OR kind IN ('server', 'consumer')) AND otel.status_code = 'ERROR'"
        }
    }

    objective {
        target = 99.25
        time_window {
            rolling {
                count = 1
                unit = "DAY"
            }
        }
    }
}

# Create a service level for Payment Service 
resource "newrelic_service_level" "paymentservice-service-level" {
    guid = data.newrelic_entity.payment-entity.id
    name = "Payment Service Level"
    description = "Proportion of successful requests."

    events {
        account_id = var.account_id
        valid_events {
            from = "Span"
            where = "entity.guid='${data.newrelic_entity.payment-entity.id}' AND (span.kind IN ('server', 'consumer') OR kind IN ('server', 'consumer'))"
        }
        bad_events {
            from = "Span"
            where = "entity.guid='${data.newrelic_entity.payment-entity.id}' AND (span.kind IN ('server', 'consumer') OR kind IN ('server', 'consumer')) AND otel.status_code = 'ERROR'"
        }
    }

    objective {
        target = 99.25
        time_window {
            rolling {
                count = 1
                unit = "DAY"
            }
        }
    }
}

# Create an alert policy to monitor service health of the OTel demo 
resource "newrelic_alert_policy" "oteldemo-service-health" {
  name = "OpenTelemetry Service Health"
  incident_preference = "PER_CONDITION" 
}

# Add an alert condition for OTel service health monitoring 
resource "newrelic_nrql_alert_condition" "otel-service-health" {
  account_id                     = var.account_id
  policy_id                      = newrelic_alert_policy.oteldemo-service-health.id
  type                           = "static"
  name                           = "otel-service-health"
  description                    = "Service has too many errors"
  enabled                        = true

  nrql {
    query = "FROM Span SELECT filter(count(*), WHERE otel.status_code = 'ERROR') / count(*) as 'Error rate for all errors' WHERE (span.kind LIKE 'server' OR span.kind LIKE 'consumer' OR kind LIKE 'server' OR kind LIKE 'consumer') FACET entity.name"
  }

  critical {
    operator              = "above"
    threshold             = 0.01
    threshold_duration    = 180
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 0.005
    threshold_duration    = 180
    threshold_occurrences = "ALL"
  }
}

# Add an alert condition for service levels 
resource "newrelic_nrql_alert_condition" "apm-service-levels" {
  account_id                     = var.account_id
  policy_id                      = newrelic_alert_policy.oteldemo-service-health.id
  type                           = "static"
  name                           = "apm-service-levels"
  description                    = "Service level objective is not met"
  enabled                        = true

  nrql {
    query = "FROM Metric SELECT sum(newrelic.sli.good) / sum(newrelic.sli.valid) as 'SLI' WHERE sli.guid IN ('${newrelic_service_level.checkout-service-level.sli_guid}') FACET sli.guid"
  }

  critical {
    operator              = "below"
    threshold             = 0.9925
    threshold_duration    = 60
    threshold_occurrences = "ALL"
  }
}


resource "newrelic_one_dashboard_json" "otel_collector_flow_dashboard" {
   json = replace(
  	replace(    # This changes the dashboard name
    	    file("../workshop/dashboards/otel_collector_data_flow.json"),
    	    "by Terraform"
    	    ,"renamed by Terraform"
  	),
	"999999999",  # This is the value in the source file
	"${var.account_id}"   # This is the value it will be changed to
	)
}

resource "newrelic_entity_tags" "otel_collector_flow_dashboard" {
	guid = newrelic_one_dashboard_json.otel_collector_flow_dashboard.guid
	tag {
    	     key    = "terraform"
    	     values = [true]
	}
}

output "otel_collector_flow_dashboard" {
      value = newrelic_one_dashboard_json.otel_collector_flow_dashboard.permalink
}