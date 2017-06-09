# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


Assertion.create(condition: "http 200 status ok", assertion_type: "http 200")
Assertion.create(condition: "ajax 200 status ok", assertion_type: "ajax 200")

ActiveRecord::Base.connection.execute("ALTER TABLE assertions CHANGE created_at created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP")
ActiveRecord::Base.connection.execute("ALTER TABLE assertions CHANGE updated_at updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP")


