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

#### Updating an absence request

|Step|Action|Expected result|
|---|---|---|
|1|Without an active session, go to [the application](https://approvals-staging.princeton.edu/)|The application has a button to Login with NetID|
|2|Press "LOGIN with NetID" button and login with CAS credentials|You are taken to the My Requests page|
|3|Find an already created absence request and click on the card|You will be taken to the details page for the request|
|4|Press the Edit button|The details page will become an editable form|
|5|Change some of the values and add a comment|The updated values will be reflected in the form|
|6|Press Submit Request|You will return to the details page with the changed values and a new comment|

#### Approving an absence request

|Step|Action|Expected result|
|---|---|---|
|1|With the application set to act as a delegate for your approver as detailed above|You should see a banner at the top of the page saying you are acting as a delegate for the selected person|
|2|Click on the "Requests to Review" link in the header|You should be taken to the "Requests Awaiting My Approval" page with the request you created|
|3|Click on the title of the absence request you just created|You should navigate to a page with the details of the request|
|4|Enter a note into the Notes field|The form should contain the entered note|
|5|Press the Approve button|You should see "Absence Request was successfully updated"|

#### Denying an absence request

|Step|Action|Expected result|
|---|---|---|
|1|With the application set to act as a delegate for your approver as detailed above|You should see a banner at the top of the page saying you are acting as a delegate for the selected person|
|2|Click on the "Requests to Review" link in the header|You should be taken to the "Requests Awaiting My Approval" page with the request you created|
|3|Click on the title of the absence request you just created|You should navigate to a page with the details of the request|
|4|Enter a note into the Notes field|The form should contain the entered note|
|5|Press the Deny button|You should see "Absence Request was successfully updated"|

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
|12|Select a different 'Date range'|The new date range should reflect in the input box|
|13|Type a new value in 'Total hours requested'|The new value should reflect in the input box|
|14|Press 'Submit Request'|The Page should render the updated Request with the updated values|
|15|Click the link on top of the screen 'Stop acting on <delegator's name> behalf.'|The application should direct you to your 'My Requests' page. The page should list only your requests and display 'You are now acting on your behalf' message|

### Travel request workflow

Note: these steps must be completed on a non-production environment, to prevent corrupting production data.

#### Creating a travel request

|Step|Action|Expected result|
|---|---|---|
|1|Without an active session, go to [the application](https://approvals-staging.princeton.edu/)|The application has a button to Login with NetID|
|2|Press "LOGIN with NetID" button and login with CAS credentials|You are taken to the My Requests page|
|3|Press "New travel request" button|You see a form with even info and expenses|
|4|In the Event Name field, type "Test Event 360"|Below the Event Name field you will see a message saying there appears to be a date in the field|
|5|In the Location field, type "Princeton, NJ"|The form will show the entered value|
|6|Select an Event Format|The form shows that you have selected the appropriate Event Format|
|7|Select a Participation type|The form shows that you have selected the appropriate Participation type|
|8|In the Purpose field, type "Training"|The form will show the appropriate Purpose|
|9|In the Event Dates field, type "12/14/2026 - 12/18/2026"|The form will show the selected date range|
|10|In the Travel Dates field, type "12/13/2026 - 12/19/2026"|The form will show the selected date range|
|11|In the Notes to Approvers field, Type "This is a note"|The form will show the entered note|
|12|In the Anticipated Expenses section, enter some expenses|The form will show a total for each line and an overall total|
|13|Press the Submit Request button|A modal will appear indicating a possible date in the Event Name|
|14|Press the Continue button|You see "Travel request was successfully created."|

#### Editing a travel request

|Step|Action|Expected result|
|---|---|---|
|1|Create a travel request as detailed above|You see "Travel request was successfully created."|
|2|Press the Edit button at the bottom of the page|You should be taken to a page where the fields are editable|
|3|Make a few changes|The fields should reflect the new values|
|4|Add a new note to the Approvers|The fom will show the entered note|
|5|Add or remove some expenses|The total should update to reflect changes|
|6|Press the Submit Request button|If the event name has a number a modal will appear indicating that "Possible Date Detected' in the Event Name|
|7|Press the Continue button|You see "Travel request was successfully updated."|

#### Setting up a delegation for testing
|Step|Action|Expected result|
|---|---|---|
|1|Create a travel request as detailed above|You see "Travel request was successfully created."|
|2|Follow [the instructions](https://github.com/pulibrary/approvals/tree/main?tab=readme-ov-file#testing-user-accounts) to make yourself a delegate for your approver|The rake task should be successful
|3|Click on you netid at the top right to open the menu and select "My Delegations"|You should see your approver in the list of names|
|4|Click on your approver's name to act as a delegate for them|You should see a banner at the top of the page saying you are acting on behalf of the selected person|


#### Approving a travel request

|Step|Action|Expected result|
|---|---|---|
|1|With the application set to act as a delegate for your approver as detailed above|You should see a banner at the top of the page saying you are acting as a delegate for the selected person|
|2|Click on the "Requests to Review" link in the header|You should be taken to the "Requests Awaiting My Approval" page with the request you created|
|3|Click on the title of the request you just created|You should navigate to a page with the details of the request|
|4|Enter a note into the Notes field|The form should contain the entered note|
|5|Press the Approve button|You should see "Travel Request was successfully updated"|

#### Denying a travel request

|Step|Action|Expected result|
|---|---|---|
|1|With the application set to act as a delegate for your approver as detailed above|You should see a banner at the top of the page saying you are acting as a delegate for the selected person|
|2|Click on the "Requests to Review" link in the header|You should be taken to the "Requests Awaiting My Approval" page with the request you created|
|3|Click on the title of the request you just created|You should navigate to a page with the details of the request|
|4|Enter a note into the Notes field|The form should contain the entered note|
|5|Press the Deny button|You should see "Travel Request was successfully denied"|
