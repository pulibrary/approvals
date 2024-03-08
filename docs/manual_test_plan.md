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

### Test delegation workflow
* Follow the steps in [Testing User accounts](https://github.com/pulibrary/approvals?tab=readme-ov-file#database-creation) and run this rake task: `bundle exec rake approvals:make_delegate[netid_delegate,netid]` to allow the user with netid_delegate to review and make requests on behalf of netid. Set netid_delegate as your netid.
* Run the rake task: 'bundle exec rake approvals:make_me_a_supervisor\[netid,7\]' set netid to be the same with the one from the previous step. With this rake task you make netid a supervisor with 7 direct reports.

|Step|Action|Expected result|
|---|---|---|
|1|Without an active session, go to [the application](https://approvals-staging.princeton.edu/)|The application has a button to Login with NetID|
|2|Press "LOGIN with NetID" button and login with CAS credentials|You are taken to the My Requests page|
|3|Click on your netid top-right menu bar. Select "My Delegates" option|You see a message: 'Please use this feature with care as it allows other people whom you designate to act on your behalf.' and a form to add a Delegate|
|4|In the input box type the desired delegate Person/netid and press 'Add Delegate' button|The form shows the name of the Delegator and a red x button to remove them|
|5|Pres on the delegator's name|The person's name should be removed from the form|
|6|Click on your netid top-right menu bar. Select "My Delegations" option|You see a message: 'Please use this feature with care as it allows you to act on someone's behalf.' |You should see the name of the netid you added in the rake task at the beginning of the workflow|
|7|Click on the delegator's name. | The page should direct you to see the Delegator's requests|
|8|Click on one of the delegator's 'Pending' requests.|You should be able to see the request with active 'Edit', 'Cancel the Request' and 'Comment' buttons|
|9|Press 'Comment' button|The form should display a notes area.|
|10|Type your comment and press 'Comment' button.|The form should display your comment as the delegator's comment.|
|11|Press 'Edit' button|The form should display in edit mode.|
|12|Select 'Absence Type' and choose a different option|The new option should reflect in the select|
|13|Select a different 'Date range'|The new date range should reflect in the input box|
|14|Type a new value in 'Total hours requested'|The new value should reflect in the input box|
|15|Type a comment in the 'Comments' area.|The comment should display in the Comments area|
|16|Press 'Submit Request'|The Page should render the updated Request with the updated values|
|17|Click the link on top of the screen 'Stop acting on <delegator's name> behalf.'|The application should direct you to your 'My Requests' page. The page should list only your requests and display 'You are now acting on your behalf' message|
