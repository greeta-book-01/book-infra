 # Resource: Config Map
resource "kubernetes_config_map_v1" "book_mysql_config_map" {
   metadata {
     name = "book-mysql-dbcreation-script"
   }
   
   data = {
    "1.sql" = "${file("${path.module}/mysql-init/1.sql")}"
    "2.sql" = "${file("${path.module}/mysql-init/2.sql")}"
    "3.sql" = "${file("${path.module}/mysql-init/3.sql")}"
    "4.sql" = "${file("${path.module}/mysql-init/4.sql")}"
    "5.sql" = "${file("${path.module}/mysql-init/5.sql")}"
    "6.sql" = "${file("${path.module}/mysql-init/6.sql")}"
   }
} 