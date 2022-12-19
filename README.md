# QueuesFluentDriverMultipleExecution

Reprodution of https://github.com/m-barthelemy/vapor-queues-fluent-driver/issues/27

# Usage

1. configure connection to database
2. simply run

```
$ swift run
...
2022-12-19T19:08:24+0900 info main : job_id=940F558A-EC00-47B9-8935-45D884281708 p_id=51675C99-B581-4555-9072-A376D1E95770 [App] EchoJob!
2022-12-19T19:08:24+0900 info main : job_id=940F558A-EC00-47B9-8935-45D884281708 p_id=51675C99-B581-4555-9072-A376D1E95770 [App] EchoJob!
p_id=51675C99-B581-4555-9072-A376D1E95770 is multiple executed!
```
