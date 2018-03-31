# Abandonned, realized I'm probably planning ahead too much
require 'csv'

filePath=ARGV[0]

CSV.open(filePath, 'rb', headers: :first_row, encoding: 'UTF-8', col_sep: "\t") do |csv|
    currentModel = ''
    csv.each do |row|
        if row['model'] != currentModel
            railsGstr =
    end
end
