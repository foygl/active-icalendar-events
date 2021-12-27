# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'active-icalendar-events'
  s.version     = '0.2.0'
  s.summary     = 'Get all events active at a timestamp for an icalendar file'
  s.authors     = ['William Starling']
  s.email       = 'w.starling+icalendar@gmail.com'
  s.files       = ['lib/active_icalendar_events.rb']
  s.homepage    = 'https://github.com/foygl/active-icalendar-events'
  s.license     = 'MIT'

  s.add_runtime_dependency 'activesupport', '~> 6.1'
  s.add_runtime_dependency 'icalendar', '~> 2.7'
end
