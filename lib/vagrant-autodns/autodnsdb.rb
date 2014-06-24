#© 2014 LinkedIn Corp. All rights reserved.
#Licensed under the Apache License, Version 2.0 (the "License"); you may not
#use this file except in compliance with the License. You may obtain a copy of
#the License at  http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

require 'sqlite3'
require 'fileutils'

module VagrantAutoDNS
  class AutoDNSDB
    attr_reader :db
    def initialize(db_file = 'autodns.db')
      FileUtils.mkdir_p(File.dirname(db_file))
      @db = SQLite3::Database.new(db_file)
      @db.results_as_hash = true
      @db.execute(Query::CREATE_RECORDS_TABLE)
    end

    def find_record(hostname)
      @db.get_first_row(Query::FIND_RECORD, [hostname])
    end

    def update_record(hostname, ip, vagrant_id = nil)
      @db.execute(Query::UPDATE_RECORD, [hostname, ip, vagrant_id, Time.now.to_i])
    end

    def delete_record(hostname)
       @db.execute(Query::DELETE_RECORD, [hostname])
    end

    def delete_host(vagrant_id)
      @db.execute(Query::DELETE_HOST, [vagrant_id])
    end

    def list_all_records
      @db.execute(Query::LIST_ALL_RECORDS)
    end

    def delete_all_records
      @db.execute(Query::DELETE_ALL_RECORDS)
    end

    def dependent_vms
      @db.execute(Query::LIST_DEPENDENT_VMS).map{|r| r['vagrant_id']}
    end

    class Query
      DELETE_ALL_RECORDS = 'DELETE FROM records'

      LIST_ALL_RECORDS = 'SELECT * FROM records'

      UPDATE_RECORD = <<-END_QUERY.gsub(/\s+/, ' ').strip
        INSERT OR REPLACE INTO records (hostname, ip, vagrant_id, modified)
        VALUES (?, ?, ?, ?)
      END_QUERY

      FIND_RECORD = 'SELECT * FROM records WHERE hostname = ?'

      DELETE_RECORD = 'DELETE FROM records WHERE hostname = ?'

      DELETE_HOST = 'DELETE FROM records WHERE vagrant_id = ?'

      LIST_DEPENDENT_VMS = <<-END_QUERY.gsub(/\s+/, ' ').strip
        SELECT vagrant_id FROM records
        WHERE vagrant_id IS NOT null
        GROUP BY vagrant_id
      END_QUERY

      CREATE_RECORDS_TABLE = <<-DBSETUP.gsub(/\s+/, ' ').strip
        CREATE TABLE IF NOT EXISTS records
        (
          hostname varchar(100) PRIMARY KEY,
          ip varchar(45),
          vagrant_id varchar(100),
          modified timestamp(20)
        )
      DBSETUP

    end

  end
end
