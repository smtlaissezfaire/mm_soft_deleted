require 'date'

Gem::Specification.new do |s|
  s.name        = 'mm_soft_deleted'
  s.version     = '0.0.4'
  s.date        = Date.today.to_s
  s.summary     = "Soft delete records with mongo mapper"
  s.description = "Soft delete records with mongo mapper"
  s.authors     = [
    "Scott Taylor",
  ]
  s.email       = 'scott@railsnewbie.com'
  s.files       = Dir.glob("lib/**/**.rb")
  s.homepage    =
    'http://github.com/GoLearnUp/mm_soft_deleted'
  s.license       = 'MIT'
end
