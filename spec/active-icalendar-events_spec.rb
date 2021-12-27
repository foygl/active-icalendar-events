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

  it "check monthly" do
    ical_file_path = './spec/ical_files/google_calendar_uk_monthly.ics'

    expected_active_events_at_specific_datetimes = {
      '2022-01-11 09:59' => [],
      '2022-01-11 10:00' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-01-11 12:59' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-01-11 13:00' => [],

      '2022-01-14 23:59' => [],
      '2022-01-15 00:00' => ['Monthly Test (15th day, bimonthly)'],
      '2022-01-15 12:00' => ['Monthly Test (15th day, bimonthly)'],
      '2022-01-15 23:59' => ['Monthly Test (15th day, bimonthly)'],
      '2022-01-16 00:00' => [],

      '2022-01-20 09:59' => [],
      '2022-01-20 10:00' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-01-20 12:59' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-01-20 13:00' => [],

      '2022-02-08 09:59' => [],
      '2022-02-08 10:00' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-02-08 12:59' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-02-08 13:00' => [],

      '2022-02-14 23:59' => [],
      '2022-02-15 00:00' => [],
      '2022-02-15 12:00' => [],
      '2022-02-15 23:59' => [],
      '2022-02-16 00:00' => [],

      '2022-02-17 09:59' => [],
      '2022-02-17 10:00' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-02-17 12:59' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-02-17 13:00' => [],

      '2022-03-08 09:59' => [],
      '2022-03-08 10:00' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-03-08 12:59' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-03-08 13:00' => [],

      '2022-03-14 23:59' => [],
      '2022-03-15 00:00' => ['Monthly Test (15th day, bimonthly)'],
      '2022-03-15 12:00' => ['Monthly Test (15th day, bimonthly)'],
      '2022-03-15 23:59' => ['Monthly Test (15th day, bimonthly)'],
      '2022-03-16 00:00' => [],

      '2022-03-17 09:59' => [],
      '2022-03-17 10:00' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-03-17 12:59' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-03-17 13:00' => [],

      '2022-04-12 09:59' => [],
      '2022-04-12 10:00' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-04-12 12:59' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-04-12 13:00' => [],

      '2022-04-14 23:59' => [],
      '2022-04-15 00:00' => [],
      '2022-04-15 12:00' => [],
      '2022-04-15 23:59' => [],
      '2022-04-16 00:00' => [],

      '2022-04-21 09:59' => [],
      '2022-04-21 10:00' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-04-21 12:59' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-04-21 13:00' => [],

      '2022-05-10 09:59' => [],
      '2022-05-10 10:00' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-05-10 12:59' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-05-10 13:00' => [],

      '2022-05-14 23:59' => [],
      '2022-05-15 00:00' => ['Monthly Test (15th day, bimonthly)'],
      '2022-05-15 12:00' => ['Monthly Test (15th day, bimonthly)'],
      '2022-05-15 23:59' => ['Monthly Test (15th day, bimonthly)'],
      '2022-05-16 00:00' => [],

      '2022-05-19 09:59' => [],
      '2022-05-19 10:00' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-05-19 12:59' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-05-19 13:00' => [],

      '2022-06-14 09:59' => [],
      '2022-06-14 10:00' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-06-14 12:59' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-06-14 13:00' => [],

      '2022-06-14 23:59' => [],
      '2022-06-15 00:00' => [],
      '2022-06-15 12:00' => [],
      '2022-06-15 23:59' => [],
      '2022-06-16 00:00' => [],

      '2022-06-16 09:59' => [],
      '2022-06-16 10:00' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-06-16 12:59' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-06-16 13:00' => [],

      '2022-07-12 09:59' => [],
      '2022-07-12 10:00' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-07-12 12:59' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-07-12 13:00' => [],

      '2022-07-14 23:59' => [],
      '2022-07-15 00:00' => ['Monthly Test (15th day, bimonthly)'],
      '2022-07-15 12:00' => ['Monthly Test (15th day, bimonthly)'],
      '2022-07-15 23:59' => ['Monthly Test (15th day, bimonthly)'],
      '2022-07-16 00:00' => [],

      '2022-07-21 09:59' => [],
      '2022-07-21 10:00' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-07-21 12:59' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-07-21 13:00' => [],

      '2022-08-09 09:59' => [],
      '2022-08-09 10:00' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-08-09 12:59' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-08-09 13:00' => [],

      '2022-08-14 23:59' => [],
      '2022-08-15 00:00' => [],
      '2022-08-15 12:00' => [],
      '2022-08-15 23:59' => [],
      '2022-08-16 00:00' => [],

      '2022-08-18 09:59' => [],
      '2022-08-18 10:00' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-08-18 12:59' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-08-18 13:00' => [],

      '2022-09-13 09:59' => [],
      '2022-09-13 10:00' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-09-13 12:59' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-09-13 13:00' => [],

      '2022-09-14 23:59' => [],
      '2022-09-15 00:00' => ['Monthly Test (15th day, bimonthly)'],
      '2022-09-15 09:59' => ['Monthly Test (15th day, bimonthly)'],
      '2022-09-15 10:00' => ['Monthly Test (15th day, bimonthly)', 'Monthly Test (3rd Thursday x 12)'],
      '2022-09-15 12:00' => ['Monthly Test (15th day, bimonthly)', 'Monthly Test (3rd Thursday x 12)'],
      '2022-09-15 12:59' => ['Monthly Test (15th day, bimonthly)', 'Monthly Test (3rd Thursday x 12)'],
      '2022-09-15 13:00' => ['Monthly Test (15th day, bimonthly)'],
      '2022-09-15 23:59' => ['Monthly Test (15th day, bimonthly)'],
      '2022-09-16 00:00' => [],


      '2022-10-11 09:59' => [],
      '2022-10-11 10:00' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-10-11 12:59' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-10-11 13:00' => [],

      '2022-10-14 23:59' => [],
      '2022-10-15 00:00' => [],
      '2022-10-15 12:00' => [],
      '2022-10-15 23:59' => [],
      '2022-10-16 00:00' => [],

      '2022-10-20 09:59' => [],
      '2022-10-20 10:00' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-10-20 12:59' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-10-20 13:00' => [],

      '2022-11-08 09:59' => [],
      '2022-11-08 10:00' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-11-08 12:59' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-11-08 13:00' => [],

      '2022-11-14 23:59' => [],
      '2022-11-15 00:00' => ['Monthly Test (15th day, bimonthly)'],
      '2022-11-15 12:00' => ['Monthly Test (15th day, bimonthly)'],
      '2022-11-15 23:59' => ['Monthly Test (15th day, bimonthly)'],
      '2022-11-16 00:00' => [],

      '2022-11-17 09:59' => [],
      '2022-11-17 10:00' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-11-17 12:59' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-11-17 13:00' => [],

      '2022-12-13 09:59' => [],
      '2022-12-13 10:00' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-12-13 12:59' => ['Monthly Test (2nd Tuesday until next year)'],
      '2022-12-13 13:00' => [],

      '2022-12-14 23:59' => [],
      '2022-12-15 00:00' => [],
      '2022-12-15 09:59' => [],
      '2022-12-15 10:00' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-12-15 12:00' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-12-15 12:59' => ['Monthly Test (3rd Thursday x 12)'],
      '2022-12-15 13:00' => [],
      '2022-12-15 23:59' => [],
      '2022-12-16 00:00' => [],

      '2023-01-10 09:59' => [],
      '2023-01-10 10:00' => [],
      '2023-01-10 12:59' => [],
      '2023-01-10 13:00' => [],

      '2023-01-19 09:59' => [],
      '2023-01-19 10:00' => [],
      '2023-01-19 12:59' => [],
      '2023-01-19 13:00' => [],

      '2023-01-14 23:59' => [],
      '2023-01-15 00:00' => ['Monthly Test (15th day, bimonthly)'],
      '2023-01-15 12:00' => ['Monthly Test (15th day, bimonthly)'],
      '2023-01-15 23:59' => ['Monthly Test (15th day, bimonthly)'],
      '2023-01-16 00:00' => [],
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

  it "check yearly" do
    ical_file_path = './spec/ical_files/google_calendar_uk_yearly.ics'

    expected_active_events_at_specific_datetimes = {
      '2021-01-11 23:59' => [],
      '2021-01-12 00:00' => [],
      '2021-01-12 23:59' => [],
      '2021-01-13 00:00' => [],

      '2022-01-11 23:59' => [],
      '2022-01-12 00:00' => ['Yearly Event'],
      '2022-01-12 23:59' => ['Yearly Event'],
      '2022-01-13 00:00' => [],

      '2023-01-11 23:59' => [],
      '2023-01-12 00:00' => ['Yearly Event'],
      '2023-01-12 23:59' => ['Yearly Event'],
      '2023-01-13 00:00' => [],

      '2024-01-11 23:59' => [],
      '2024-01-12 00:00' => ['Yearly Event'],
      '2024-01-12 23:59' => ['Yearly Event'],
      '2024-01-13 00:00' => [],

      '2025-01-11 23:59' => [],
      '2025-01-12 00:00' => ['Yearly Event'],
      '2025-01-12 23:59' => ['Yearly Event'],
      '2025-01-13 00:00' => [],

      '2026-01-11 23:59' => [],
      '2026-01-12 00:00' => ['Yearly Event'],
      '2026-01-12 23:59' => ['Yearly Event'],
      '2026-01-13 00:00' => [],

      '2027-01-11 23:59' => [],
      '2027-01-12 00:00' => [],
      '2027-01-12 23:59' => [],
      '2027-01-13 00:00' => [],
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

  it "check yearly, with moves and deletes" do
    ical_file_path = './spec/ical_files/google_calendar_uk_yearly_with_moves_and_deletes.ics'

    expected_active_events_at_specific_datetimes = {
      '2021-01-11 23:59' => [],
      '2021-01-12 00:00' => [],
      '2021-01-12 23:59' => [],
      '2021-01-13 00:00' => [],

      '2022-01-10 23:59' => [],
      '2022-01-11 00:00' => ['Yearly Event'], # Moved back a day
      '2022-01-11 23:59' => ['Yearly Event'],
      '2022-01-12 00:00' => [],
      '2022-01-12 23:59' => [],

      '2023-01-11 23:59' => [],
      '2023-01-12 00:00' => ['Yearly Event'],
      '2023-01-12 23:59' => ['Yearly Event'],
      '2023-01-13 00:00' => [],

      '2024-01-11 23:59' => [],
      '2024-01-12 00:00' => [], # Deleted
      '2024-01-12 23:59' => [],
      '2024-01-13 00:00' => [],

      '2025-01-11 23:59' => [],
      '2025-01-12 00:00' => [], # Moved to a 10 - 10:30 event
      '2025-01-12 09:59' => [],
      '2025-01-12 10:00' => ['Yearly Event'],
      '2025-01-12 10:29' => ['Yearly Event'],
      '2025-01-12 10:30' => [],
      '2025-01-12 23:59' => [],
      '2025-01-13 00:00' => [],

      '2026-01-11 23:59' => [],
      '2026-01-12 00:00' => ['Yearly Event'],
      '2026-01-12 23:59' => ['Yearly Event'],
      '2026-01-13 00:00' => [],

      '2027-01-11 23:59' => [],
      '2027-01-12 00:00' => [],
      '2027-01-12 23:59' => [],
      '2027-01-13 00:00' => [],
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
