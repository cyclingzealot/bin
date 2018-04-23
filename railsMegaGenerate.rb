require 'csv'
require 'byebug'
require 'optparse'
require 'facets'


params = ARGV.getopts("dha", "addColumns", "noSnakeCase", "file:", "help", "debug")
params.symbolize_keys!

def headersRequired()
    ["model", "attribute", "datatype", "unique", "default"]
end

# Show help if requested or the file parameter is not specified
if params.slice(:h, :help).select{|k,v| v}.count > 0 or params.slice(:file, :f).reject{|k,v| v.nil?}.count == 0
    puts "Usage: -f $filePath [-a[ddColumns] [-noSnakeCase]] [-d[ebug]]"
    puts "Your csv file must have the headers:\n\t#{headersRequired().join("\t")}"
    puts "For references, as long as your attribute name is singular, it should work and will ouput \$attributeName:references, which in turn will generate t.references and add_index (AFAIK).  See https://railsguides.net/advanced-rails-model-generators/"
    puts "Attributes starting with # will be skipped"
    exit 1
end

filePath=params[:file] or params[:f]

def detectSeperator(filePath)
    firstLine = File.open(filePath, &:readline)
    [',', ":", ";", "\t"].max_by{|s| firstLine.split(s).count}
end


def checkHeaders(csvFileObj, headersToRequired)
    headersRequired.all?{|hr|csvFileObj.first.headers.include?(hr)}
    csvFileObj.rewind
end

def checkDataType(dataTypeStr)
    allowedDataTypes().include?(dataTypeStr)
end

def allowedDataTypes()
    [:primary_key, :string, :text, :integer, :bigint, :float, :decimal, :numeric, :datetime, :time, :date, :binary, :boolean, :references].map{|v| v.to_s}
end



if not File.exists?(filePath)
    $stderr.puts "No file at #{filePath}"
    exit 1
end

notNull=[]
default={}
sep=detectSeperator(filePath)
line_count = File.readlines(filePath).size
CSV.open(filePath, 'r', headers: :first_row, encoding: 'UTF-8', col_sep: sep) do |csv|
    if not checkHeaders(csv, headersRequired())
        raise "Not all required headers (#{headersRequired()}) in #{csv.first.headers}"
    end

    currentModel = ''
    railsGstr = ''
    linenum = 0
    csv.read.each do |row|
        linenum += 1
        #next if (row['model'].nil? or row['model'].empty?)

        attributeName = row['attribute'].strip
        attributeName = attributeName.snakecase unless params[:noSnakeCase]
        next if attributeName.starts_with?('#')

        if (params[:d] or params[:debug])
            puts "#{linenum}/#{line_count} #{railsGstr}"
        end


        if (not row['model'].nil?) and (not row['model'].empty?) and row['model'] != currentModel

            # Publish the current railsGstr
            puts railsGstr if railsGstr != ''

            # And now determine the next one
            currentModel = row['model']

            if params[:addColumns] or params[:a]
                generateType = 'migration'
                migrationName = "AddColumnsTo#{currentModel}"
            else
                generateType = 'model'
                migrationName = currentModel
            end

            railsGstr = "rails g #{generateType} #{migrationName} "
        end


        dataType = row['datatype']
        raise "#{dataType} not among allowed data types (#{allowedDataTypes()})" if not checkDataType(dataType)

        railsGstr += attributeName + ':' + dataType

        if not row['unique'].nil? and ['VRAI', 'TRUE'].map(&:downcase).include?(row['unique'].downcase)
            railsGstr += ':uniq'
        end

        railsGstr += ' '

        if linenum == line_count-1
            puts railsGstr
        end


    end
end



#(notNull + default.keys).uniq

