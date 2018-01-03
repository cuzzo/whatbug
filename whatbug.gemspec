Gem::Specification.new do |s|
  s.name = "whatbug"
  s.version = "0.0.2"
  s.date = "2017-01-03"
  s.summary = "Find the source of the bug with WhatBug"
  s.description = "WhatBug helps you find where a bug was introduced faster by finding all lines of code in the relevant functions of a stack trace and identifying which of those have changed within a timeframe."
  s.authors = ["Brian Yahn"]
  s.email = "yahn007@outlook.com"
  s.executables << "whatbug"

  s.add_runtime_dependency "dotenv", "~> 2.1", ">= 2.1.1"
  s.add_runtime_dependency "github-linguist", "~> 5.3", ">= 5.3.2"

  s.files = ["lib/airbrake_client.rb", "lib/c_syntax_tracer.rb", "lib/git_client.rb", "lib/python_tracer.rb", "lib/rollbar_client.rb", "lib/ruby_tracer.rb", "lib/tracer.rb"]
  s.homepage = "https://github.com/cuzzo/whatbug"
  s.license = "BSD-2-Clause"
end
