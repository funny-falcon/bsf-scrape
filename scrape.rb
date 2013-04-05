#!/usr/bin/ruby
require 'timeout'
require 'open-uri'
require 'nokogiri'
require 'csv'
require 'pg'

#############################
# STRUCTURE OF THIS SCRIPT:
# 1.  Create global variables
# 2.  Create classes
# 3.  Create functions
# 4.  Define main function
# 5.  Execute main function
#############################

##############################
# CREATE GLOBAL VARIABLES HERE
##############################
# Assume that we wish to run the long version
$exec_long = true

# Assume this is the development environment
$username = ''
$is_devel = true
$dir_home = ''
$dir_scrape = ''
$dir_db = ''
$dir_input = ''
$dir_downloads = ''
$dir_output = ''

# Maximum length of string fields in database
$len_symbol = 0
$len_name = 0
$len_type = 0
$len_obj = 0
$len_cat = 0
$len_family = 0
$len_stylebox = 0

# Array of funds
$arrayFund = []

# Number of funds
$num_funds_total = 0

# Postgres database information
$db_name = ''
$db_user = ''
$db_password = ''

#####################
# CREATE CLASSES HERE
#####################
# Define class Fund
class Fund
  @population = 0
  def initialize (symbol)
    @symbol = symbol
  end
  
  def get_symbol
    @symbol
  end
  
  def get_name
    @name
  end
  def set_name name
    @name = name
  end
  
  def get_type
    @type
  end
  def set_type type
    @type = type
  end
  
  def get_obj
    @obj
  end
  def set_obj obj
    @obj = obj
  end

  def get_cat
    @cat
  end
  def set_cat cat
    @cat = cat
  end
  
  def get_family
    @family
  end
  def set_family family
    @family = family
  end  

  def get_assets
    @assets
  end
  def set_assets assets
    @assets = assets
  end  

  def get_stylebox
    @stylebox
  end
  def set_stylebox stylebox
    @stylebox = stylebox
  end  

  def get_mininv
    @mininv
  end
  def set_mininv mininv
    @mininv = mininv
  end
  
  def get_turnover
    @turnover
  end
  def set_turnover turnover
    @turnover = turnover
  end
  
  def get_exp
    @exp
  end
  def set_exp exp
    @exp = exp
  end
  
  def get_load_front
    @load_front
  end
  def set_load_front load_front
    @load_front = load_front
  end

  def get_load_back
    @load_back
  end
  def set_load_back load_back
    @load_back = load_back
  end

  def get_biggest
    @biggest
  end
  def set_biggest biggest
    @biggest = biggest
  end

  def get_price
    @price
  end
  def set_price price
    @price = price
  end

  def get_pb
    @pb
  end
  def set_pb pb
    @pb = pb
  end

  def get_pe
    @pe
  end
  def set_pe pe
    @pe = pe
  end

  def get_ps
    @ps
  end
  def set_ps ps
    @ps = ps
  end

  def get_pcf
    @pcf
  end
  def set_pcf pcf
    @pcf = pcf
  end
end

# Based on the example at:
# http://marcclifton.wordpress.com/2012/11/12/an-example-of-using-postgresql-with-ruby/
class FundDatabase 
  # Create the connection instance.
  def connect
    @conn = PG.connect(
        :dbname => $db_name,
        :user => $db_user,
        :password => $db_password)
  end
  
  # Disconnect the back-end connection.
  def disconnect
    @conn.close
  end
 
  # Create our table of fund data
  def createFundTable
    command_create = ''
    command_create += 'CREATE TABLE funds_new ( '
    command_create += 'index int, '
    command_create += 'symbol varchar(' + $len_symbol.to_s() + '), '
    command_create += 'name varchar(' + $len_name.to_s() + '), '
    command_create += 'type varchar(' + $len_type.to_s() + ' ), '
    command_create += 'objective varchar(' + $len_obj.to_s() + '),	'
    command_create += 'category varchar(100),	'
    command_create += 'family varchar(100),	'
    command_create += 'style_size varchar(6),	'
    command_create += 'style_value varchar(6),	'
    command_create += 'price float,	'
    command_create += 'pcf float,	'
    command_create += 'pb float,	'
    command_create += 'pe float,	'
    command_create += 'ps float,	'
    command_create += 'expense_ratio float,	'
    command_create += 'load_front float,	'
    command_create += 'load_back float,	'
    command_create += 'min_inv int,	'
    command_create += 'turnover varchar (6),	'
    command_create += 'biggest_position float,	'
    command_create += 'assets varchar(10),	'
    command_create += 'PRIMARY KEY (symbol)	'
    command_create += ');'
    @conn.exec(command_create);
  end
  
  # Update our table of fund data
  def updateFund (array_details)
    # array_details = [symbol, category, family, style_size, style_value, 
    # price, pcf, pb, pe, ps, expense_ratio, load_front, load_back, 
    # min_inv, turnover, biggest_position, assets]
    # NOTE: All inputs must be strings.
    symbol = array_details [0]
    category = array_details [1]
    family = array_details [2]
    style_size = array_details [3]
    style_value = array_details [4]
    price = array_details [5]
    pcf = array_details [6]
    pb = array_details [7]
    pe = array_details [8]
    ps = array_details [9]
    expense_ratio = array_details [10]
    load_front = array_details [11]
    load_back = array_details [12]
    min_inv = array_details [13]
    turnover = array_details [14]
    biggest_position = array_details [15]
    assets = array_details [16]
    
    command_create = ""
    #command_create += 'UPDATE funds_new WHERE symbol=' 
    #command_create += symbol + ' '
    command_create += "UPDATE funds_new "
    command_create += "SET category='" + category + "',"
    command_create += "family='" + family + "',"
    command_create += "style_size='" + style_size + "',"
    command_create += "style_value='" + style_value + "',"
    command_create += "price=" + price + ","
    command_create += "pcf=" + pcf + ","
    command_create += "pb=" + pb + ","
    command_create += "pe=" + pe + ","
    command_create += "ps=" + ps + ","
    command_create += "expense_ratio=" + expense_ratio + ","
    command_create += "load_front=" + load_front + ","
    command_create += "load_back=" + load_back + ","
    command_create += "min_inv=" + min_inv + ","
    command_create += "turnover=" + turnover + ","
    command_create += "biggest_position=" + biggest_position + ","
    command_create += "assets='" + assets + "' "
    command_create += "WHERE symbol='" + symbol + "'"
    command_create += ";"
    @conn.exec(command_create);
  end
  
  # Drop our table of fund data
  def dropFundTable
    @conn.exec("DROP TABLE funds_new")
  end
  
  def copyFundTable
    str1 = "DROP TABLE funds"
    str2 = "CREATE TABLE funds AS SELECT * FROM funds_new"
    begin
      @conn.exec(str2)
    rescue
      @conn.exec(str1)
      @conn.exec(str2)
    end
    
  end
  
  # Prepared statements prevent SQL injection attacks.  However, for the connection, the prepared statements
  # live and apparently cannot be removed, at least not very easily.  There is apparently a significant
  # performance improvement using prepared statements.
  def prepareInsertFundStatement
    str1 = "insert_fund"
    str2 = "insert into funds_new (Index, Symbol, Name, Type, Objective) values ($1, $2, $3, $4, $5)"
    @conn.prepare(str1, str2)
  end
  
  # Add a user with the prepared statement.
  def addFund(index, symbol, name, type, obj)
    @conn.exec_prepared("insert_fund", [index, symbol, name, type, obj])
  end
  
  # Get index from table
  def scrollSymbolsFromTable
    str1 = "SELECT symbol FROM funds_new"
    @conn.exec(str1) do |result|
      result.each do |row|
        yield row if block_given?
      end
    end
  end
  
  # Print to CSV file
  def printCSV (filename_short)
    csv_path = '/var/lib/postgresql/8.4/main/' + filename_short
    puts 'Copying the database to: '
    puts csv_path
    @conn.exec ("COPY funds_new TO '" + csv_path + "' With CSV HEADER;")
  end
  
  # Print to CSV file
  def printCSVmain (filename_short)
    csv_path = '/var/lib/postgresql/8.4/main/' + filename_short
    puts 'Copying the database to: '
    puts csv_path
    @conn.exec ("COPY funds TO '" + csv_path + "' With CSV HEADER;")
  end
  
end


#############################################################
# START WITH A DELAY OF RANDOM LENGTH OR UNTIL KEY IS PRESSED
# WHICHEVER COMES FIRST
#############################################################

def delay
  delay_min = rand * 30
  delay_sec = delay_min * 60
  puts
  puts 'DELAY MODE'
  puts 'This script will continue after ' + delay_min.to_s() + ' minutes'
  puts 'or when you press any key, WHICHEVER COMES FIRST.'
  begin
    timeout(delay_sec) do
      begin
        system("stty raw -echo")
        str = STDIN.getc
      ensure
        system("stty -raw echo")
      end
    puts 'Delay mode terminated by user'
    end
  rescue Timeout::Error
    puts 'Delay mode terminated by script'
  end
end

##############################################################
# Long version or short version of script?
# Get user input
# Short version is needed for quick results during development
##############################################################
def select_length
  puts
  puts 'Press any key within 5 seconds to run the short version of this script.'
  puts 'Otherwise, the long version of this script will run.'
  begin
    timeout(5) do
      begin
        system("stty raw -echo")
        str = STDIN.getc
      ensure
        system("stty -raw echo")
      end
      $exec_long = false
      puts
      puts "EXECUTING THE SHORT VERSION OF THIS SCRIPT" 
    end
  rescue Timeout::Error
    puts "EXECUTING THE LONG VERSION OF THIS SCRIPT"
  end
end

# Put contents of file into string
def string_from_file (filename)
  str_output = ''
  f = File.open(filename, "r")
  f.each_line do |line|
    str_output += line
  end
  # The newline at the end of the file MUST be removed when
  # acquiring the username and password.
  str_output = str_output.gsub("\n", "")
  return str_output
end

########################################
# Development or production environment?
########################################
def get_env
  require 'etc'
  username = Etc.getlogin
  $dir_home = '/home/' + username
  $dir_scrape = $dir_home + '/bsf-scrape'
  $is_devel = Dir.exists? $dir_scrape
  $username = username
  if ($is_devel == true)
    puts
    puts 'Environment: DEVELOPMENT'

  else
    $dir_scrape = '/home/doppler/webapps'
    $dir_scrape += '/bsf_scrape/bsf-scrape'
    puts
    puts 'Environment: PRODUCTION'
  end
end

# Create a directory if it doesn't already exist
def create_dir (dir_name)
  Dir.mkdir(dir_name) unless Dir.exists?(dir_name)
end

#######################################################################
# CREATE THE DIRECTORIES CONTAINING THE LISTS OF FUND NAMES, FUND DATA,
# AND OUTPUT DATA 
#######################################################################
def create_dir_all
  $dir_input = $dir_scrape + '/input'
  $dir_downloads = $dir_scrape + '/downloads'
  $dir_output = $dir_scrape + '/output'
  $dir_db = $dir_scrape + '/db'
  create_dir $dir_input 
  create_dir $dir_downloads
  create_dir $dir_output
end

def get_db_params
  $db_name = 'pg_bsf' # Both development and production environments
  if ($is_devel == true)
    $db_user = $username
    $db_password = '' # Password not needed in development environment
  else
    file_username = $dir_db + '/.username.txt'
    $db_user = string_from_file file_username
    file_password = $dir_db + '/.password.txt'
    $db_password = string_from_file file_password
  end
end

# Get the age of a given file (in hours)
# If the file is not found, assume it is 1 billion hours old.
def age_of_file (file1) # In hours
  begin
    age_seconds = Time.now - File.mtime(file1) # Calculate age of file in seconds
    age_hours = age_seconds/3600
    return age_hours
  rescue
    return 1000000000
  end
end

# Download a file from a URL if the file is over a certain age
def download_file (url1, file1, file_age_max_hours)
  file_age = age_of_file file1 # Get age of file
  # Get size of file (0 if it does not exist)
  file_size = 0
  begin
    file_size = File.stat(file1).size
  rescue
    file_size = 0
  end
  # Number of failures to download file
  n_fail = 0
  n_fail_max = 4
  # Skip download if the file exists and is newer than a given age
  if (file_age <= file_age_max_hours && file_size > 0) 
    # puts "File is new enough, skipping download"
  else # Perform download until effort succeeds once or fails too many times
    while ((file_age > file_age_max_hours || file_size == 0) && (n_fail <= n_fail_max))
      begin
        # Provide a random delay of .1 to .2 seconds to limit the impact
        # on the upstream server
        t_delay = (1+rand)/10
        sleep (t_delay) 
        open(file1, 'w') do |fo|
          fo.print open(url1).read
        end
        file_size = File.stat(file1).size # Bypassed if download fails
        file_age = age_of_file file1 # Bypassed if download fails
      rescue
        n_fail += 1
        puts ("Failure #" + n_fail.to_s())
        puts ("Download failed, giving up") if n_fail > n_fail_max
      end
    end
  end
end

########################################
# DOWNLOAD LISTS OF FUNDS FROM BLOOMBERG
########################################
def download_fund_lists
  url_base = 'http://www.bloomberg.com/markets/funds/country/usa'
  file_base = $dir_input
  puts
  puts "Downloading the list of funds from " 
  puts url_base
  puts "Proceeding one page at a time"
  i = 1
  i_finished = false
  file_size = 0
  while (i_finished == false)
    i_str = i.to_s()
    url = url_base # i == 1
    url = url_base + '/' + i_str unless i ==1 # i > 1
    filename = file_base + '/page' + i_str + '.html'
    download_file url, filename, 20
    # Files containing data have ':US' in them (symbol column).  Blank files do not.
    if File.readlines(filename).grep(/:US/).any?
      i_finished = false
      print i_str + ' '
    else
      i_finished = true
      File.delete filename
    end
    i += 1
  end
  puts
  puts 'Finished downloading the list of funds'
end

##################################################
# OBTAIN THE LIST OF FUNDS, STORE DATA IN DATABASE
##################################################
# FILES DOWNLOADED FROM BLOOMBERG
# Column 1: Name
# Column 2: Symbol
# Column 3: Type
# Column 4: Objective

# clean_array function: removes a substring from every element in an array
def clean_array (array_input, substring)
  array_output = Array.new
  array_input.each do |i|
    item = i.to_s()
    item.slice! substring
    array_output << item
  end
  return array_output
end

# Convert all array elements to strings
def array_to_s (array_input)
  array_output = Array.new
  array_input.each do |i|
    item = i.to_s()
    array_output << item
  end
  return array_output
end

# Determines if entry contains any element of array
def is_substring_in_entry (array, entry)
  output_local = false
  array.each do |i|
    i_substring = i
    output_local = true if entry.downcase.include? i_substring
  end
  return output_local
end

def fillDatabaseFundLong
  download_fund_lists # Download the list of funds from Bloomberg
    
  # Scrape the basic fund data from the downloaded Bloomberg web pages
  i = 1 # page number
  i_finished = false
  file_base = $dir_scrape + '/input'
  puts
  puts "Extracting AND filtering fund list from Bloomberg's list of funds"
  puts "Over 30,000 funds are on Bloomberg's list."
  puts "This list needs to be reduced to a more manageable size."
  puts "Because the focus of this project is stock funds, anything"
  puts "that is clearly not a plain unleveraged stock fund or is not"
  puts "diversified with respect to industry is eliminated."
  puts
  puts "Proceeding one page at a time"
  
  arrayFundLocal = Array.new
  
  obj_remove = Array.new
  obj_remove << 'alternative' << 'asset-backed securities' << 'balanced'
  obj_remove << 'commodity' << 'convertible' << 'preferred' << 'derivative'
  obj_remove << 'alloc' << 'debt' << 'short' << 'government' << 'govt'
  obj_remove << 'futures' << 'muni' << 'real estate' << 'mmkt'
  obj_remove << 'venture capital' << 'asset backed securities' << 'currency'
  obj_remove << 'market neutral' << 'flexible portfolio' << 'sector'
  
  name_remove = Array.new
  name_remove << 'bull' << 'bear' << 'fixed' << 'bond' << 'real estate'
  name_remove << 'ultrasector' << 'sector' << 'telecom' << 'infrastructure' 
  name_remove << 'hedge' << 'etn' << 'leverage' << 'short' << 'duration'
  name_remove << 'municipal' << 'futures' << 'currency' << 'mlp'
  name_remove << 'premium' << 'alternative' << 'write' << 'inverse'
  name_remove << 'risk-managed' << 'treasury' << 'treasuries'
  name_remove << '3x' << '2x'
  name_remove << 'consumer' << 'energy' << 'financials' << 'materials'
  name_remove << 'miners' << 'uranium' << 'utility'

  while i_finished == false  
    i_str = i.to_s()
    print i_str + ' '
    filename = file_base + '/page' + i_str + '.html'
    if File.exist?(filename)
    
      # There are over 30,000 funds in the Bloomberg database.  Each
      # long array greatly increases memory consumption.  An earlier
      # version of the script consumed several hundred MB.
      
      # Steps for minimizing memory consumption:
      # 1.  The results of page scrapings are converted into strings.
      # 2.  Filtering is done BEFORE the basic fund data is fed into
      #     the array of funds.  This cuts down on the number of elements
      #     in the array.
      # 3.  The array of funds is local and not global.  Before we exit
      #     the scope, the fund data is fed into a database.
      # 4.  symbol_array, name_array, type_array, and obj_array are
      #      destroyed every time the script finishes scraping the current 
      #      page.
      
      page = Nokogiri::HTML(open(filename))
      # './/td': every instance of <td>something</td>
      # './/td[contains (@*, "symbol")]': every instance of <td something="symbol"></td>
      # './/td[contains (@*, "symbol")]/text()': the something within the above <td></td>
      symbol_array = page.xpath('.//td[contains (@*, "symbol")]/text()')
      symbol_array = clean_array symbol_array, ':US' # removes ":US" from fund symbol
      symbol_array = array_to_s symbol_array
      name_array = page.xpath('.//td[contains (@*, "name")]//span/text()')
      name_array = array_to_s name_array
      # './/tr': every instance of <tr>something</tr>
      # './/tr[td[contains (@*, "name")]]': every instance of <tr><td something="name"></td></tr>
      # './/tr[td[contains (@*, "name")]]//td[3]': the 3rd '<td>something</td>'
      # within the above
    
      # NEED TO KEEP THE "<td>" and "</td>" initially and then remove them later.
      # The information for these fields is sometimes left blank, but the procedure for
      # creating arrays from xpath doesn't allow blank elements.
      type_array = page.xpath('.//tr[td[contains (@*, "name")]]//td[3]')
      type_array = clean_array type_array, '<td>'
      type_array = clean_array type_array, '</td>'
      type_array = array_to_s type_array
      
      obj_array = page.xpath('.//tr[td[contains (@*, "name")]]//td[4]')
      obj_array = clean_array obj_array, '<td>'
      obj_array = clean_array obj_array, '</td>'
      obj_array = array_to_s obj_array
      
      # Screen out funds not compatible with the mission of Bargain Stock Funds
      # Fill array with remaining funds
      n_array_last = symbol_array.length - 1
      for n in 0..n_array_last
        symbol_local = symbol_array [n]
        name_local = name_array [n]
        name_local = name_local.gsub('&amp;', '&')
        type_local = type_array [n]
        obj_local = obj_array [n]
        
        # Remove any fund that isn't an open-end fund or ETF
        type_keep = false
        if type_local == 'Open-End Fund' || type_local == 'ETF'
          type_keep = true
        end

        # Filter by objective
        # Remove any fund that is clearly anything other than 
        # an unleveraged stock fund that is diversified with respect to
        # industry/sector
        obj_keep = true
        obj_keep = false if (is_substring_in_entry obj_remove,obj_local)
        
        # Filter by name
        # Remove any fund that is clearly anything other than 
        # an unleveraged stock fund that is diversified with respect to
        # industry/sector
        name_keep = true
        name_keep = false if (is_substring_in_entry name_remove,name_local)
    
        fund_keep = type_keep && obj_keep && name_keep

        # Keep fund if and only if fund_keep is still true
        if fund_keep==true
          $len_symbol = [$len_symbol, symbol_local.length].max
          $len_name = [$len_name, name_local.length].max
          $len_type = [$len_type, type_local.length].max
          $len_obj = [$len_obj, obj_local.length].max
          fund1 = Fund.new symbol_local
          fund1.set_name name_local
          fund1.set_type type_local
          fund1.set_obj obj_local
          arrayFundLocal << fund1 # Increases memory consumption
        end
      end
    else
      i_finished = true
    end
    i += 1
  end
  puts
  puts "Finished extracting data from Bloomberg's list of funds"  
  puts "Writing fund data to database"

  # Start the database  
  fd = FundDatabase.new()
  fd.connect
  begin
    fd.dropFundTable
  rescue
  end
  fd.createFundTable
  fd.prepareInsertFundStatement
  n_funds_last = (arrayFundLocal.length) - 1
  for n in 0..n_funds_last
    # NOTE: Some of the original arrays are NOT strings.
    fund1 = arrayFundLocal [n]
    symbol_local = fund1.get_symbol
    name_local = fund1.get_name
    type_local = fund1.get_type
    obj_local = fund1.get_obj
    fd.addFund n, symbol_local, name_local, type_local, obj_local
  end
  puts "Finished writing fund data to database"
  
  fd.printCSV('fundlist.csv') if $is_devel # Export database to CSV
  fd.disconnect
   
end

def fillDatabaseFundShort
    
  # Scrape the basic fund data from the downloaded Bloomberg web pages
  puts 'Filling the database with the shortened list of funds'
  file_base = $dir_scrape + '/input'
  
  arrayFundLocal = Array.new
  
  obj_remove = Array.new
  obj_remove << 'alternative' << 'asset-backed securities' << 'balanced'
  obj_remove << 'commodity' << 'convertible' << 'preferred' << 'derivative'
  obj_remove << 'alloc' << 'debt' << 'short' << 'government' << 'govt'
  obj_remove << 'futures' << 'muni' << 'real estate' << 'mmkt'
  obj_remove << 'venture capital' << 'asset backed securities' << 'currency'
  obj_remove << 'market neutral' << 'flexible portfolio' << 'sector'
  
  name_remove = Array.new
  name_remove << 'bull' << 'bear' << 'fixed' << 'bond' << 'real estate'
  name_remove << 'ultrasector' << 'sector' << 'telecom' << 'infrastructure' 
  name_remove << 'hedge' << 'etn' << 'leverage' << 'short' << 'duration'
  name_remove << 'municipal' << 'futures' << 'currency' << 'mlp'
  name_remove << 'premium' << 'alternative' << 'write' << 'inverse'
  name_remove << 'risk-managed' << 'treasury' << 'treasuries'
  name_remove << '3x' << '2x'
  name_remove << 'consumer' << 'energy' << 'financials' << 'materials'
  name_remove << 'miners' << 'uranium' << 'utility'

  symbol_array = Array.new
  name_array = Array.new
  type_array = Array.new
  obj_array = Array.new

  symbol_array << 'NVDBX'
  name_array << 'Wells Fargo Advantage Diversified Equity Fund - B'
  type_array << 'Fund of Funds'
  obj_array << 'Blend'

  symbol_array << 'NVDBX'
  name_array << 'Wells Fargo Advantage Diversified Equity Fund - B'
  type_array << 'Fund of Funds'
  obj_array << 'Blend'

  symbol_array << 'VCAIX'
  name_array << 'Vanguard California Intermediate-Term Tax-Exempt Fund - Investor'
  type_array << 'Open-End Fund'
  obj_array << 'Muni-California'
  
  symbol_array << 'VIG'
  name_array << 'Vanguard Dividend Appreciation ETF'
  type_array << 'ETF'
  obj_array << 'Growth and Income'
  
  symbol_array << 'VDE'
  name_array << 'Vanguard Energy ETF'
  type_array << 'ETF'
  obj_array << 'Sector Fund-Energy'
  
  symbol_array << 'VFIIX'
  name_array << 'Vanguard GNMA Fund - Investor'
  type_array << 'Open-End Fund'
  obj_array << 'Asset Backed Securities'
  
  symbol_array << 'VMMXX'
  name_array << 'Vanguard Prime Money Market Fund - Investor'
  type_array << 'Open-End Fund'
  obj_array << 'Taxable First Tier-MMkt'
  
  symbol_array << 'VWNDX'
  name_array << 'Vanguard Windsor Fund - Investor'
  type_array << 'Open-End Fund'
  obj_array << 'Value'

  symbol_array << 'DFJ'
  name_array << 'WisdomTree Japan SmallCap Dividend Fund'
  type_array << 'ETF'
  obj_array << 'Country Fund-Japan'
  
  symbol_array << 'HTY'
  name_array << 'John Hancock Tax-Advantaged Global Shareholder Yield Fund'
  type_array << 'Closed-End Fund'
  obj_array << 'Growth and Income'
  
  symbol_array << '0543190D'
  name_array << 'American Realty Capital Real Estate Income Fund'
  type_array << 'Mutual Fund'
  obj_array << ''

  symbol_array << 'ADTHVX'
  name_array << 'Advisors Dis Tr 724 Global Inflation Growth Ptf Srs 2011-1'
  type_array << 'UIT'
  obj_array << ''
  
  symbol_array << 'CSVWX'
  name_array << ''
  type_array << 'Open-End Fund'
  obj_array << ''
  
  symbol_array << 'LSMBX'
  name_array << ''
  type_array << 'Open-End Fund'
  obj_array << ''

  symbol_array << 'IDHVF'
  name_array << ''
  type_array << 'Open-End Fund'
  obj_array << ''

  symbol_array << 'EWU'
  name_array << ''
  type_array << 'ETF'
  obj_array << ''

  symbol_array << 'EWVS'
  name_array << ''
  type_array << 'ETF'
  obj_array << ''

  symbol_array << 'AIA'
  name_array << ''
  type_array << 'ETF'
  obj_array << ''

  symbol_array << 'JCVWX'
  name_array << ''
  type_array << 'Open-End Fund'
  obj_array << ''

  symbol_array << 'JGYIX'
  name_array << ''
  type_array << 'Open-End Fund'
  obj_array << ''

  symbol_array << 'VICFX'
  name_array << ''
  type_array << 'Open-End Fund'
  obj_array << ''

  symbol_array << 'VEIAX'
  name_array << ''
  type_array << 'Open-End Fund'
  obj_array << ''

  symbol_array << 'A1A'
  name_array << ''
  type_array << 'ETF'
  obj_array << ''
  
  # Screen out funds not compatible with the mission of Bargain Stock Funds
  # Fill array with remaining funds
  n_array_last = symbol_array.length - 1
  for n in 0..n_array_last
    symbol_local = symbol_array [n]
    name_local = name_array [n]
    name_local = name_local.gsub('&amp;', '&')
    type_local = type_array [n]
    obj_local = obj_array [n]
        
    # Remove any fund that isn't an open-end fund or ETF
    type_keep = false
    if type_local == 'Open-End Fund' || type_local == 'ETF'
      type_keep = true
    end

    # Filter by objective
    # Remove any fund that is clearly anything other than 
    # an unleveraged stock fund that is diversified with respect to
    # industry/sector
    obj_keep = true
    obj_keep = false if (is_substring_in_entry obj_remove,obj_local)
        
    # Filter by name
    # Remove any fund that is clearly anything other than 
    # an unleveraged stock fund that is diversified with respect to
    # industry/sector
    name_keep = true
    name_keep = false if (is_substring_in_entry name_remove,name_local)
    
    fund_keep = type_keep && obj_keep && name_keep

    # Keep fund if and only if fund_keep is still true
    if fund_keep==true
      $len_symbol = [$len_symbol, symbol_local.length].max
      $len_name = [$len_name, name_local.length].max
      $len_type = [$len_type, type_local.length].max
      $len_obj = [$len_obj, obj_local.length].max
      fund1 = Fund.new symbol_local
      fund1.set_name name_local
      fund1.set_type type_local
      fund1.set_obj obj_local
      arrayFundLocal << fund1 # Increases memory consumption
    end
  end

  puts
  puts "Finished acquiring the shortened list of funds"  
  puts "Writing fund data to database"
  puts "Finished writing fund data to database"

  # Start the database  
  fd = FundDatabase.new()
  fd.connect
  begin
    fd.dropFundTable
  rescue
  end
  fd.createFundTable
  fd.prepareInsertFundStatement
  n_funds_last = (arrayFundLocal.length) - 1
  for n in 0..n_funds_last
    # NOTE: Some of the original arrays are NOT strings.
    fund1 = arrayFundLocal [n]
    symbol_local = fund1.get_symbol
    name_local = fund1.get_name
    type_local = fund1.get_type
    obj_local = fund1.get_obj
    fd.addFund n, symbol_local, name_local, type_local, obj_local
  end

  fd.printCSV('fundlist.csv') if $is_devel # Export database to CSV
  
end

####################################
# DOWNLOAD DETAILED FUND INFORMATION
####################################
def url_fund_profile (symbol_local)
  url_local = 'http://finance.yahoo.com/q/pr?s=' + symbol_local + '+Profile'
  return url_local
end

def url_fund_holdings (symbol_local)
  url_local = 'http://finance.yahoo.com/q/hl?s=' + symbol_local + '+Holdings'
  return url_local
end

# Yahoo Finance quote data: http://www.gummy-stuff.org/Yahoo-data.htm
# URL for latest price: 'http://finance.yahoo.com/d/quotes.csv?s=' + symbol + '&f=l1'
def url_fund_price (symbol_local)
  url_local = 'http://finance.yahoo.com/d/quotes.csv?s=' + symbol_local + '&f=l1'
end

# This function downloads the fund's price per share.
# Because the file is only 7 bytes, the delay is cut to 
# 1 to 2 milliseconds.
def download_price (symbol_local)
  url1 = url_fund_price symbol_local
  dir_fund = $dir_downloads + '/' + symbol_local
  file1 = dir_fund + '/quote.csv'
  file_age = age_of_file file1 # Get age of file
  file_age_max_hours = 20
  # Get size of file (0 if it does not exist)
  file_size = 0
  begin
    file_size = File.stat(file1).size
  rescue
    file_size = 0
  end
  # Number of failures to download file
  n_fail = 0
  n_fail_max = 2
  if (file_age <= file_age_max_hours && file_size == 0) # Skip download
    # puts ("File is new enough, skipping download")
  else # Perform download until effort succeeds once or fails too many times
    while ((file_age > file_age_max_hours || file_size == 0) && (n_fail <= n_fail_max))
      begin
        # Provide a random delay of 1 to 2 milliseconds to limit the impact
        # on the upstream server
        t_delay = (1+rand)/1000
        sleep (t_delay) 
        open(file1, 'w') do |fo|
          fo.print open(url1).read
        end
        file_size = File.stat(file1).size # Bypassed if download fails
        file_age = age_of_file file1 # Bypassed if download fails
      rescue
        n_fail += 1
        puts ("Failure #" + n_fail.to_s())
        puts ("Download failed, giving up") if n_fail > n_fail_max
      end
    end
  end
end

def download_fund_data
  puts 'DOWNLOADING DETAILED INFORMATION ON FUNDS'
  puts 'NOTE: This is a VERY long process.'
  
  # Start the database  
  fd = FundDatabase.new()
  fd.connect
  i = 0 # Number of rows completed
  
  # Getting the number of funds from the table (i_total)
  # This is EXTREMELY crude, but it works.
  # I could not figure out how to extract the number of rows
  # with Postgres commands in Ruby.
  fd.scrollSymbolsFromTable do |row|
    symbol_local = row['symbol']
    i +=1
  end
  $num_funds_total = i
  
  i = 0 # Number of rows completed
  time_start = Time.now()
  fd.scrollSymbolsFromTable do |row|
    symbol_local = row['symbol']

    url1 = url_fund_profile symbol_local
    url2 = url_fund_holdings symbol_local
    url3 = url_fund_price symbol_local
    dir_fund = $dir_downloads + '/' + symbol_local
    file1 = dir_fund + '/profile.html'
    file2 = dir_fund + '/holdings.html'
    file3 = dir_fund + '/quote.csv'
    create_dir dir_fund
    download_file url1, file1, 160
    download_file url2, file2, 160
    download_price symbol_local

    i +=1
    if rand < 0.01 || i==10
      rate_s = i / (Time.now() - time_start)
      remain_s = ($num_funds_total - i) / rate_s
      remain_m = remain_s/60
      puts "Fund downloads completed: " + i.to_s() + '/' + $num_funds_total.to_s()
      puts "Minutes remaining: " + remain_m.to_s()
    end
  end
  puts 'FINISHED DOWNLOADING DETAILED FUND INFORMATION'
end

# OUTPUT: float
def percent_to_num (string_local)
  begin
    string_local.slice! '%'
    num = Float(string_local)
    return num
  rescue
    return nil
  end
end

#OUTPUT: float
def str_to_num (string_local)
  begin
    return Float (string_local)
  rescue
    return nil
  end
end

# OUTPUT: int
def str_to_int (string_local)
  string_local = string_local.gsub(",", "")
  begin
    return Integer (string_local)
  rescue
    return nil
  end
end

# OUTPUT: 0.0
def nil_to_0 (num_local)
  if num_local.nil?
    return 0.0
  else
    return num_local
  end
end

# OUTPUT: string
def scrape_cat_mf (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/profile.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[1][td[contains (text(), "Category:")]]//td[2]/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return scrape
end

# OUTPUT: string
def scrape_cat_etf (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/profile.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Category:")]]//td[2]//a/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return scrape
end

# OUTPUT: string
def scrape_cat (symbol_local)
  output = scrape_cat_mf (symbol_local)
  if output == ''
    output = scrape_cat_etf (symbol_local)
  end
  return output
end

# OUTPUT: string
def scrape_fam (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/profile.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Fund Family:")]]//td[2]//a/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return scrape
end

# OUTPUT: string
def scrape_assets (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/profile.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Net Assets:")]]//td[2]//text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return scrape
end

# OUTPUT: string
def url_stylebox (num)
  str_output = 'http://us.i1.yimg.com/us.yimg.com/i/fi/3_0stylelargeeq'
  str_output += (num.to_s() + '.gif')
  return str_output
end

# OUTPUT: 2-element array
def scrape_stylebox (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/profile.html'
  page = Nokogiri::HTML(open(filename))
  i = 0
  i_found = 0
  style_found = false
  while !style_found && i <= 10 
    # Determine if url_stylebox(i) is within filename
    is_here = false
    File.open(filename) do |io|
      io.each {|line| line.chomp!;is_here = true if line.include? url_stylebox(i)}
    end
    if is_here
      style_found = true
      i_found = i
    end
    i += 1
  end
  output_array = Array.new
  str_small = 'Small'
  str_med = 'Medium'
  str_large = 'Large'
  str_value = 'Value'
  str_blend = 'Blend'
  str_growth = 'Growth'
  case i_found
  when 1
    output_array = [str_large, str_value]
  when 2
    output_array = [str_large, str_blend]
  when 3
    output_array = [str_large, str_growth]
  when 4
    output_array = [str_med, str_value]
  when 5
    output_array = [str_med, str_blend]
  when 6
    output_array = [str_med, str_growth]
  when 7
    output_array = [str_small, str_value]
  when 8
    output_array = [str_small, str_blend]
  when 9
    output_array = [str_small, str_growth]
  else
    output_array = ['N/A', 'N/A']
  end
  return output_array
end

# OUTPUT: string
def scrape_style_size (symbol_local)
  get_array = scrape_stylebox symbol_local
  return get_array [0]
end

# OUTPUT: string
def scrape_style_value (symbol_local)
  get_array = scrape_stylebox symbol_local
  return get_array [1]
end

# OUTPUT: int
def scrape_mininv (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/profile.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Min Initial Investment:")]]//td[2]/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  scrape = str_to_int scrape
  scrape = nil_to_0 scrape
  scrape = Integer (scrape)
  return scrape
end

# OUTPUT: float
def scrape_turnover (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/profile.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Annual Holdings Turnover")]]//td[2]/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return percent_to_num scrape
end

# OUTPUT: float
def scrape_exp_gross (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/profile.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Prospectus Gross Expense Ratio")]]//td[2]/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return percent_to_num scrape
end

# OUTPUT: float
def scrape_exp_net (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/profile.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Annual Report Expense Ratio (net)")]]//td[2]/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return percent_to_num scrape
end

# OUTPUT: float
def scrape_exp (symbol_local)
  exp_local = scrape_exp_gross symbol_local
  if exp_local.nil?
    exp_local = scrape_exp_net symbol_local
  end
  return exp_local
end

# OUTPUT: float
def scrape_load_front (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/profile.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Max Front End Sales Load")]]//td[2]/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  scrape1 = percent_to_num scrape
  output = nil_to_0 scrape1
  return output
end

# OUTPUT: float
def scrape_load_back (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/profile.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Max Deferred Sales Load")]]//td[2]/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  scrape1 = percent_to_num scrape
  output = nil_to_0 scrape1
  return output
end

# OUTPUT: float
def scrape_price_orig (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/holdings.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/span[contains (@class, "time_rtq_ticker")]/span/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return str_to_num scrape
end

# OUTPUT: float
def scrape_pb_orig (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/holdings.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Price/Book")]]/td[2]/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return str_to_num scrape
end

# OUTPUT: float
def scrape_pe_orig (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/holdings.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Price/Earnings")]]/td[2]/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return str_to_num scrape
end

# OUTPUT: float
def scrape_pcf_orig (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/holdings.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Price/Cashflow")]]/td[2]/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return str_to_num scrape
end

# OUTPUT: float
def scrape_ps_orig (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/holdings.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/tr[td[contains (text(), "Price/Sales")]]/td[2]/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return str_to_num scrape
end

# OUTPUT: float
def scrape_biggest (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/holdings.html'
  page = Nokogiri::HTML(open(filename))
  string_xpath = './/table[tr[th[contains (text(), "Top 10 Holdings")]]]'
  string_xpath += '/following-sibling::table[1]/tr/td/table/tr[2]/td[3]/text()'
  scrape = page.xpath (string_xpath)
  scrape = scrape.to_s()
  return str_to_num scrape
end

# OUTPUT: float
def scrape_price_now (symbol_local)
  filename = $dir_downloads + '/' + symbol_local + '/quote.csv'
  price_string = ''
  f = File.open(filename, "r")
  f.each_line do |line|
    price_string += line
  end
  output = str_to_num price_string
  return output
end

# OUTPUT: float
def scrape_pcf_now (symbol_local)
  p2 = scrape_price_now symbol_local
  p1 = scrape_price_orig symbol_local
  ratio = scrape_pcf_orig symbol_local
  begin
    return (p2/p1) * ratio
  rescue
    return nil
  end
end

# OUTPUT: float
def scrape_pb_now (symbol_local)
  p2 = scrape_price_now symbol_local
  p1 = scrape_price_orig symbol_local
  ratio = scrape_pb_orig symbol_local
  begin
    return (p2/p1) * ratio
  rescue
    return nil
  end
end

# OUTPUT: float
def scrape_pe_now (symbol_local)
  p2 = scrape_price_now symbol_local
  p1 = scrape_price_orig symbol_local
  ratio = scrape_pe_orig symbol_local
  begin
    return (p2/p1) * ratio
  rescue
    return nil
  end
end

# OUTPUT: float
def scrape_ps_now (symbol_local)
  p2 = scrape_price_now symbol_local
  p1 = scrape_price_orig symbol_local
  ratio = scrape_ps_orig symbol_local
  begin
    return (p2/p1) * ratio
  rescue
    return nil
  end
end

# OUTPUT: string
# Converts blanks and nils to NULL
def something_to_s (input)
  str_input = input.to_s()
  str_output = str_input
  if str_input == 'nil' || str_input == ''
    str_output = 'NULL'
  end
  return str_output
end

def get_fund_details
  puts 'SCRAPING FUND DETAILS FROM DOWNLOADED PAGES'
  
  # Start the database  
  fd = FundDatabase.new()
  fd.connect
  i = 0 # Number of rows completed
  
  time_start = Time.now()
  fd.scrollSymbolsFromTable do |row|
    symbol= row['symbol']
    dir_fund = $dir_downloads + '/' + symbol
    file1 = dir_fund + '/profile.html'
    file2 = dir_fund + '/holdings.html'
    file3 = dir_fund + '/quote.csv'
    category = something_to_s(scrape_cat symbol)
    family = something_to_s(scrape_fam symbol)
    assets = something_to_s(scrape_assets symbol)
    style_size = something_to_s(scrape_style_size symbol)
    style_value = something_to_s(scrape_style_value symbol)
    min_inv = something_to_s(scrape_mininv symbol)
    expense_ratio = something_to_s(scrape_exp symbol)
    turnover = something_to_s(scrape_turnover symbol)
    load_front = something_to_s(scrape_load_front symbol)
    load_back = something_to_s(scrape_load_back symbol)
    biggest_position = something_to_s(scrape_biggest symbol)
    price = something_to_s(scrape_price_now symbol)
    pe = something_to_s(scrape_pe_now symbol)
    pb = something_to_s(scrape_pb_now symbol)
    ps = something_to_s(scrape_ps_now symbol)
    pcf = something_to_s(scrape_pcf_now symbol)
    array_details = Array.new
    array_details << symbol << category << family 
    array_details << style_size << style_value << price
    array_details << pcf << pb << pe << ps << expense_ratio
    array_details << load_front << load_back << min_inv
    array_details << turnover << biggest_position << assets
    # array_details = [symbol, category, family, style_size, style_value, 
    # price, pcf, pb, pe, ps, expense_ratio, load_front, load_back, 
    # min_inv, turnover, biggest_position, assets]
    # NOTE: All inputs must be strings.
    fd.updateFund array_details    
    i += 1
    if rand < 0.01 || i==10
      rate_s = i / (Time.now() - time_start)
      remain_s = ($num_funds_total - i) / rate_s
      remain_m = remain_s/60
      puts "Fund data scraping completed: " + i.to_s() + '/' + $num_funds_total.to_s()
      puts "Minutes remaining: " + remain_m.to_s()
    end
  end
  puts 'FINISHED SCRAPING DETAILED FUND INFORMATION'
  fd.printCSVmain('profile_all.csv') if $is_devel # Export database to CSV
  fd.copyFundTable
  fd.disconnect
end





###############
# MAIN FUNCTION
###############
def main
  delay
  select_length
  get_env
  create_dir_all
  get_db_params
  if $exec_long
    fillDatabaseFundLong
  else
    fillDatabaseFundShort
  end
  download_fund_data
  get_fund_details
end

main
