module Marten
  module DB
    module Management
      # Represents an SQL statement holding the detail of the tables and associated columns.
      #
      # This abstraction is mainly used in the context of the schema editor, where deferred statements need to be
      # temporarily stored in order to be executed later on. In those situations, statements need to provide the
      # ability to be mutated to apply possible schema changes to them.
      class Statement
        alias ReferenceTypes = Columns | ForeignKeyName | IndexName | Table

        getter params

        def initialize(@template : String, **kwargs)
          @params = Hash(String, ReferenceTypes).new
          @params.merge!(kwargs.to_h.transform_keys(&.to_s))
        end

        def references_column?(table : String, column : String) : Bool
          @params.values.any? { |ref| ref.references_column?(table, column) }
        end

        def references_table?(name : String) : Bool
          @params.values.any? { |ref| ref.references_table?(name) }
        end

        def rename_column(table : String, old_name : String, new_name : String)
          @params.values.each do |ref|
            ref.rename_column(table, old_name, new_name)
          end
        end

        def rename_table(old_name : String, new_name : String)
          @params.values.each do |ref|
            ref.rename_table(old_name, new_name)
          end
        end

        def to_s
          @template % @params.transform_values(&.to_s)
        end
      end
    end
  end
end
