# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

Assertion.create(id: 1, assertion_type: "http-200")
Assertion.create(id: 2, assertion_type: "ajax-200")
Assertion.create(id: 3, assertion_type: "report")
Assertion.create(id: 4, assertion_type: "step-succeed")
Assertion.create(id: 5, assertion_type: "match-url")

Template.create(name: 'ruby')
Template.create(name: 'java')

ActiveRecord::Base.connection.execute("ALTER TABLE results CHANGE created_at created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP")

