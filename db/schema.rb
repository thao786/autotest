# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170713000338) do

  create_table "assertions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "webpage"
    t.boolean  "active"
    t.string   "condition"
    t.string   "assertion_type"
    t.string   "label"
    t.integer  "test_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["test_id"], name: "index_assertions_on_test_id", using: :btree
  end

  create_table "drafts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "stamp"
    t.string   "webpage"
    t.string   "apk"
    t.string   "activity"
    t.string   "action_type"
    t.string   "session_id"
    t.string   "typed"
    t.integer  "scrollTop"
    t.integer  "scrollLeft"
    t.integer  "x"
    t.integer  "y"
    t.string   "selector"
    t.integer  "screenwidth"
    t.integer  "screenheight"
    t.string   "tabId"
    t.string   "windowId"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "extracts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.integer  "step_id"
    t.string   "source_type", default: "webpage"
    t.string   "command"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["step_id"], name: "index_extracts_on_step_id", using: :btree
  end

  create_table "plans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email"
    t.integer  "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prep_tests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order"
    t.integer  "test_id"
    t.integer  "step_id"
    t.integer  "suite_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["step_id"], name: "index_prep_tests_on_step_id", using: :btree
    t.index ["suite_id"], name: "index_prep_tests_on_suite_id", using: :btree
    t.index ["test_id"], name: "index_prep_tests_on_test_id", using: :btree
  end

  create_table "results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "test_id"
    t.integer  "assertion_id"
    t.integer  "step_id"
    t.string   "runId"
    t.text     "error",        limit: 4294967295
    t.string   "webpage"
    t.datetime "created_at",                      default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",                      default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["assertion_id"], name: "index_results_on_assertion_id", using: :btree
    t.index ["step_id"], name: "index_results_on_step_id", using: :btree
    t.index ["test_id"], name: "index_results_on_test_id", using: :btree
  end

  create_table "steps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "test_id"
    t.datetime "time"
    t.boolean  "active"
    t.string   "device_type"
    t.string   "typed"
    t.integer  "scrollTop"
    t.integer  "scrollLeft"
    t.string   "action_type"
    t.string   "selector"
    t.integer  "wait"
    t.string   "webpage"
    t.integer  "order"
    t.text     "config",       limit: 65535
    t.integer  "screenwidth"
    t.integer  "screenheight"
    t.string   "tabId"
    t.string   "windowId"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["test_id"], name: "index_steps_on_test_id", using: :btree
  end

  create_table "suites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description", limit: 65535
    t.string   "title",                     null: false
    t.integer  "user_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["user_id"], name: "index_suites_on_user_id", using: :btree
  end

  create_table "test_params", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "val"
    t.string   "label"
    t.integer  "test_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_id"], name: "index_test_params_on_test_id", using: :btree
  end

  create_table "tests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "suite_id"
    t.string   "title",                                           null: false
    t.string   "name"
    t.string   "session_id"
    t.datetime "session_expired_at"
    t.text     "description",        limit: 65535
    t.boolean  "active",                           default: true, null: false
    t.boolean  "running",                           default: false, null: false
    t.string   "params"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.index ["suite_id"], name: "index_tests_on_suite_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "plan_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
    t.string   "image"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["plan_id"], name: "index_users_on_plan_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "assertions", "tests"
  add_foreign_key "extracts", "steps"
  add_foreign_key "prep_tests", "steps"
  add_foreign_key "prep_tests", "suites"
  add_foreign_key "prep_tests", "tests"
  add_foreign_key "results", "assertions"
  add_foreign_key "results", "steps"
  add_foreign_key "results", "tests"
  add_foreign_key "steps", "tests"
  add_foreign_key "suites", "users"
  add_foreign_key "test_params", "tests"
  add_foreign_key "tests", "suites"
  add_foreign_key "users", "plans"
end
