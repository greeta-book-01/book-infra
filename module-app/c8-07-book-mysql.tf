# Resource: Order Postgres Kubernetes Deployment
resource "kubernetes_deployment_v1" "book_mysql_deployment" {
  metadata {
    name = "book-mysql"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "book-mysql"
      }          
    }
    strategy {
      type = "Recreate"
    }  
    template {
      metadata {
        labels = {
          app = "book-mysql"
        }
      }
      spec {
        volume {
          name = "book-mysql-dbcreation-script"
          config_map {
            name = kubernetes_config_map_v1.book_mysql_config_map.metadata.0.name 
          }
        }

        container {
          name = "book-mysql"
          image = "mysql:8.1.0"
          port {
            container_port = 3306
            name = "mysql"
          }
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value = "test1234!"
          }

          env {
            name = "MYSQL_DATABASE"
            value = "reactlibrarydatabase"
          }          

          readiness_probe {
            exec {
              command = ["mysqladmin", "ping", "-u", "root", "-p$${MYSQL_ROOT_PASSWORD}"]
            }
          }

          volume_mount {
            name = "book-mysql-dbcreation-script"
            mount_path = "/docker-entrypoint-initdb.d"
          }          
        }
      }
    }      
  }
  
}

# Resource: Keyloak Postgres Load Balancer Service
resource "kubernetes_service_v1" "book_mysql_service" {
  metadata {
    name = "book-mysql"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.book_mysql_deployment.spec.0.selector.0.match_labels.app 
    }
    port {
      port        = 3306 # Service Port
      target_port = 3306 # Container Port  # Ignored when we use cluster_ip = "None"
    }
    type = "ClusterIP"
    # load_balancer_ip = "" # This means we are going to use Pod IP   
  }
}

# Resource: order Postgres Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler_v1" "book_mysql_hpa" {
  metadata {
    name = "book-mysql-hpa"
  }
  spec {
    max_replicas = 2
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment_v1.book_mysql_deployment.metadata[0].name 
    }
    target_cpu_utilization_percentage = 60
  }
}