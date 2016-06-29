require "jsonpath"

module Embulk
  module Filter

    class Jsoncolumn < FilterPlugin
      Plugin.register_filter("jsoncolumn", self)

      def self.transaction(config, in_schema, &control)
        # configuration code:
        task = {
          'schema' => config.param("schema", :array),
          'columns' =>
            config.param('schema', :array, :default => []).inject({}){|a, col|
              a[col['name']] = col['type'].to_sym
              a
            }
        }

        columns = task['columns'].map.with_index{|(name, type), i|
          Column.new(i, name, type)
        }

        #out_columns = in_schema + columns
        out_columns = columns

        yield(task, out_columns)
      end

      def init
        # initialization code:
      end

      def close
      end

      def add(page)
        # filtering code:
        page.each do |records|
          records.each do |record|
            r = JSON.parse(record)
            page_builder.add(make_record(task['schema'], r))
          end
        end
      end

      def make_record(schema, e)
        schema.map do |c|
          name = c["name"]
          path = c["path"]
          val = path.nil? ? e[name] : find_by_path(e, path)

          puts "PATH: #{path}"
          puts "VAL: #{val}"

          v = val.nil? ? "" : val
          type = c["type"]
          case type
            when "string"
              v
            when "long"
              v.to_i
            when "double"
              v.to_f
            when "boolean"
              if v.nil?
                nil
              elsif v.kind_of?(String)
                ["yes", "true", "1"].include?(v.downcase)
              elsif v.kind_of?(Numeric)
                !v.zero?
              else
                !!v
              end
            when "timestamp"
              v.empty? ? nil : Time.strptime(v, c["format"])
            else
              raise "Unsupported type #{type}"
          end
        end
      end

      def find_by_path(e, path)
        JsonPath.on(e, path).first
      end

      def finish
        page_builder.finish
      end
    end

  end
end
