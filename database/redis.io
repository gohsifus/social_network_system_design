// Хочется что-то кешировать, например посты, т.к к популярному посту может быть оч много обращений

table postsCache {
  postID int [primary key]
  postData json
  ttl time
}