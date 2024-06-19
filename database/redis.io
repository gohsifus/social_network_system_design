// Хочется что-то кешировать, например посты, т.к к популярному посту может быть оч много обращений

table cache {
  url varchar [unique]
  response json
  ttl time
}