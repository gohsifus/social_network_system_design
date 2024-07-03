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