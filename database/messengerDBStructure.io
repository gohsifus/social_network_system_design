// Replication:
// - master-slave (sync)
// - replication factor 3
// - репликация по разным ДЦ для отказоустойчивости
//
// Sharding:
// - Будем шардировать по chat_id.
// - Тип: будем использовать directory-based шардинг и раскидывать данные в зависимости от загруженности шарда, так как чаты могут отличаться активностью и при key-based шардинге например данные могут распределятся неравномерно.

Table chats {
  id int [primary key]
  left_user_id int
  right_user_id int
}

Table messages {
  id int [primary key]
  chat_id int
  message text
  author int
  created_at timestamp
  viewed bool
}

Ref: chats.id < messages.chat_id