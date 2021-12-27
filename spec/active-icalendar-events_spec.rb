require './lib/active-icalendar-events.rb'

describe ActiveIcalendarEvents do
  it "does a thing" do
    File.open('ical_files/google_calendar_uk_weekly_1000_to_1300_mwfs_25_instances.ics', 'r') { |ical_file|
      zone = ActiveSupport::TimeZone.new('Europe/London')
      datetime = zone.parse('2022-03-16 10:00')

      ical_data = Icalendar::Calendar.parse(ical_file)

      active_events = ActiveIcalendarEvents::all_active_events(
        datetime,
        Icalendar::Calendar.parse(ical_data)
      )
    }

    #expect(calculator.factorial_of(5)).to eq(120)
  end
end
