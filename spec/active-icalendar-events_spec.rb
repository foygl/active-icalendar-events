require './lib/active-icalendar-events.rb'

describe ActiveIcalendarEvents do
  def run_active_events_test(ical_file_path, datetime_s, zone_s, expected_active_events)
    zone = ActiveSupport::TimeZone.new(zone_s)
    datetime = zone.parse(datetime_s)

    ical_data = File.open(ical_file_path, 'r') { |ical_file|
      Icalendar::Calendar.parse(ical_file)
    }

    active_events = ActiveIcalendarEvents::all_active_events(
      datetime,
      ical_data
    )

    expect(active_events).to match_array(expected_active_events), "expected #{expected_active_events.inspect} for #{datetime}, got #{active_events.inspect}"
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

  it "check weekly, uk timezone over daylight savings, 25 instances, with deletions" do
    ical_file_path = './spec/ical_files/google_calendar_uk_weekly_1000_to_1300_mwfs_25_instances_with_deletions.ics'

    # Check every active day
    expected_active_days = [
      '2022-03-18',
      '2022-03-20',
      '2022-03-21',
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
      '2022-04-18',
      '2022-04-20',
      '2022-04-22',
      '2022-04-24',
      '2022-04-25',
    ]

    expected_deleted_days = [
      '2022-03-16',
      '2022-03-23',
      '2022-03-25',
      '2022-04-17',
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

    (expected_deleted_days + expected_inactive_days).each { |day|
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

  it "check weekly, uk timezone over daylight savings, 25 instances, with deletions and moves" do
    ical_file_path = './spec/ical_files/google_calendar_uk_weekly_1000_to_1300_mwfs_25_instances_with_deletions_and_moves.ics'

    # Check every active day
    expected_active_days = [
      '2022-03-18',
      '2022-03-21',
      '2022-03-30',
      '2022-04-01',
      '2022-04-03',
      '2022-04-04',
      '2022-04-11',
      '2022-04-13',
      '2022-04-15',
      '2022-04-18',
      '2022-04-20',
      '2022-04-22',
      '2022-04-24',
      '2022-04-25',
    ]

    expected_deleted_days = [
      '2022-03-16',
      '2022-03-23',
      '2022-03-25',
      '2022-04-17',
      '2022-04-27',
    ]

    expected_moved_days = {
      '2022-03-20' => {
        :active_times => [
          '2022-03-20 16:00',
          '2022-03-20 17:00',
          '2022-03-20 18:00',
          '2022-03-20 18:59',
        ],
        :inactive_times => [
          '2022-03-20 15:59',
          '2022-03-20 19:00',
        ]
      }, # Moved to 16:00
      '2022-03-27' => {
        :active_times => [
          '2022-03-26 16:00',
          '2022-03-26 17:00',
          '2022-03-26 18:00',
          '2022-03-26 18:59',
        ],
        :inactive_times => [
          '2022-03-26 15:59',
          '2022-03-26 19:00',
        ]
      }, # Moved to 16:00 the day before
      '2022-03-28' => {
        :active_times => [
          '2022-03-27 16:00',
          '2022-03-27 17:00',
          '2022-03-27 18:00',
          '2022-03-27 18:59',
        ],
        :inactive_times => [
          '2022-03-27 15:59',
          '2022-03-27 19:00',
        ]
      }, # Moved to 16:00 the day before
      '2022-04-06' => {
        :active_times => [
          '2022-03-26 23:00',
          '2022-03-27 00:00',
          '2022-03-27 00:59', # We lost an hour
        ],
        :inactive_times => [
          '2022-03-26 22:59',
          '2022-03-27 01:00', # We lost an hour
          '2022-04-06 09:00',
          '2022-04-06 10:00',
          '2022-04-06 11:00',
          '2022-04-06 12:00',
          '2022-04-06 13:00',
          '2022-04-06 14:00',
          '2022-04-06 15:00',
          '2022-04-06 16:00',
          '2022-04-06 17:00',
        ]
      }, # Moved to 23:00 on the 26th (daylight savings)
      '2022-04-08' => {
        :active_times => [
          '2022-04-09 16:00',
          '2022-04-09 17:00',
          '2022-04-09 18:00',
          '2022-04-09 18:59',
        ],
        :inactive_times => [
          '2022-04-09 15:59',
          '2022-04-09 19:00',
          '2022-04-08 09:00',
          '2022-04-08 10:00',
          '2022-04-08 11:00',
          '2022-04-08 12:00',
          '2022-04-08 13:00',
          '2022-04-08 14:00',
          '2022-04-08 15:00',
          '2022-04-08 16:00',
          '2022-04-08 17:00',
        ]
      }, # Moved to 16:00 the day after
      '2022-04-10' => {
        :active_times => [
          '2022-04-10 23:00',
          '2022-04-11 00:00',
          '2022-04-11 01:00',
          '2022-04-11 02:00',
          '2022-04-11 02:59',
        ],
        :inactive_times => [
          '2022-04-10 22:59',
          '2022-04-11 03:00',
          '2022-04-10 09:00',
          '2022-04-10 10:00',
          '2022-04-10 11:00',
          '2022-04-10 12:00',
          '2022-04-10 13:00',
          '2022-04-10 14:00',
          '2022-04-10 15:00',
          '2022-04-10 16:00',
          '2022-04-10 17:00',
        ]
      } # Moved to 23:00, increased duration to 4 hours
    }

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

    expected_moved_days.each { |_, times_to_check|
      times_to_check[:active_times].each { |time|
        run_active_events_test(
          ical_file_path,
          time,
          'Europe/London',
          ['Weekly Test']
        )
      }

      times_to_check[:inactive_times].each { |time|
        run_active_events_test(
          ical_file_path,
          time,
          'Europe/London',
          []
        )
      }
    }

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

    (expected_deleted_days + expected_inactive_days).each { |day|
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

  it "check daily, uk timezone over daylight savings, from 2022-10-26 to 2022-11-03" do
    ical_file_path = './spec/ical_files/google_calendar_uk_daily_until_date.ics'

    # Check every active day
    expected_active_days = [
      '2022-10-26',
      '2022-10-27',
      '2022-10-28',
      '2022-10-29',
      '2022-10-30',
      '2022-10-31',
      '2022-11-01',
      '2022-11-02',
      '2022-11-03',
    ]

    # Check a representative selection of inactive days
    expected_inactive_days = [
      '2022-10-24',
      '2022-10-25',
      '2022-11-04',
      '2022-11-05',
    ]

    expected_active_events_at_times = {
      '08:00' => ['All Day Daily Test'],
      '09:00' => ['All Day Daily Test'],
      '09:59' => ['All Day Daily Test'],
      '10:00' => ['All Day Daily Test', 'Daily Test'],
      '11:00' => ['All Day Daily Test', 'Daily Test'],
      '12:00' => ['All Day Daily Test', 'Daily Test'],
      '12:59' => ['All Day Daily Test', 'Daily Test'],
      '13:00' => ['All Day Daily Test'],
      '14:00' => ['All Day Daily Test'],
      '20:00' => ['All Day Daily Test'],
      '21:00' => ['All Day Daily Test'],
      '22:00' => ['All Day Daily Test'],
      '22:59' => ['All Day Daily Test'],
      '23:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '23:59' => ['All Day Daily Test', 'Late Night Daily Test'],
    }

    expected_active_events_at_specific_datetimes = {
      '2022-10-25 23:00' => [],
      '2022-10-25 23:59' => [],
      '2022-10-26 00:00' => ['All Day Daily Test'],
      '2022-10-26 01:00' => ['All Day Daily Test'],
      '2022-10-26 01:59' => ['All Day Daily Test'],
      '2022-10-26 02:00' => ['All Day Daily Test'],

      '2022-10-26 23:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-26 23:59' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-27 00:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-27 01:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-27 01:59' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-27 02:00' => ['All Day Daily Test'],

      '2022-10-29 23:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-29 23:59' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-30 00:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-30 01:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-30 01:59' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-30 02:00' => ['All Day Daily Test'],

      '2022-11-03 23:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-11-03 23:59' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-11-04 00:00' => ['Late Night Daily Test'],
      '2022-11-04 01:00' => ['Late Night Daily Test'],
      '2022-11-04 01:59' => ['Late Night Daily Test'],
      '2022-11-04 02:00' => [],
    }

    expected_active_days.each { |day|
      expected_active_events_at_times.each { |time, active_events|
        run_active_events_test(
          ical_file_path,
          "#{day} #{time}",
          'Europe/London',
          active_events
        )
      }
    }

    expected_inactive_days.each { |day|
      expected_active_events_at_times.each { |time, _|
        run_active_events_test(
          ical_file_path,
          "#{day} #{time}",
          'Europe/London',
          []
        )
      }
    }

    expected_active_events_at_specific_datetimes.each { |datetime, active_events|
      run_active_events_test(
        ical_file_path,
        datetime,
        'Europe/London',
        active_events
      )
    }
  end

  it "check daily, uk timezone over daylight savings, from 2022-10-26 to 2022-11-03, with deletions" do
    ical_file_path = './spec/ical_files/google_calendar_uk_daily_until_date_with_deletions.ics'

    # Check every active day
    expected_active_days = [
      '2022-10-27',
      '2022-10-28',
      '2022-10-30',
      '2022-11-01',
      '2022-11-02',
    ]

    expected_deleted_days = [
      '2022-10-26',
      '2022-10-29',
      '2022-10-31',
      '2022-11-03',
    ]

    # Check a representative selection of inactive days
    expected_inactive_days = [
      '2022-10-24',
      '2022-10-25',
      '2022-11-04',
      '2022-11-05',
    ]

    expected_active_events_at_times = {
      '08:00' => ['All Day Daily Test'],
      '09:00' => ['All Day Daily Test'],
      '09:59' => ['All Day Daily Test'],
      '10:00' => ['All Day Daily Test', 'Daily Test'],
      '11:00' => ['All Day Daily Test', 'Daily Test'],
      '12:00' => ['All Day Daily Test', 'Daily Test'],
      '12:59' => ['All Day Daily Test', 'Daily Test'],
      '13:00' => ['All Day Daily Test'],
      '14:00' => ['All Day Daily Test'],
      '20:00' => ['All Day Daily Test'],
      '21:00' => ['All Day Daily Test'],
      '22:00' => ['All Day Daily Test'],
      '22:59' => ['All Day Daily Test'],
      '23:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '23:59' => ['All Day Daily Test', 'Late Night Daily Test'],
    }

    expected_active_events_at_specific_datetimes = {
      '2022-10-25 23:00' => [],
      '2022-10-25 23:59' => [],
      '2022-10-26 00:00' => [],
      '2022-10-26 01:00' => [],
      '2022-10-26 01:59' => [],
      '2022-10-26 02:00' => [],

      '2022-10-26 23:00' => [],
      '2022-10-26 23:59' => [],
      '2022-10-27 00:00' => ['All Day Daily Test'],
      '2022-10-27 01:00' => ['All Day Daily Test'],
      '2022-10-27 01:59' => ['All Day Daily Test'],
      '2022-10-27 02:00' => ['All Day Daily Test'],

      '2022-10-27 23:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-27 23:59' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-28 00:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-28 01:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-28 01:59' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-10-28 02:00' => ['All Day Daily Test'],

      '2022-10-29 23:00' => [],
      '2022-10-29 23:59' => [],
      '2022-10-30 00:00' => ['All Day Daily Test'],
      '2022-10-30 01:00' => ['All Day Daily Test'],
      '2022-10-30 01:59' => ['All Day Daily Test'],
      '2022-10-30 02:00' => ['All Day Daily Test'],

      '2022-11-02 23:00' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-11-02 23:59' => ['All Day Daily Test', 'Late Night Daily Test'],
      '2022-11-03 00:00' => ['Late Night Daily Test'],
      '2022-11-03 01:00' => ['Late Night Daily Test'],
      '2022-11-03 01:59' => ['Late Night Daily Test'],
      '2022-11-03 02:00' => [],
    }

    expected_active_days.each { |day|
      expected_active_events_at_times.each { |time, active_events|
        run_active_events_test(
          ical_file_path,
          "#{day} #{time}",
          'Europe/London',
          active_events
        )
      }
    }

    (expected_inactive_days + expected_deleted_days).each { |day|
      expected_active_events_at_times.each { |time, _|
        run_active_events_test(
          ical_file_path,
          "#{day} #{time}",
          'Europe/London',
          []
        )
      }
    }

    expected_active_events_at_specific_datetimes.each { |datetime, active_events|
      run_active_events_test(
        ical_file_path,
        datetime,
        'Europe/London',
        active_events
      )
    }
  end
end
