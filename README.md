# Active icalendar events

Get all events that are active at a timestamp for an icalendar file.

This has been manual tested only with Google Calendar and seems to work for all the cases I can think of.

Possible future work:
- [ ] Write some tests.
- [ ] Check it works for calendars that don't start on Monday.
- [ ] Check it works for calendars that are not Google Calendar.
- [ ] Validation of data/parameters.
- [ ] Clean up module interface (currently just exposing all methods with module_function)
- [ ] Specify timezone rather than assuming that server this is run on is in the same timezone as the calendar.

## Example Usage

```ruby
require 'active-icalendar-events'
require 'active_support'
require 'active_support/core_ext'
require 'open-uri'

ICAL_URL = ENV['ICAL_URL']

ical_data = URI::open(ICAL_URL)

datetime = ActiveSupport::TimeZone.new('Europe/London').now.to_datetime

active_events = ActiveIcalendarEvents::all_active_events(DateTime.now, Icalendar::Calendar.parse(ical_data))
```

## Run Tests

```bash
bundle exec rspec
```
