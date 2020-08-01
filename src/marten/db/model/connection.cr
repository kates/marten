module Marten
  module DB
    abstract class Model
      module Connection
        macro included
          extend Marten::DB::Model::Connection::ClassMethods
        end

        module ClassMethods
          def connection
            DB::Connection.for(table_name)
          end
        end
      end
    end
  end
end