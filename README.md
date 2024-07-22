# System Design социальной сети для курса по System Design
<hr>
<a href="https://balun.courses/courses/system_design">Ссылка на курс</a>
<hr>

## Формализованные требования

### Функциональные требования:
* Должна быть лента с публикациями 
* Пост в ленте может состоять из текста, картинок и геометки
* Под постами должна быть возможность поставить оценку (лайк/дизлайк) 
* Под постами должна быть возможность написать комментарий
* Возможность подписаться на пользователя и следить за его публикациями
* Должна быть страница пользователя с его публикациями и основной информацией
* Страница с топами самых популярных мест (по странам/ по городам)
* Общение с другими пользователями в личных сообщениях
* Аутентификация пользователя

### Нефункциональные требования
* Максимальный размер картинки - 500кб
* Максимальное количество картинок в посте - 5
* Максимальное количество символов в посте - 1000
* Максимальное количество символов в комментариях к посту - 200
* В комментариях только текст
* Определенные форматы геометок (пользователь может указать геометку, только в том формате что мы определим)
* Максимальное количество комментариев от одного аккаунта для поста - 30
* DAU - 10 000 000
* Несколько клиентов (мобильные устройства, web)
* Данные храним всегда
* Availability - %99.95
* Максимальное количество подписчиков у одного пользователя - 5 000 000 (при достижении лимита увеличивать на 20%)
* Среднее количество запросов на пользователя - 12 на запись 200 на чтение в сутки
* Аудитория - СНГ
* Сезонность - в сезон летних отпусков (лето) и в сезон новогодних каникул (январь, февраль) - среднее количество запросов на запись будет расти с 12 до 15 в сутки (будет больше публикаций, сообщений, комментариев). 
* В личных сообщениях можно отправлять только текст
* Максимальное количество символов в личном сообщении - 250
* Через какое максимальное время после создания поста он появляется в лентах? - 30 секунд
* Максимальное время доставки сообщения пользователю - 5 сек

<hr>

## Расчет нагрузки

### RPS

``` 
DAU = 10 000 000

RPS = DAU * avgRequestsPerDay / 86400
```

* Посты
```
avgRequestsPerDay = 160 + 1 = 151 (100 постов посмотрел, 50 подгрузил ленту, 1 создал)

RPS = 10 000 000 * 161 / 86400 = 18 634
```

* Комментарии
```
avgRequestsPerDay = 20 + 4 = 24 (20 раз подгрузил комментарии, 4 создал)

RPS = 10 000 000 * 24 / 86400 = 2 777
```

* Сообщения
```
avgRequestsPerDay = 10 + 5 = 15 (10 раз подгрузил сообщения, 5 отправил)

RPS = 10 000 000 * 15 / 86400 = 1 736 
```

* Профили пользователей
```
avgRequestsPerDay = 10 + 2 = 11 (10 профилей открыл, 2 подписки/отписки/создание новых юзеров)

RPS = 10 000 000 * 12 / 86400 = 1388
```

### Traffic

```
Traffic = rps * avgRequestSize
```

* Посты

Рассчитаем средний размер запроса:
```
Пусть:
Среднее количество картинок в посте - 1 (100кб)
Среднее количество символов в посте - 200 (400б)

avgRequestSize = 100400 б
```
Тогда
```
Traffic = 18634 * 100400 = 1.87 gb
```

* Комментарии

Рассчитаем средний размер запроса:
```
Пусть
Среднее количество символов в комментарии - 50
Количество комментариев подгружаемых за один запрос - 50

avgRequestSize = 50 * 50 * 2 = 5 kb
```
Тогда
```
Traffic = 2777 * 5 = 13 885 kb
```

* Сообщение

Рассчитаем средний размер запроса:
```
Пусть
Среднее количество символов в сообщении - 100
Количество сообщений подгружаемых за один запрос - 50

avgRequestSize = 100 * 50 * 2 = 10 kb
```
Тогда
```
Traffic = 1736 * 10 = 17 360 kb
```

* Профили пользователей

Рассчитаем средний размер запроса:
```
Пусть
В профиле аватарка в среднем - 100kb
nickname и количество подписчиков - 30 b в среднем 

avgRequestSize = 100 kb
```
Тогда
```
Traffic = 1388 * 10 = 13 880 kb
```

## Одновременные соединения
```
Connections = dau * 0.1

Connections = 10 000 000 * 0.1 = 1 000 000
```

<hr>

## Расчет дисков
Формулы:
```
Disks_for_capacity = capacity / disk_capacity
Disks_for_throughput = traffic_per_second / disk_throughput
Disks_for_iops = iops / disk_iops
Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops))
```

Capacity на 1 год: 
```
postsWriteTrafficOneUserPerDay    = 1 * 100400b = 100 400 b
commentsWriteTrafficOneUserPerDay = 4 * 100b = 400 b
messagesWriteTrafficOneUserPerDay = 5 * 200b = 1000 b
usersWriteTrafficOneUserPerDay    = 0.1 * 100000b = 10 000 b (write по сути только на создание имеет размер)

fullPostsWriteTrafficPerDay = 100 400 b * 10 000 000 = 1TB
fullcommentsWriteTrafficPerDay = 400 b * 10 000 000 = 4 GB
fullMessagesWriteTrafficPerDay = 1000 b * 10 000 000 = 10 GB
fullUsersWriteTrafficPerDay = 10 000 b * 10 000 000 = 100 GB

capacityRoughPosts = fullPostsWriteTrafficPerDay * 365 = 1 TB * 365 = 365 TB
capacityRoughComments = fullCommentsWriteTrafficPerDay * 365 = 4 GB * 365 =  1.5 TB
capacityRoughMessages = fullMessagesWriteTrafficPerDay * 365 = 10 GB * 365 = 3.7 TB
capacityRoughUsers = fullUsersWriteTrafficPerDay * 365 = 100 GB * 365 = 37 TB


Возьмем 20% запас
capacityPosts = capacityRoughPosts * 1.2 = 438 TB
capacityComments = capacityRoughComments * 1.2 = ~2 TB
capacityPostsMessages = capacityRoughMessages * 1.2 = ~5 TB
capacityPostsUsers = capacityRoughUsers * 1.2 = 45 TB

capacity = 490 TB
```

Количество необходимых дисков:
#### Posts
```
capacity = 438 TB
throughput = 13 MB/s
iops = 18 634

Disks_for_capacity = 438 / disk_capacity = 14 HDD or 5 SSD or 15 SSD(nVME)
Disks_for_throughput = 1870 MB / disk_throughput = 19 HDD or 4 SSD or 1 SSD(nVME) 
Disks_for_iops = 18 634 / disk_iops = 187 HDD or 19 SSD or 2 SSD(nVME)
Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = 5 SSD (по 100TB)
```

#### Comments
```
capacity = 1.5 TB
throughput = 14 MB/s
iops = 2 777

Disks_for_capacity = 1.5 / disk_capacity = 1 HDD or 1 SSD or 1 SSD(nVME)
Disks_for_throughput =  14 MB / disk_throughput = 1 HDD or 1 SSD or 1 SSD(nVME) 
Disks_for_iops = 2 777 / disk_iops = 28 HDD or 3 SSD or 1 SSD(nVME)
Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = 3 SSD (по 2TB)
```

#### Messages
```
capacity = 3.7 TB
throughput = 18 MB/s
iops = 1 736

Disks_for_capacity = 3.7 / disk_capacity = 1 HDD or 1 SSD or 1 SSD(nVME)
Disks_for_throughput =  18 MB / disk_throughput = 1 HDD or 1 SSD or 1 SSD(nVME) 
Disks_for_iops = 1 736 / disk_iops = 18 HDD or 2 SSD or 1 SSD(nVME)
Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = 2 SSD (по 5TB)
```

#### Users
```
capacity = 45 TB
throughput = 18 MB/s
iops = 1 388

Disks_for_capacity = 45 / disk_capacity = 2 HDD or 1 SSD or 2 SSD(nVME)
Disks_for_throughput =  18 MB / disk_throughput = 1 HDD or 1 SSD or 1 SSD(nVME) 
Disks_for_iops = 1 388 / disk_iops = 14 HDD or 2 SSD or 1 SSD(nVME)
Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = 2 SSD (по 30TB)
```

# Расчет количества хостов
Формула
```
Hosts = disks / disks_per_host
Hosts_with_replication = hosts * replication_factor
```

Рассчитаем хосты для баз (у разных бд может быть разная репликация)
```
Users = 2 disks
Comments = 3 disks
Posts = 5 disks

Messages = 2 Disks

Для бд мессенджера:
Hosts = 2/2 = 1
Hosts_with_replication = 1 * 3 = 3

Для изображений (s3):
Hosts = 4/2 = 2
Hosts_with_replication = 2 * 3 = 6

Для постов и связанных сущностей (юзеры комменты и т.д):
Hosts = 6 / 2 = 3
Hosts_with_replication = 3 * 4 = 12

В итоге:
Hosts = 6
Hosts_with_replication = 21
```




