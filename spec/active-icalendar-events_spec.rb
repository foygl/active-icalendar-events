require './lib/active-icalendar-events.rb'

describe ActiveIcalendarEvents do
  def run_active_events_test(ical_file_path, datetime_s, zone_s, expected_active_events)
    zone = ActiveSupport::TimeZone.new(zone_s)
    datetime = zone.parse(datetime_s).to_datetime

    ical_data = File.open(ical_file_path, 'r') { |ical_file|
      Icalendar::Calendar.parse(ical_file)
    }

    active_events = ActiveIcalendarEvents::all_active_events(
      datetime,
      ical_data
    )

    expect(active_events).to eq(expected_active_events), "expected #{expected_active_events.inspect} for #{datetime}, got #{active_events.inspect}"
  end

  it "check weekly, uk timezone over daylight savings, 25 instances" do
    ical_file_path = './spec/ical_files/google_calendar_uk_weekly_1000_to_1300_mwfs_25_instances.ics'

    # Check every active day
    expected_active_days = [
      '2022-03-16',
      '2022-03-18',
      '2022-03-20',
      '2022-03-21',
      '2022-03-23',
      '2022-03-25',
      '2022-03-27',
      '2022-03-28',
      '2022-03-30',
      '2022-04-01',
      '2022-04-03',
      '2022-04-04',
      '2022-04-06',
      '2022-04-08',
      '2022-04-10',
      '2022-04-11',
      '2022-04-13',
      '2022-04-15',
      '2022-04-17',
      '2022-04-18',
      '2022-04-20',
      '2022-04-22',
      '2022-04-24',
      '2022-04-25',
      '2022-04-27',
    ]

    # Check a representative selection of inactive days
    expected_inactive_days = [
      '2022-03-13',
      '2022-03-14',
      '2022-03-15',
      '2022-03-17',
      '2022-03-19',
      '2022-03-22',
      '2022-03-26',
      '2022-03-29',
      '2022-04-26',
      '2022-04-28',
      '2022-04-29',
      '2022-04-30',
      '2022-05-01',
      '2022-05-02',
    ]

    expected_active_times = [
      '10:00',
      '11:00',
      '12:00',
      '12:59',
    ]

    expected_inactive_times = [
      '09:00',
      '09:59',
      '13:00',
      '14:00',
    ]
    
    expected_active_days.each { |day|
      expected_active_times.each { |time|
        run_active_events_test(
          ical_file_path,
          "#{day} #{time}",
          'Europe/London',
          ['Weekly Test']
        )
      }

      expected_inactive_times.each { |time|
        run_active_events_test(
          ical_file_path,
          "#{day} #{time}",
          'Europe/London',
          []
        )
      }
    }
    
    expected_inactive_days.each { |day|
      (expected_active_times + expected_inactive_times).each { |time|
        run_active_events_test(
          ical_file_path,
          "#{day} #{time}",
          'Europe/London',
          []
        )
      }
    }
  end
end
