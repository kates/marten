require "./spec_helper"

describe Marten::DB::Query::SQL::Predicate::EndsWith do
  describe "#to_sql" do
    it "returns the expected SQL statement" do
      predicate = Marten::DB::Query::SQL::Predicate::EndsWith.new(Post.get_field("title"), "foo", "table")
      {% if env("MARTEN_SPEC_DB_CONNECTION").id == "postgresql" %}
        predicate.to_sql(Marten::DB::Connection.default).should eq(
          {"table.title LIKE %s", ["%foo"]}
        )
      {% elsif env("MARTEN_SPEC_DB_CONNECTION").id == "mysql" %}
        predicate.to_sql(Marten::DB::Connection.default).should eq(
          {"table.title LIKE BINARY %s", ["%foo"]}
        )
      {% else %}
        predicate.to_sql(Marten::DB::Connection.default).should eq(
          {"table.title LIKE %s ESCAPE '\\'", ["%foo"]}
        )
      {% end %}
    end
  end
end