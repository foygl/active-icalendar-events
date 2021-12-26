#!/usr/bin/env ruby

require 'bundler'
Bundler.require

require 'active_support'
require 'active_support/core_ext'
require 'date'
require 'icalendar'
require 'set'

# See https://datatracker.ietf.org/doc/html/rfc5545 for more details about icalendar format
#
# "rrule" structure that we are supporting (we only support array size of one)
# - frequency: String
#   - DAILY
#   - WEEKLY
#   - MONTHLY
#   - YEARLY
# - until: String Date (e.g. 20220324T235959Z). Can't be used with "count"
# - count: Integer. Can't be used with "until"
# - interval: Integer (modifier for frequency e.g. every 2 days)
# - by_second: UNSUPPORTED
# - by_minute: UNSUPPORTED
# - by_hour: UNSUPPORTED
# - by_day: Array of String
#   - When frequency is WEEKLY:
#     - MO
#     - TU
#     - WE
#     - TH
#     - FR
#     - SA
#     - SU
#   - When frequency is MONTHLY:
#     - 4FR etc. (i.e. 4th Friday of every month)
# - by_month_day: Array of Numerical Strings (When frequency is MONTHLY)
#   - 1
#   - 2
#   - ...
#   - 31
# - by_year_day: UNSUPPORTED
# - by_week_number: UNSUPPORTED
# - by_month: UNSUPPORTED
# - by_set_position: UNSUPPORTED
# - week_start: UNSUPPORTED

module ActiveIcalendarEvents
  module_function

  # datetime:       instance of DateTime
  # icalendar_data: output of Icalendar::Calendar.parse(cal_file)
  def all_active_events(datetime, icalendar_data)
    active_events = Set.new

    format_icalendar_data(icalendar_data).each do |_, events|
      recurrence_definition = events.select { |e|
        !e[:recurrence_rule].empty? || !e[:recurrence_dates].empty?
      }
      if recurrence_definition.size > 1
        raise RuntimeError, 'Should only have one event that defines the recurrence in a group'
      elsif recurrence_definition.size == 1
        r = recurrence_definition.first
        if r[:recurrence_rule].size > 1
          raise RuntimeError, 'Multiple recurrence rules not supported'
        elsif r[:recurrence_rule].size == 1
          # TODO: Validate the overrides
          active_events << get_active_event_for_datetime(
            :datetime => datetime,
            :name => r[:name],
            :event_start => r[:event_start],
            :event_end => r[:event_end],
            :recurrence_rule => r[:recurrence_rule].first,
            :recurrence_dates => r[:recurrence_dates],
            :excluding_dates => r[:excluding_dates],
            :overrides => events.reject { |e| e == r }.group_by { |e| e[:recurrence_id] }
          )
        else
          # TODO: Haven't bothered implementing this as Google Calendar doesn't seem to use these
          raise RuntimeError, 'Not yet implemented when only recurrence_dates are provided'
        end
      else
        # Non reccurring events
        events.each { |e|
          active_events.add(e[:name]) if is_event_active?(datetime, e[:event_start].to_time, e[:event_end].to_time)
        }
      end
    end

    # Remove 'nil' if it has been put in the set
    active_events.delete nil

    active_events
  end

  private

  def format_icalendar_data(icalendar_data)
    icalendar_data.first.events.map { |e|
      {
        name: e.summary.downcase,
        event_start: e.dtstart,
        event_end: e.dtend,
        recurrence_rule: e.rrule,
        recurrence_dates: e.rdate,
        excluding_dates: e.exdate,
        recurrence_id: e.recurrence_id,
        uid: e.uid
      }
    }.group_by { |e| e[:uid] }
  end

  def is_event_active?(datetime, event_start, event_end)
    event_start <= datetime.to_time &&
      event_end > datetime.to_time
  end

  def until_datetime_passed?(considered_datetime, until_datetime)
    !until_datetime.nil? && considered_datetime > until_datetime
  end

  def instance_count_exceeded?(considered_count, count)
    !count.nil? && considered_count > count
  end

  def is_daily_event_active_for_datetime?(datetime,
                                          event_start,
                                          event_end,
                                          until_datetime,
                                          count,
                                          interval,
                                          excluding_dates,
                                          overridden_dates)
    event_start_considered = event_start
    event_end_considered = event_end
    considered_count = 1
    while !until_datetime_passed?(event_start_considered, until_datetime) &&
          !instance_count_exceeded?(considered_count, count) &&
          event_start_considered <= datetime

      if is_event_active?(datetime, event_start_considered, event_end_considered)
        return !excluding_dates.include?(event_start_considered) &&
               !overridden_dates.include?(event_start_considered)
      end

      if !excluding_dates.include?(event_start_considered)
        considered_count += 1
      end

      event_start_considered = event_start_considered + interval.days
      event_end_considered = event_end_considered + interval.days
    end

    false
  end

  def is_weekly_event_active_for_datetime?(datetime,
                                           event_start,
                                           event_end,
                                           until_datetime,
                                           count,
                                           interval,
                                           by_day,
                                           excluding_dates,
                                           overridden_dates)
    event_start_considered = event_start
    event_end_considered = event_end
    considered_count = 1
    while !instance_count_exceeded?(considered_count, count)

      if by_day.empty?
        if until_datetime_passed?(event_start_considered, until_datetime) ||
           event_start_considered > datetime
          return false
        end

        if is_event_active?(datetime, event_start_considered, event_end_considered)
          return !excluding_dates.include?(event_start_considered) &&
                 !overridden_dates.include?(event_start_considered)
        end

        if !excluding_dates.include?(event_start_considered)
          considered_count += 1
        end
      else
        week_event_start_considered =
          event_start_considered.monday? ? event_start_considered :
                                           event_start_considered.prev_occurring(:monday)
        week_event_end_considered =
          (week_event_start_considered.to_time + (event_end.to_time - event_start.to_time)).to_datetime

        (1..7).each { |_|
          if week_event_start_considered >= event_start
            if until_datetime_passed?(week_event_start_considered, until_datetime) ||
               instance_count_exceeded?(considered_count, count) ||
               week_event_start_considered > datetime
              return false
            end

            day_code = week_event_start_considered.strftime("%^a").chop

            if by_day.include?(day_code)
              if is_event_active?(datetime, week_event_start_considered, week_event_end_considered)
                return !excluding_dates.include?(week_event_start_considered) &&
                       !overridden_dates.include?(week_event_start_considered)
              end

              if !excluding_dates.include?(week_event_start_considered)
                considered_count += 1
              end
            end
          end

          week_event_start_considered = week_event_start_considered + 1.days
          week_event_end_considered = week_event_end_considered + 1.days
        }
      end

      event_start_considered = event_start_considered + interval.weeks
      event_end_considered = event_end_considered + interval.weeks
    end

    false
  end

  def get_nth_day_in_month(datetime, day)
    matches = day.match /^([0-9]+)([A-Z]+)$/
    if matches.nil?
      raise RuntimeError, "Unexpected by_day format found"
    end

    number, day_code = matches.captures

    day_label = case day_code
                when 'MO'
                  :monday
                when 'TU'
                  :tuesday
                when 'WE'
                  :wednesday
                when 'TH'
                  :thursday
                when 'FR'
                  :friday
                when 'SA'
                  :saturday
                when 'SU'
                  :sunday
                else
                  raise RuntimeError, "Unexpected day code used"
                end

    target_day = datetime.beginning_of_month

    if target_day.strftime("%^a").chop != day_code
      target_day = target_day.next_occurring(day_label)
    end

    (2..number.to_i).each { |_|
      target_day = target_day.next_occurring(day_label)
    }

    target_day
  end

  def is_monthly_event_active_for_datetime?(datetime,
                                            event_start,
                                            event_end,
                                            until_datetime,
                                            count,
                                            interval,
                                            by_day,
                                            by_month_day,
                                            excluding_dates,
                                            overridden_dates)
    # TODO: We will ignore the contents of "by_month_day" for now and assume
    #       always contains one number which is the same as the day of
    #       "event_start". We additionally assume that "by_day" will only contain
    #       a single value.

    event_start_considered = event_start
    event_end_considered = event_end
    considered_count = 1
    while !until_datetime_passed?(event_start_considered, until_datetime) &&
          !instance_count_exceeded?(considered_count, count) &&
          event_start_considered <= datetime

      if is_event_active?(datetime, event_start_considered, event_end_considered)
        return !excluding_dates.include?(event_start_considered) &&
               !overridden_dates.include?(event_start_considered)
      end

      if !excluding_dates.include?(event_start_considered)
        considered_count += 1
      end

      if by_day.nil? || by_day.empty?
        event_start_considered = event_start_considered + interval.month
        event_end_considered = event_end_considered + interval.month
      else
        event_start_considered =
          get_nth_day_in_month(event_start_considered.beginning_of_month + interval.month,
                               by_day.first)
        event_end_considered =
          (event_start_considered.to_time + (event_end.to_time - event_start.to_time)).to_datetime
      end
    end

    false
  end

  def is_yearly_event_active_for_datetime?(datetime,
                                           event_start,
                                           event_end,
                                           until_datetime,
                                           count,
                                           interval,
                                           excluding_dates,
                                           overridden_dates)
    event_start_considered = event_start
    event_end_considered = event_end
    considered_count = 1
    while !until_datetime_passed?(event_start_considered, until_datetime) &&
          !instance_count_exceeded?(considered_count, count) &&
          event_start_considered <= datetime

      if is_event_active?(datetime, event_start_considered, event_end_considered)
        return !excluding_dates.include?(event_start_considered) &&
               !overridden_dates.include?(event_start_considered)
      end

      if !excluding_dates.include?(event_start_considered)
        considered_count += 1
      end

      event_start_considered = event_start_considered + interval.years
      event_end_considered = event_end_considered + interval.years
    end

    false
  end

  def get_active_event_for_datetime(datetime: DateTime.now,
                                    name:,
                                    event_start:,
                                    event_end:,
                                    recurrence_rule:,
                                    recurrence_dates: [],
                                    excluding_dates: [],
                                    overrides:)
    # Can return early if one of the overrides matches as they always take precendence
    overrides.values.flatten.each { |e|
      return e[:name] if e[:event_start] <= datetime.to_time &&
                         e[:event_end] > datetime.to_time
    }

    # Can return early if one of the recurrence dates matches and is not overridden
    # Note: I've just made an assumption about how this data could be presented.
    #       Google Calendar does not seem to create rdates, only rrules.
    (recurrence_dates - overrides.keys).each { |recurrence_event_start|
      recurrence_event_end = recurrence_event_start + (event_end.to_time - event_start.to_time)
      return name if is_event_active?(datetime, recurrence_event_start, recurrence_event_end)
    }

    until_datetime = nil
    if !recurrence_rule.until.nil?
      until_datetime = DateTime.parse(recurrence_rule.until)
    end

    case recurrence_rule.frequency
    when "DAILY"
      return name if is_daily_event_active_for_datetime?(
        datetime,
        event_start,
        event_end,
        until_datetime,
        recurrence_rule.count,
        recurrence_rule.interval.nil? ? 1 : recurrence_rule.interval,
        excluding_dates,
        overrides.keys
      )
    when "WEEKLY"
      return name if is_weekly_event_active_for_datetime?(
        datetime,
        event_start,
        event_end,
        until_datetime,
        recurrence_rule.count,
        recurrence_rule.interval.nil? ? 1 : recurrence_rule.interval,
        recurrence_rule.by_day,
        excluding_dates,
        overrides.keys
      )
    when "MONTHLY"
      return name if is_monthly_event_active_for_datetime?(
        datetime,
        event_start,
        event_end,
        until_datetime,
        recurrence_rule.count,
        recurrence_rule.interval.nil? ? 1 : recurrence_rule.interval,
        recurrence_rule.by_day,
        recurrence_rule.by_month_day,
        excluding_dates,
        overrides.keys
      )
    when "YEARLY"
      return name if is_yearly_event_active_for_datetime?(
        datetime,
        event_start,
        event_end,
        until_datetime,
        recurrence_rule.count,
        recurrence_rule.interval.nil? ? 1 : recurrence_rule.interval,
        excluding_dates,
        overrides.keys
      )
    else
      throw RuntimeError, "Invalid event frequency"
    end

    nil
  end

end
