# icome8

icome version 8, version up from icome7.

## require

* ruby 2.3.1
* jruby 9.1.3.0
* mongodb 3.2.9
* gem mongo 2.3.0

## install

## develop branch

```sh
localhost$ ./mongodb-start.sh
localhost$ ./ucome --debug
localhost$ ./acome --debug
localhost$ ./icome.rb --debug
```

## production

dbs.melt.kyutech.ac.jp で ucome を起動させておき、

```
isc$ make isc
isc$ icome
```

## changelog

* 2017-10-03 1.7.0 情報応用授業スタート、アップデート再開。
* 2016-09-08 1.0.0.
* 2016-09-08 1.0.1, ucome を (cd icome8 && make start) でスタートさせる。
* 2016-09-08 1.0.2, exec
* 2016-09-08 1.0.3, メニューにブロックの状況に応じて赤で囲み

## GitHub

https://github.com/hkim0331/icome8.git

## author

hiroshi.kimura.0331@gmail.com

---
hkimura.
