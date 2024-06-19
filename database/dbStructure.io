// Replication:
// - master-slave (sync)
// - replication factor 3
//
// Sharding:
// - не будет, т.к преобладают операции чтения

Table users {
  id integer [primary key]
  username varchar
  avatar int [ref: - images.id]
  email varchar
}

Table follows {
  following_user_id integer
  followed_user_id integer
  created_at timestamp
}

Table posts {
  id integer [primary key]
  title varchar
  body text [note: 'Content of the post']
  user_id integer
  created_at timestamp
  geo int [ref: - geopoints.id]
}

Table posts_images {
  id integer [primary key]
  post_id int [ref: > posts.id]
  image_id int [ref: > images.id]
}

Table images {
  id integer [primary key]
  url varchar
  created_at timestamp
}

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
}

Table comments {
  id int [primary key]
  post_id int
  comment text
  author int
  created_at timestamp
}

Table geopoints {
  id int [primary key]
  country_id int [ref: - countries.id]
  city_id int [ref: - cities.id]
  coords geom
}

Table cities {
  id int [primary key]
  title varchar
}

Table countries {
  id int [primary key]
  title varchar
}

Table reactions {
  id int [primary key]
  value bool
  post_id int [ref: - posts.id]
  user_id int [ref: - users.id]
}

Ref: posts.user_id > users.id // many-to-one

Ref: users.id < follows.following_user_id

Ref: users.id < follows.followed_user_id

Ref: chats.id < messages.chat_id

Ref: messages.author > users.id

Ref: comments.post_id > posts.id
