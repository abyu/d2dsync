Installing and running
########################
1. Install latest ruby
2. Checkout the code, and run `bundle install`
3. Then run `rails sever`, application should be available in http://localhost:3000
4. Make sure to update the client_secrets.template.json with cliet id and secrets and rename it to client_secrets.json
5. rake db:migrate to create db

Bundle install may fail to install sqllite3, if you are on a linux machine run `yum install sqlite-devel` or `apt-get install libsqlite3-dev`
