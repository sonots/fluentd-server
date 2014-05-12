The conf body as followings, would be too small to evaluate:

```
<source>
  type forward
  port <%= port %>
</source>
```

| # of requests | concurrency | unicorn worker | req/sec |
|---------------|-------------|----------------|---------|
|20000          |126          |1               |865.07   |
|20000          |126          |12              |4116.78  |

