# icome7

icome version 8.

rewrote icome7

## require

```
$ gem install mongo
```

## develop

prep mongodb:

```sh
localhost$ ./mongo-mongo.sh
```

launch ucome:

```sh
localhost$ ./ucome.rb --port port
```

then icome.

```sh
localhost$  ./icome.rb --ucome druby://localhost:port
```

--debug option is also available.

## production

### orange

```sh
# service mongodb start
# service ucome start
```

ucome runs under hkim privilege.

### isc

```sh
isc$ /edu/bin/icome
```

### isc admin

```sh
hkimura$ ~/icome7/admin.rb
```

* display message
* upload dir/file ...
  upload local:~/dir/file as remote:/srv/icome7/upload/uid/file
  `dir/` is omitted.


## author

hiroshi.kimura.0331@gmail.com

