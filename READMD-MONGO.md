# /etc/mongodb.conf

> bind_ip = 127.0.0.1

ufw で許可していても、mongodb 側で拒否している。
ゆるめて他からのコネクションを許そう（ruby 他のアプリから接続する）

* server db.melt 2.6.10
* client imac3   4.0.2

だめ。大学外からアクセスできない。

