Take benchmark of `/api/:name`. The conf body is as following:

```
<source>
  type forward
  port <%= port %>
</source>
```

| # of requests | concurrency | server  | # of workers | req/sec |
|---------------|-------------|---------|--------------|---------|
|20000          |126          | unicorn | 1            |865.07   |
|20000          |126          | unicorn | 12           |4116.78  |
|20000          |126          | puma    | 1            |634.20|
|20000          |126          | puma    | 12           |3765.66  |

Let's use unicorn
