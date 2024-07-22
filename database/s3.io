//В s3 будем хранить все изображения

// Replication: не работал с s3, но вроде как репликация поддерживается - хотелось бы иметь репликацию по разным ДЦ для отказоустойчивости
// - master-slave (sync)
// - replication factor 3
//
// Sharding:
// - не будет, т.к преобладают операции чтения

Table bucket {
  url varchar [primary key]
  img image
}