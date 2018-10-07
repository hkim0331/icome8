# FIXME

* bug タイムアウト

ucome とつながらない時、早めに報告し、終了したい。

```
ucome: druby://150.69.90.3:4002
start
warning: thread "Ruby-0-Thread-2: ./icome.rb:4" terminated with exception (report_on_exception is true):
DRb::DRbConnError: druby://150.69.90.3:4002 - #<Errno::ECONNREFUSED: Connection refused - connect(2) for "150.69.90.3" port 4002>
            block in open at /usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:785
                     each at org/jruby/RubyArray.java:1801
                     open at /usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:778
               initialize at /usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1288
                     open at /usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1268
  block in method_missing at /usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1181
              with_friend at /usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1200
           method_missing at /usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1180
           block in start at ./icome.rb:204
org.jruby.exceptions.RuntimeError: (DRbConnError) druby://150.69.90.3:4002 - #<Errno::ECONNREFUSED: Connection refused - connect(2) for "150.69.90.3" port 4002>
	at RUBY.block in open(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:785)
	at org.jruby.RubyArray.each(org/jruby/RubyArray.java:1801)
	at RUBY.open(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:778)
	at RUBY.initialize(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1288)
	at RUBY.open(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1268)
	at RUBY.block in method_missing(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1181)
	at RUBY.with_friend(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1200)
	at RUBY.method_missing(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1180)
	at $_dot_.icome.block in start(./icome.rb:204)
Exception in thread "AWT-EventQueue-0" org.jruby.exceptions.RuntimeError: (DRbConnError) druby://150.69.90.3:4002 - #<Errno::ECONNREFUSED: Connection refused - connect(2) for "150.69.90.3" port 4002>
	at RUBY.block in open(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:785)
	at org.jruby.RubyArray.each(org/jruby/RubyArray.java:1801)
	at RUBY.open(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:778)
	at RUBY.initialize(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1288)
	at RUBY.open(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1268)
	at RUBY.block in method_missing(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1181)
	at RUBY.with_friend(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1200)
	at RUBY.method_missing(/usr/local/Cellar/jruby/9.2.0.0/libexec/lib/ruby/stdlib/drb/drb.rb:1180)
	at $_dot_.icome.group_ex(./icome.rb:115)
	at RUBY.block in robocar_menu(/Users/hkim/workspace/icome8/icome-ui.rb:160)
```

* [bugfix] 2017-10-11 xwatch のオプションは --check ではなく --conf
* [bugfix] 2017-10-11 icome.rb:@log.debug ではなく、@logger.debug
* [change] 2017-10-10 acome 使わず、環境変数 UCOME を .bash_profile で定義、
  acome.rb でつなぐ。
* SID-UID-JNAME.txt ファイルがないとき？
* [fixed] thr ではなく thu。/edu/lib/icome を使うのは面倒か？
* 2016-09-29 教室チェックが機能しない。c-2g? c-2b? とその周りのコード。
* upload 時、ファイルが見つからない時、素朴に「ファイルがない」を表示するべきか？
* dialog の表示位置。
* BUG? druby://localhost:9001 で通信できないわけは？
  druby://127.0.0.1:9001 では行けるのに。
* BUG? ccl 使用時、monbodb://localhost:27017 でエラーになるか？
  monbodb://127.0.0.1:27017 ではどうか？ 2016-09-26
* jname, myid, subj(授業科目）をドキュメントに入れるか？
* ucome ではなく、mongodb にコマンドを入れるようにしたら?
    + ロジックが増える。
    + 時間ごとにクリアしないで良い。全てのクラスで同じ課題が出せる。
    - 課題を出すタイミングがめんどくさくなる。
      upload がファイルが見つかるまでブロックとかできないっしょ。
    - 時間ごとに新しいコマンドを用意する必要がある。
* BUG: acome:reset したら icome が回り続ける。
  回避するには reset の効果を確認してから
  disable reset の番号
  だけどな。

## OLD DOCS

### 2015-05-13

install 時に debug で始まる行にコメント。（いらんか、速度が大事なアプリじゃない）。

### 2015-05-11, 0.10

* admin から ucome にバージョンと uri を聞く（聞けないか。つながらんのだから）。

* mongodb: セーフモードを導入するか？

* find_uhours
  ローカルファイルじゃなく、DBに聞きに行ってもいいかも。

* icome-admin
  * push
  * 今日のサマリ
  * 受講生ごとサマリ

### log

最初の時間に間に合ってないので、特別なコードを書く必要がある。
次の時間、学生が全員来るとは限らない。

## DONE

* サイズがでかすぎるファイルはアップロードしない。
* ucome は自分のアドレスをつかえばいいじゃないか？
* ucome に --uri オプション
* 提出物で表示されるファイル名がソートされていない。
* `提出物`のことばはおかしい。意味を表していない。ふさわしくない。
  奪取物にしよう。
* 記録が無反応なのはいいか？
* 提出物が無反応なのはいいか？
* 新規登録と時間外出席を区別する。
* ucome は root で動かしたらまずいだろう。
* upload/download は admin.rb が起動している PC とやりとりさせるのがいいか？
  ucome とやりとりも可能だが、データを用意するのがめんどくさくなる。
* version を書き込むとそこでマージが失敗するようになった。いつから？
* pull
* ucome にはキャッシュさせない。
* キャッシュするなら icome 側。
* キャッシュしない icome を作る。どうせ、ダイアログでブロックするさ。
* インストールスクリプト
* singleton チェックは icome.rb のラッパー、つまり、icome.sh で実施。
* icome.rb を終了させない。=> nohup で。
* watch-ss => 別フォルダ、別プロジェクトで。
