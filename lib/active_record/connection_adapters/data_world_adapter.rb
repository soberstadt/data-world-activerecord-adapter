require 'active_record/connection_adapters/abstract_adapter'
require 'uri'
require 'net/http'
require 'openssl'

module ActiveRecord
  class Base
    class << self
      def data_world_connection(config)
        ConnectionAdapters::DataWorldAdapter.new({}, logger, config)
      end
    end
  end

  module ConnectionAdapters #:nodoc:

    class DataWorldAdapter < AbstractAdapter
      def adapter_name #:nodoc:
        'Data.World'
      end

      def requires_reloading?
        true
      end

      def supports_count_distinct? #:nodoc:
        true
      end


      # DATABASE STATEMENTS ======================================

      def execute(sql, name = nil) #:nodoc:
        url = URI("https://api.data.world/v0/sql/#{@config[:owner]}/#{@config[:id]}")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(url)
        request["content-type"] = 'application/json'
        request["authorization"] = "Bearer #{@config[:auth_token]}"
        request.body = {
          query: sql,
          includeTableSchema: true
        }.to_json

        response = http.request(request)

        try_json response.read_body
      end

      def exec_query(sql, name = nil, binds = [], prepare: false)
        if preventing_writes? && write_query?(sql)
          raise ActiveRecord::ReadOnlyError, "Data.World is read-only, query not accepted: #{sql}"
        end

        type_casted_binds = type_casted_binds(binds)

        log(sql, name, binds, type_casted_binds) do
          raw = execute(sql_bind(sql, binds))
          cols = raw.dig(0, 'fields')&.map { |h| h['name'] }
          records = raw[1..-1].map(&:values)

          ActiveRecord::Result.new(cols, records)
        end
      end

      # do our best job binding the variables into the query
      def sql_bind(sql, binds)
        new_sql = sql.clone
        binds.each do |attribute|
          value = if attribute.value.is_a?(String)
            "'#{attribute.value}'"
          else
            attribute.value.to_s
          end

          new_sql = new_sql.sub('?', value)
        end
        new_sql
      end

      def try_json(string)
        JSON.parse(string)
      rescue
        raise string
      end


      # SCHEMA STATEMENTS ========================================

      def tables(name = nil) #:nodoc:
        sql = "SELECT tableName FROM Tables"
        execute(sql, name).map { |row| row[0] }
      end

      def views
        []
      end

      def columns(table_name, name = nil) #:nodoc:
        table_structure(table_name).map do |field|
          type_metadata = SqlTypeMetadata.new(sql_type: field['columnDatatype'])
          ActiveRecord::ConnectionAdapters::Column.new(field['columnName'], nil, type_metadata)
        end
      end

      protected

      def table_structure(table_name)
        columns = execute("SELECT * FROM TableColumns WHERE tableName = \"#{table_name}\"")[1..-1]
        raise(ActiveRecord::StatementInvalid, "Could not find table '#{table_name}'") if columns.empty?
        columns
      end
    end
  end
end