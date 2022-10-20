This task creates a CSV of approved travel requests that overlap with the requested reporting period. 

To run: 
```bash
bundle exec rake approvals:reports:approved_trips\["11/01/2022","12/31/2022"\]
```

This defaults to saving the file to `./tmp/approved_request_report.csv`

You can also run the task with an optional file path: 
```bash
bundle exec rake approvals:reports:approved_trips\["11/01/2022","12/31/2022","/tmp/my_report_today.csv"\]
```
