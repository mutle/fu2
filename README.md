= About fu2

fu2 is a community-software. It works similar to forums, but also has some differences.

== Features

* Discussion channels
* Private messages
* Invite users

== Requirements

* Redis
* PostgreSQL
* ElasticSearch

== Installation

Set up `config/database.yml` with valid credentials to your local postgres server.

Then run:

```
rake db:create db:migrate db:seed
```

== License

This application is licensed under the MIT-LICENSE, see the file MIT-LICENSE for more information.

== Copyright

Developed by Mutwin Kraus (mutle).
