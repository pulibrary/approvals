# README

This is an application that allows the library to create workflows that allow staff to seek approval for travel and leave. 

[![CircleCI](https://circleci.com/gh/pulibrary/approvals.svg?style=svg)](https://circleci.com/gh/pulibrary/approvals)

## Ruby version

  3.0.0

## System dependencies

   * Postgres
   * Node
   * Yarn
   * Rails
   * Bundler

## Configuration

   * Bundle & Yarn install
     ```
     bundle install
     yarn install
     ```
   
## Database creation

   * Run `bundle exec rake servers:start` to start a local postgres server, create, and migrate.
   * seed the database
     ```
     bundle exec rake db:seed # you must be on the VPN for this step
     ```
   * `bundle exec rake db:seed` only creates accounts for users listed in the [Active Library Staff-Scheduled-en CSV](https://github.com/pulibrary/approvals/blob/main/Active%20Library%20Staff%20-%20Scheduled-en.csv) file.  If you are not yet listed in the file, you will have to add a row with your NetID in order to log
   in to the system later.
   * There are additional rake tasks that allow you to create scenarios and requests in the system
     * make_me_a_department_head\[netid,number\]
        for example the following command will create a department for cac9 to be the head of and have 5 supervisors, each with 5 reports.
       ```
       bundle exec rake approvals:make_me_a_department_head\[cac9,5\]
       ```
     * make_me_a_supervisor\[netid,number\]
       for example the following command will create 7 directs report for cac9 to supervise
       ```
       bundle exec rake approvals:make_me_a_supervisor\[cac9,7\]
       ```
     * make_requests_for_everyone
       Make random numbers of request in random states for everyone in the system.
       ```
       bundle exec rake approvals:make_requests_for_everyone
       ```
    
## Testing User Accounts
  * Users can have test requests created for them via rake. The following command creates 
    ```
    bundle exec rake approvals:make_requests_for_user[netid]
    ```
  * Other users can subsume other user's roles by manipulating the system's delegation features. The following task allows the user with netid_delegate to review and make requests on behalf of netid. 
    ```
    bundle exec rake approvals:make_delegate[netid_delegate,netid]
    ```
  * If the newly delegated individual then visits the "delegates/to_assume" route in the application they will be able select the user attached to 'netid' and see the requests they've made and make them on their behalf. 

## Development

   * run the first time
     ```
     gem install foreman mailcatcher
     ```
   * run every time
     ```
     mailcatcher && foreman start
     ```
   
     [you can see the mail that has been sent here]( http://localhost:1080/)
     
## Staging Mail Catcher
  To See mail that has been sent on the staging server you must ssh tunnel into the server
  ```
  ssh -L 1082:localhost:1080 pulsys@lib-approvals-staging1
  ```
  Once the tunnel is open [you can see the mail that has been sent on staging here]( http://localhost:1082/)
     
## How to run the test suite

`bundle exec rake spec` will run the tests.

`yarn test` will run the javascript tests, and `yarn lint` will run the javascript
linter.

If you want to see a test in Chrome, run it with the `RUN_IN_BROWSER=true` environment variable, for example:

    RUN_IN_BROWSER=true bundle exec rspec spec/features/new_travel_request_spec.rb

## Deployment instructions


