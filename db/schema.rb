# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150820133554) do

  create_table "accounts", force: :cascade do |t|
    t.string   "subdomain",     limit: 255, default: "", null: false
    t.string   "company_name",  limit: 255, default: "", null: false
    t.string   "company_url",   limit: 255, default: ""
    t.string   "company_phone", limit: 255, default: ""
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["subdomain"], :name => "index_accounts_on_subdomain", :unique => true
  end

  create_table "clients", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "account_id", limit: 4
    t.index ["account_id"], :name => "fk__clients_account_id"
    t.foreign_key ["account_id"], "accounts", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_clients_account_id"
  end

  create_table "projects", force: :cascade do |t|
    t.integer  "client_id",   limit: 4,   null: false
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.datetime "deleted_at"
    t.integer  "account_id",  limit: 4
    t.index ["account_id"], :name => "fk__projects_account_id"
    t.index ["client_id"], :name => "fk__projects_client_id"
    t.index ["deleted_at"], :name => "index_projects_on_deleted_at"
    t.foreign_key ["account_id"], "accounts", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_projects_account_id"
    t.foreign_key ["client_id"], "clients", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_projects_client_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "deleted_at"
    t.integer  "account_id", limit: 4
    t.index ["account_id"], :name => "fk__tasks_account_id"
    t.index ["deleted_at"], :name => "index_tasks_on_deleted_at"
    t.foreign_key ["account_id"], "accounts", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_tasks_account_id"
  end

  create_table "task_projects", force: :cascade do |t|
    t.integer  "task_id",    limit: 4
    t.integer  "project_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["project_id"], :name => "fk__task_projects_project_id"
    t.index ["task_id", "project_id"], :name => "index_task_projects_on_task_id_and_project_id", :unique => true
    t.index ["task_id"], :name => "fk__task_projects_task_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_task_projects_project_id"
    t.foreign_key ["task_id"], "tasks", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_task_projects_task_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "deleted_at"
    t.integer  "account_id", limit: 4
    t.index ["account_id"], :name => "fk__teams_account_id"
    t.index ["deleted_at"], :name => "index_teams_on_deleted_at"
    t.foreign_key ["account_id"], "accounts", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_teams_account_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             limit: 255, default: "", null: false
    t.string   "last_name",              limit: 255, default: "", null: false
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id",                limit: 4
    t.string   "qr_code",                limit: 255
    t.integer  "pin_code",               limit: 4
    t.integer  "team_id",                limit: 4
    t.string   "avatar_file_name",       limit: 255
    t.string   "avatar_content_type",    limit: 255
    t.integer  "avatar_file_size",       limit: 4
    t.datetime "avatar_updated_at"
    t.integer  "account_id",             limit: 4
    t.string   "access_token",           limit: 255
    t.datetime "archived_at"
    t.index ["account_id"], :name => "fk__users_account_id"
    t.index ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
    t.index ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
    t.index ["role_id"], :name => "fk__users_role_id"
    t.index ["team_id"], :name => "fk__users_team_id"
    t.foreign_key ["account_id"], "accounts", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_users_account_id"
    t.foreign_key ["role_id"], "roles", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_users_role_id"
    t.foreign_key ["team_id"], "teams", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_users_team_id"
  end

  create_table "time_stations", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.float    "total_time", limit: 24, default: 0.0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "parent_id",  limit: 4
    t.index ["parent_id"], :name => "fk__time_stations_parent_id"
    t.index ["user_id"], :name => "fk__time_stations_user_id"
    t.foreign_key ["parent_id"], "time_stations", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_time_stations_parent_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_time_stations_user_id"
  end

  create_table "timesheets", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.integer  "task_id",        limit: 4
    t.integer  "project_id",     limit: 4
    t.datetime "start_time"
    t.datetime "stop_time"
    t.float    "total_time",     limit: 24,  default: 0.0
    t.boolean  "running",        limit: 1,   default: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "notes",          limit: 255
    t.date     "belongs_to_day"
    t.datetime "deleted_at"
    t.index ["deleted_at"], :name => "index_timesheets_on_deleted_at"
    t.index ["project_id"], :name => "fk__timesheets_project_id"
    t.index ["task_id"], :name => "fk__timesheets_task_id"
    t.index ["user_id"], :name => "fk__timesheets_user_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_timesheets_project_id"
    t.foreign_key ["task_id"], "tasks", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_timesheets_task_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_timesheets_user_id"
  end

  create_table "user_projects", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "project_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["project_id"], :name => "fk__user_projects_project_id"
    t.index ["user_id", "project_id"], :name => "index_user_projects_on_user_id_and_project_id", :unique => true
    t.index ["user_id"], :name => "fk__user_projects_user_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_user_projects_project_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_user_projects_user_id"
  end

end
