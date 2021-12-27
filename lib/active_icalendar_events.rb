#!/usr/bin/env ruby
# frozen_string_literal: true

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
      recurrence_definition = events.select do |e|
        !e[:recurrence_rule].empty? || !e[:recurrence_dates].empty?
      end
      if recurrence_definition.size > 1
        raise 'Should only have one event that defines the recurrence in a group'
      elsif recurrence_definition.size == 1
        r = recurrence_definition.first
        if r[:recurrence_rule].size > 1
          raise 'Multiple recurrence rules not supported'
        elsif r[:recurrence_rule].size == 1
          # TODO: Validate the overrides
          active_events << get_active_event_for_datetime(
            datetime: datetime,
            name: r[:name],
            event_start: r[:event_start],
            event_end: r[:event_end],
            recurrence_rule: r[:recurrence_rule].first,
            recurrence_dates: r[:recurrence_dates],
            excluding_dates: r[:excluding_dates],
            overrides: events.reject { |e| e == r }.group_by { |e| e[:recurrence_id] }
          )
        else
          # TODO: Haven't bothered implementing this as Google Calendar doesn't seem to use these
          raise 'Not yet implemented when only recurrence_dates are provided'
        end
      else
        # Non reccurring events
        events.each do |e|
          active_events.add(e[:name]) if event_active?(datetime, e[:event_start], e[:event_end])
        end
      end
    end

    # Remove 'nil' if it has been put in the set
    active_events.delete nil

    active_events.to_a
  end

  def timezone_for_event(event)
    if event.parent.timezones.empty?
      ActiveSupport::TimeZone.new(event.parent.custom_properties['x_wr_timezone'].first.to_s)
    else
      ActiveSupport::TimeZone.new(event.parent.timezones.first.tzid.to_s)
    end
  end

  def format_icalendar_data(icalendar_data)
    icalendar_data.first.events.map do |e|
      event_start = e.dtstart
      if event_start.is_a?(Icalendar::Values::Date)
        timezone ||= timezone_for_event(e)
        event_start = timezone.local(event_start.year, event_start.month, event_start.day)
      end

      event_end = e.dtend
      if event_end.is_a?(Icalendar::Values::Date)
        timezone ||= timezone_for_event(e)
        event_end = timezone.local(event_end.year, event_end.month, event_end.day)
      end

      excluding_dates = e.exdate.map do |d|
        if d.is_a?(Icalendar::Values::Date)
          timezone ||= timezone_for_event(e)
          timezone.local(d.year, d.month, d.day)
        else
          d
        end
      end

      recurrence_dates = e.rdate.map do |d|
        if d.is_a?(Icalendar::Values::Date)
          timezone ||= timezone_for_event(e)
          timezone.local(d.year, d.month, d.day)
        else
          d
        end
      end

      e.rrule.each do |rrule|
        unless rrule.until.nil?
          timezone ||= timezone_for_event(e)
          rrule.until = timezone.parse(rrule.until)
        end
      end

      {
        name: e.summary,
        event_start: event_start,
        event_end: event_end,
        recurrence_rule: e.rrule,
        recurrence_dates: recurrence_dates,
        excluding_dates: excluding_dates,
        recurrence_id: e.recurrence_id,
        uid: e.uid
      }
    end.group_by { |e| e[:uid] }
  end

  def event_active?(datetime, event_start, event_end)
    event_start <= datetime.to_time &&
      event_end > datetime.to_time
  end

  def until_datetime_passed?(considered_datetime, until_datetime)
    !until_datetime.nil? && considered_datetime > until_datetime
  end

  def instance_count_exceeded?(considered_count, count)
    !count.nil? && considered_count > count
  end

  def daily_event_active_for_datetime?(datetime,
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

      if event_active?(datetime, event_start_considered, event_end_considered)
        return !excluding_dates.include?(event_start_considered) &&
               !overridden_dates.include?(event_start_considered)
      end

      # We consider both active dates and excluded dates for the recurrence count
      considered_count += 1

      event_start_considered += interval.days
      event_end_considered += interval.days
    end

    false
  end

  def weekly_event_active_for_datetime?(datetime,
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
    until instance_count_exceeded?(considered_count, count)

      # NOTE: Google Calendar does not appear to produce weekly events that do not specify a "by_day" array, so this path is untested
      if by_day.empty?
        if until_datetime_passed?(event_start_considered, until_datetime) ||
           event_start_considered > datetime
          return false
        end

        if event_active?(datetime, event_start_considered, event_end_considered)
          return !excluding_dates.include?(event_start_considered) &&
                 !overridden_dates.include?(event_start_considered)
        end

        # We consider both active dates and excluded dates for the recurrence count
        considered_count += 1
      else
        week_event_start_considered =
          if event_start_considered.monday?
            event_start_considered
          else
            event_start_considered.prev_occurring(:monday)
          end
        week_event_end_considered = week_event_start_considered + (event_end.to_time - event_start.to_time).seconds

        (1..7).each do |_|
          if week_event_start_considered >= event_start
            if until_datetime_passed?(week_event_start_considered, until_datetime) ||
               instance_count_exceeded?(considered_count, count) ||
               week_event_start_considered > datetime
              return false
            end

            day_code = week_event_start_considered.strftime('%^a').chop

            if by_day.include?(day_code)
              if event_active?(datetime, week_event_start_considered, week_event_end_considered)
                return !excluding_dates.include?(week_event_start_considered) &&
                       !overridden_dates.include?(week_event_start_considered)
              end

              # We consider both active dates and excluded dates for the recurrence count
              considered_count += 1
            end
          end

          week_event_start_considered += 1.days
          week_event_end_considered += 1.days
        end
      end

      event_start_considered += interval.weeks
      event_end_considered += interval.weeks
    end

    false
  end

  # Get the beginning of the month, maintaining the timestamp
  def beginning_of_month(datetime)
    datetime - (datetime.day - 1).days
  end

  def get_nth_day_in_month(datetime, day)
    matches = day.match(/^([0-9]+)([A-Z]+)$/)
    raise 'Unexpected by_day format found' if matches.nil?

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
                  raise 'Unexpected day code used'
                end

    target_day = beginning_of_month(datetime)

    target_day = target_day.next_occurring(day_label) if target_day.strftime('%^a').chop != day_code

    (2..number.to_i).each do |_|
      target_day = target_day.next_occurring(day_label)
    end

    target_day
  end

  def monthly_event_active_for_datetime?(datetime,
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

      if event_active?(datetime, event_start_considered, event_end_considered)
        return !excluding_dates.include?(event_start_considered) &&
               !overridden_dates.include?(event_start_considered)
      end

      # We consider both active dates and excluded dates for the recurrence count
      considered_count += 1

      if by_day.nil? || by_day.empty?
        event_start_considered += interval.month
        event_end_considered += interval.month
      else
        event_start_considered =
          get_nth_day_in_month(beginning_of_month(event_start_considered) + interval.month,
                               by_day.first)
        event_end_considered = event_start_considered + (event_end.to_time - event_start.to_time).seconds
      end
    end

    false
  end

  def yearly_event_active_for_datetime?(datetime,
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

      if event_active?(datetime, event_start_considered, event_end_considered)
        return !excluding_dates.include?(event_start_considered) &&
               !overridden_dates.include?(event_start_considered)
      end

      # We consider both active dates and excluded dates for the recurrence count
      considered_count += 1

      event_start_considered += interval.years
      event_end_considered += interval.years
    end

    false
  end

  def get_active_event_for_datetime(name:, event_start:, event_end:, recurrence_rule:, overrides:, datetime: DateTime.now,
                                    recurrence_dates: [],
                                    excluding_dates: [])
    # Can return early if one of the overrides matches as they always take precendence
    overrides.values.flatten.each do |e|
      return e[:name] if event_active?(datetime, e[:event_start], e[:event_end])
    end

    # Can return early if one of the recurrence dates matches and is not overridden
    # Note: I've just made an assumption about how this data could be presented.
    #       Google Calendar does not seem to create rdates, only rrules.
    (recurrence_dates - overrides.keys).each do |recurrence_event_start|
      recurrence_event_end = recurrence_event_start + (event_end.to_time - event_start.to_time).seconds
      return name if event_active?(datetime, recurrence_event_start, recurrence_event_end)
    end

    case recurrence_rule.frequency
    when 'DAILY'
      return name if daily_event_active_for_datetime?(
        datetime,
        event_start,
        event_end,
        recurrence_rule.until,
        recurrence_rule.count,
        recurrence_rule.interval.nil? ? 1 : recurrence_rule.interval,
        excluding_dates,
        overrides.keys
      )
    when 'WEEKLY'
      return name if weekly_event_active_for_datetime?(
        datetime,
        event_start,
        event_end,
        recurrence_rule.until,
        recurrence_rule.count,
        recurrence_rule.interval.nil? ? 1 : recurrence_rule.interval,
        recurrence_rule.by_day,
        excluding_dates,
        overrides.keys
      )
    when 'MONTHLY'
      return name if monthly_event_active_for_datetime?(
        datetime,
        event_start,
        event_end,
        recurrence_rule.until,
        recurrence_rule.count,
        recurrence_rule.interval.nil? ? 1 : recurrence_rule.interval,
        recurrence_rule.by_day,
        recurrence_rule.by_month_day,
        excluding_dates,
        overrides.keys
      )
    when 'YEARLY'
      return name if yearly_event_active_for_datetime?(
        datetime,
        event_start,
        event_end,
        recurrence_rule.until,
        recurrence_rule.count,
        recurrence_rule.interval.nil? ? 1 : recurrence_rule.interval,
        excluding_dates,
        overrides.keys
      )
    else
      throw RuntimeError, 'Invalid event frequency'
    end

    nil
  end
end
