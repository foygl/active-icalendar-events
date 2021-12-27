require './lib/active-icalendar-events.rb'

describe ActiveIcalendarEvents do
  it "does a thing" do
    zone = ActiveSupport::TimeZone.new('Europe/London')
    datetime = zone.parse('2022-03-16 10:00').to_datetime

    ical_data = File.open('./spec/ical_files/google_calendar_uk_weekly_1000_to_1300_mwfs_25_instances.ics', 'r') { |ical_file|
      Icalendar::Calendar.parse(ical_file)
    }

    active_events = ActiveIcalendarEvents::all_active_events(
      datetime,
      ical_data
    )

    expect(active_events).to eq(['Weekly Test'])
  end
end
