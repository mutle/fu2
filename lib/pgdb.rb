module PGDB

  class << self

    def callbacks
      @callbacks ||= {}
    end

    def add_callback(channel, callback)
      callbacks[channel] ||= []
      callbacks[channel] << callback
    end

    def connection
      ActiveRecord::Base.connection
    end

    def quote_string(s)
      connection.quote_string(s)
    end

    def query(q, args={})
      connection.query(q)
    end

    def pg_connection
      ActiveRecord::Base.connection_pool.with_connection do |ar_conn|
        pg_conn = ar_conn.raw_connection

        unless pg_conn.is_a?(PG::Connection)
          raise 'ActiveRecord database must be Postgres in order to use the Postgres ActionCable storage adapter'
        end

        yield pg_conn
      end
    end

    def listen(channel, &block)
      add_callback(channel, block)
      @listen_thread ||= Thread.new do
        Thread.current.abort_on_exception = true
        pg_connection do |c|
          c.exec "LISTEN #{channel};"
          loop do
            c.wait_for_notify(1) do |chan, pid, message|
              p [chan, pid, message]
              PGDB.callbacks[chan].each do |cb|
                cb(message)
              end
            end
          end
        end
      end
    end

    def unlisten(channel)
      query "UNLISTEN #{channel};"
      callbacks[channel] = nil
      if callbacks.size == 0 && @listen_thread
        @listen_thread.stop
        @listen_thread = nil
      end
    end

    def notify(channel, message)
      # query "SELECT pg_notify('#{channel}', '#{message}');"
      query "NOTIFY #{channel};"
    end

  end

end
