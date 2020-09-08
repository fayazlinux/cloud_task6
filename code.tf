provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_db_instance" "fayaz_rds" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "kk"
  password             = "noc12345"
  parameter_group_name = "default.mysql5.7"
  port                 = "3306"
  publicly_accessible  = true
  final_snapshot_identifier = true
  skip_final_snapshot       = true


}


resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "scalable-wordpress"
    labels = {
      App = "ScalableWordpress"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "ScalableWordpress"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableWordpress"
        }
      }
      spec {
        container {
          image = "wordpress"
          name  = "example"

          port {
            container_port = 80
          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress" {
  metadata {
    name = "wordpress"
  }
  spec {
    selector = {
      App = kubernetes_deployment.wordpress.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}
