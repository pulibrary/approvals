# README

This is an application that allows the library to create workflows that allow staff to seek approval for travel and leave. 

[![CircleCI](https://circleci.com/gh/pulibrary/approvals.svg?style=svg)](https://circleci.com/gh/pulibrary/approvals)

## Ruby version

  2.4.4

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

   * create, migrate and seed the database
     ```
     rake db:create 
     rake db:migrate
     rake db:seed
     ```
   * There are additional rake tasks that allow you to create scenarios and requests in the system
     * make_me_a_department_head[netid,number]
        for example the following command will create a department for cac9 to be the head of and have 5 supervisors, each with 5 reports.
       ```
       rake approvals:make_me_a_department_head[cac9,5]
       ```
     * make_me_a_supervisor[netid,number]
       for example the following command will create 7 directs report for cac9 to supervise
       ```
       rake approvals:make_me_a_supervisor[cac9,7]
       ```
     * make_requests_for_everyone
       Make random numbers of request in random states for everyone in the system.
       ```
       rake approvals:make_requests_for_everyone
       ```
    

## Development

   * run foreman
     ```
     bundle exec foreman start
     ```
   * run mail catcher
     run once 
     ```
     gem install mailcatcher
     ```
     run every time
     ```
     mailcatcher
     ```
   
     [you can see the mail that has been sent here]( http://localhost:1080/)
     
## How to run the test suite

### Percy (Visual Regressions)

[![This project is using Percy.io for visual regression testing.](https://percy.io/static/images/percy-badge.svg)](https://percy.io/Princeton-University-Library/approvals)

See: [Documentation](https://docs.percy.io/docs/capybara)

## Deployment instructions


