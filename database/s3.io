//В s3 будем хранить все изображения

Table bucket {
  url varchar [primary key]
  img image
}