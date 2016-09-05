# icome8

icome version 8.
rewrote icome7.

## README

リセットが難しい。どういう手段で実施するか?

## require

I use,

* ruby 2.3.1
* jruby 9.1.3.0
* mongodb 3.2.9
* gem mongo 2.3.0

## develop

```sh
localhost$ ./mongodb-start.sh
localhost$ ./debug-ucome
localhost$ ./debug-icome
localhost$ ./debug-acome
```

* debug- の名前は一箇所にデバッグ関連プログラムが集まって、見やすい。
* app-debug の名前は mongo-start みたいに、「アプリ 動詞」の順で統一できる。

どっちがいいか? あんまりどうでもいいや。

## production

## author

hiroshi.kimura.0331@gmail.com

---
hkimura.

