require 'active_record'

namespace :db do

	desc "Loads initial database models for the current environment."
	task :populate => :environment do
		require File.join(File.dirname(__FILE__), '/../lib', 'create_or_update')
		Dir[File.join(RAILS_ROOT, 'db', 'populate', '*.rb')].sort.each do |fixture| 
			load fixture 
			puts "Loaded #{fixture}"
		end
		Dir[File.join(RAILS_ROOT, 'db', 'populate', RAILS_ENV, '*.rb')].sort.each do |fixture| 
			load fixture 
			puts "Loaded #{fixture}"
		end
	end

	desc "Populates all Postgres schemas"
	task :populate_schemas => :environment do
		# get all schemas
		env = "#{RAILS_ENV}"
		config = YAML::load(File.open('config/database.yml'))
		ActiveRecord::Base.establish_connection(config[env])
		schemas = ActiveRecord::Base.connection.select_values("select * from pg_namespace where nspname != 'information_schema' AND nspname NOT LIKE 'pg%'")
		# puts "Migrate schemas: #{schemas.inspect}"
		# migrate each schema
		schemas.each do |schema|
			# puts "Migrate schema: #{schema}"
			config = YAML::load(File.open('config/database.yml'))
			config[env]["schema_search_path"] = schema
			ActiveRecord::Base.establish_connection(config[env])
			ActiveRecord::Base.logger = Logger.new(STDOUT)

			require File.join(File.dirname(__FILE__), '/../lib', 'create_or_update')
			Dir[File.join(RAILS_ROOT, 'db', 'populate', '*.rb')].sort.each do |fixture| 
				load fixture 
				puts "Loaded #{fixture}"
			end
			Dir[File.join(RAILS_ROOT, 'db', 'populate', RAILS_ENV, '*.rb')].sort.each do |fixture| 
				load fixture 
				puts "Loaded #{fixture}"
			end

		end	
	end

	desc "Runs migrations and then loads seed data"
	task :migrate_and_populate => [ 'db:migrate', 'db:populate' ]

	task :migrate_and_load => [ 'db:migrate', 'db:populate' ]

	desc "Drop and reset the database for the current environment and then load seed data"
	task :reset_and_populate => [ 'db:reset', 'db:populate']

	task :reset_and_load => [ 'db:reset', 'db:populate']

end
