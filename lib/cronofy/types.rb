require "date"
require "hashie"

module Cronofy
  class DateOrTime
    def initialize(args)
      # Prefer time if both provided as it is more accurate
      if args[:time]
        @time = args[:time]
      else
        @date = args[:date]
      end
    end

    def self.coerce(value)
      begin
        time = Time.strptime(value, '%Y-%m-%dT%H:%M:%SZ')
      rescue
        begin
          date = Date.strptime(value, '%Y-%m-%d')
        rescue
        end
      end

      coerced = self.new(time: time, date: date)

      raise "Failed to coerce \"#{value}\"" unless coerced.time? or coerced.date?

      coerced
    end

    def date
      @date
    end

    def date?
      !!@date
    end

    def time
      @time
    end

    def time?
      !!@time
    end

    def to_date
      if date?
        date
      else
        time.to_date
      end
    end

    def to_time
      if time?
        time
      else
        # Convert dates to UTC time, not local time
        Time.utc(date.year, date.month, date.day)
      end
    end

    def ==(other)
      case other
      when DateOrTime
        if self.time?
          other.time? and self.time == other.time
        elsif self.date?
          other.date? and self.date == other.date
        else
          # Both neither date nor time
          self.time? == other.time? and self.date? == other.date?
        end
      else
        false
      end
    end

    def inspect
      to_s
    end

    def to_s
      if time?
        "<#{self.class} time=#{self.time}>"
      elsif date?
        "<#{self.class} date=#{self.date}>"
      else
        "<#{self.class} empty>"
      end
    end
  end

  class Calendar < Hashie::Mash
  end

  class Channel < Hashie::Mash
  end

  class Event < Hashie::Mash
    include Hashie::Extensions::Coercion

    coerce_key :start, DateOrTime
    coerce_key :end, DateOrTime
  end

  class PagedEventsResult < Hashie::Mash
    include Hashie::Extensions::Coercion

    coerce_key :events, Array[Event]
  end
end