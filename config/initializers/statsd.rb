METRICS = Statsd.new(ENV['UTIL_MONITOR_IP'] || 'localhost', 8125)
METRICS.namespace = "fu2"
