require 'tempfile'
require 'securerandom'

def ask(question, new_lines_to_stop = 3)
  puts "#{question}\n"
  new_lines_count = 0
  result = ""
  while new_lines_count < new_lines_to_stop do
    line = STDIN.readline
    result << line
    if line == "\n"
      new_lines_count += 1
    else
      new_lines_count = 0
    end
  end
  result.strip
end

def run_test
  puts "WARNING!: Implement run_test function"
  true
end

test_run = false
unless ENV['SKIP_TEST']
  test_run = true
  test_passed = run_test
end

if test_run && !test_passed
  puts "Cannot pull request if test are failing!"
  exit(1)
end

title = ask("title:", 1)
card_url = ask("trello card url:", 1)
summary = ask("summary:")
test_plan = ask("test plan:")
known_issues = ask("known issues:")

if card_url == ""
  puts "ERROR: Trello card URL cannot be empty"
  exit(1)
end

markdown = <<-eos
#{title}


##Sumary##
**Trello card**: #{card_url}
**Local test passed**: #{test_run ? "YES" : "NO"}
**Local test passed**: #{test_passed ? "YES" : "NO"}

#{summary}

##Test Plan##

#{test_plan}

##Screenshots##

Drag and drop screen shots

##Known issues##

#{known_issues}
eos

file_path = "/tmp/wlx-pull-request-#{SecureRandom.base64}"
File.open(file_path, 'w') do |f|
  f.write(markdown)
end

command = "hub pull-request -F #{file_path} -o"
puts ""
puts "Pull request title and description '#{file_path}'"
puts "You can pull request by executing '#{command}'"
`#{command}` unless ENV['DRY_RUN']
