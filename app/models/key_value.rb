class KeyValue < ActiveRecord::Base
  class << self
    def get(key)
      if key =~ /\[\]$/
        where(key: key).map(&:value)
      else
        where(key: key).first.try(:value)
      end
    end

    def set(key, value)
      if key =~ /\[\]$/
        create(key: key, value: value)
      else
        create_with(value: value).find_or_create_by(key: key)
      end
    end
  end
end
