Approvals has good coverage by automated tests, but there may be some scenarios in
which manual tests may also be necessary.  Below are the steps to test important
workflows in this application manually.

### Absence request workflow

Note: these steps must be completed on a non-production environment, since absence
requests are not turned on in production.

#### Creating an absence request

|Step|Action|Expected result|
|---|---|---|
|1|Without an active session, go to [the application](https://approvals-staging.princeton.edu/)|The application has a button to Login with NetID|
|2|Press "LOGIN with NetID" button and login with CAS credentials|You are taken to the My Requests page|
|3|Press "New Absence Request" button|You see a form and various leave balances|
|4|Select an absence type|The form shows that you have selected the appropriate absence type|
|5|In the date range field, type `12/15/2026 - 1/13/2027`|The form shows the date range that you entered, and the 123.25 hours.|
|6|In the date range field, use the date picker to enter a different date range|The form shows the new date range and the correct number of hours.|
|7|Press submit request|You see "Absence request was successfully created."|
