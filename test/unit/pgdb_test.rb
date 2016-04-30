require 'test_helper'

class PGDBTest < ActiveSupport::TestCase
  def test_query
    assert PGDB.query("SELECT * FROM schema_migrations;").size > 0
  end

  def test_listen_notify
    n = 0
    PGDB.listen "test" do |message|
      p message
      n += 1
    end
    PGDB.notify("test", "foo")
    PGDB.notify("test", "foo2")
    sleep 3
    PGDB.unlisten("test")
    assert_equal 2, n
  end
end
