#!/bin/ruby

require "csv"
require "optparse"
require "getoptlong"
require "byebug"

hourPerWeekLimit = 40
startingHour ||= 9
endingHour ||= 17
weekNumberParam = "%U"

opts = GetoptLong.new(
  ["--help", "-h", GetoptLong::NO_ARGUMENT],
  ["--workingDir", "-w", GetoptLong::REQUIRED_ARGUMENT],
  ["--file", "-f", GetoptLong::REQUIRED_ARGUMENT],
  ["--tasksOnly", "-t", GetoptLong::NO_ARGUMENT],
)

workingDir = nil
inputFile = nil
tasksOnly = false

usageStr = "Usage: #{__FILE__} [--help|-h] [[--workingDir|-w] | [--file | -f ]] [--tasksOnly|-t]"

opts.each do |opt, arg|
  case opt
  when "--help", "-h"
    puts usageStr
    exit 0
  when "--workingDir", "-w"
    workingDir = arg
  when "--file", "-f"
    inputFile = arg
  when "--tasksOnly", "-t"
    tasksOnly = true
  else
    $stderr.puts usageStr
    exit 1
  end
end

#Determine the latest csv file if arg1 is not specified

if workingDir.nil? and inputFile.nil?
  if not ARGV[1].nil? and not ARGV[1].empty?
    inputFile = ARGV[1]
  else
    puts "No directory or input file specified"
    puts "Will use #{Dir.pwd}"
    workingDir = Dir.pwd
  end
end

if inputFile.nil?
  inputFile = Dir.glob(workingDir + "/*.csv").max_by { |file_path| File.mtime(file_path) }
end

if inputFile
  inputFile = File.expand_path(inputFile)
else
  raise "Variable inputFile is null"
end

if not File.exist?(inputFile)
  $stderr.puts "Input file #{inputFile} does not exist"
  exit 1
else
  puts "Using #{inputFile}"
end

puts

hoursByDate = Hash.new(0)
workingHoursByDate = Hash.new(0)
workingHoursByWeek = Hash.new(0)
descriptionByDate = Hash.new({ maxHours: 0, description: "" })

def detect_encoding(file_path)
  # Try reading a line with different encodings
  encodings_to_try = [
    'bom|utf-8',
    'utf-8',
    'ISO-8859-1:UTF-8',
    'Windows-1252:UTF-8'
  ]

  encodings_to_try.each do |enc|
    begin
      File.open(file_path, 'r', encoding: enc) do |f|
        # Force read and encode to test if it works
        line = f.readline
        line.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      end
      return enc
    rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError, ArgumentError
      next
    end
  end

  # Last resort fallback
  'ISO-8859-1:UTF-8'
end

def detect_separator(file_path, encoding)
  File.open(file_path, 'r', encoding: encoding) do |f|
    first_line = f.readline
    # Force encoding conversion to handle any remaining issues
    first_line = first_line.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    [',', ';', '|', "\t"].max_by { |delim| first_line.count(delim) }
  end
end

# Then use them before CSV.foreach:
encoding = detect_encoding(inputFile)
puts "Detected encoding: #{encoding}"

separator = detect_separator(inputFile, encoding)
puts "Detected separator: #{separator.inspect}"
puts


# Read the entire file with encoding handling, then parse with CSV
file_content = File.read(inputFile, encoding: encoding)
  .encode('UTF-8', invalid: :replace, undef: :replace, replace: '')

CSV.parse(file_content, headers: true, col_sep: separator) { |row|
  headers = row.to_h.keys
  lang = if headers.include?("Heures")
      :fr
    elsif headers.include?("Hours")
      :en
    else
      raise "I don't know what language this is. Headers were #{headers.join(", ")}"
    end

  dateHeader, hoursHeader, commentHeader = case lang
    when :fr
      %w(Date Heures Commentaire)
    when :en
      %w(Date Hours Comment)
    else
      raise "Language #{lang.to_s} unknown"
    end

  date = Date.parse(row[dateHeader])

  hoursStr = row[hoursHeader]

  hoursStr.gsub!(",", ".") if lang == :fr

  hours = hoursStr.to_f

  comment = row[commentHeader]

  if (descriptionByDate[date].nil? or (hours > descriptionByDate[date][:maxHours]))
    descriptionByDate[date] = { maxHours: hours, description: comment }
  end

  weekNumber = date.strftime(weekNumberParam).to_i + 1

  hoursByDate[date] += hours
  workingHoursByWeek[weekNumber] += hours
}

totalHours = 0
lastWeekNum = -1
lastDate = nil

missingDates = (hoursByDate.keys.min..hoursByDate.keys.max).to_a - hoursByDate.keys

hoursByDate.merge!(missingDates.map { |d| [d, 0] }.to_h)

allInfo = !tasksOnly

hoursByDate.sort_by { |date, hours| date }.each { |date, hours|
  totalHours += hours

  weekNum = date.strftime(weekNumberParam).to_i
  if lastWeekNum != weekNum and allInfo
    puts
    lastWeekNum = weekNum
  end

  comment = descriptionByDate[date][:description].gsub(/\(.*\)/, "").strip

  if allInfo
    puts "#{date.strftime("%a %Y-%m-%d")}\t\t#{hours != 0 ? hours.round(2) : "-"}\t\t#{comment}"
  else
    puts comment.strip
  end

  lastDate = date
}

puts if allInfo
puts "=== Hours per week =====================" if allInfo
workingHoursByWeek.each { |weekNum, hours|
  dateStr = sprintf("%dW%02d", Date.today.year, weekNum)
  dateStr = Date.parse(dateStr).strftime("%Y-%m-%d")
  hoursStr = hours.round(2)
  print "#{dateStr}\t\t#{hoursStr}"
  puts ((hours > hourPerWeekLimit) ? " <--- WARNING: more than #{hourPerWeekLimit} hours" : "")
}

puts "Total hours:\t\t#{totalHours.round(2)}" if allInfo

puts "\nDone #{DateTime.now}"

#Open the csv file for reading

#Have two hashes:
#- One for total time per day
#- One for total time between 9 and 5, choping off bits that "spill over" 9 and 5 pm.  Tu devras avoir des booléan #crossesStart et crossesEnd
