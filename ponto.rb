require 'date'

@cards = {} # a dictionary of arrays of DateTimes, whose keys are Dates
@holidays = {} # a hash whose key is a Date and value is a description string

def punch_card(date_time)
  day = Date.new(date_time.year, date_time.month, date_time.day)
  @cards[day] = [] if @cards[day].nil?
  @cards[day] << date_time
end

def time_to_s(seconds)
  negative = seconds < 0
  sign = 
    if seconds < 0
      '-'
    elsif seconds > 0
      '+'
    else
      ' '
    end
  seconds = seconds.magnitude
  minutes, seconds = seconds.divmod(60)
  hours, minutes = minutes.divmod(60)
  out = "#{sign}%02d:%02d"%[hours, minutes]
end

def get_positive_balance(day)
  balance = 0
  unless @cards[day].nil?
    @cards[day].each_slice(2) do |begin_card, end_card|
      balance += end_card.to_time.to_i - begin_card.to_time.to_i unless end_card.nil?
    end
  end
  balance
end

def add_holiday(day, description)
  @holidays[day] = description
end

def holiday?(day)
  @holidays.keys.include?(day)
end

def show_balance(start_date, end_date)
  balance = 0 # in seconds
  (start_date..end_date).each do |day|
    work_hours = 0
    work_hours = ((8 * 60 * 60) + (48 * 60)) unless day.sunday? || day.saturday? || holiday?(day)
    worked_hours = get_positive_balance(day)
    balance += (worked_hours - work_hours)
    output = "#{day.strftime("%Y-%m-%d %a")}"
    output += ": #{time_to_s(worked_hours - work_hours)}"
    output += " Holiday: #{@holidays[day]}" if holiday?(day)
    puts output
  end
  puts "Total balance: #{time_to_s(balance)}"
end

def load_cards(filepath='punch_cards.txt')
  day = nil
  file = File.open(filepath, 'r')
  file.each_line do |line|
    if line =~ /^\d/ # starts with a digit
      day = Date.parse(line[0..-2]) 
    elsif line.start_with?('*')
      add_holiday(day, line[1..-2])
    elsif line.start_with?('  ')
      hour = line[2..3].to_i
      mins = line[5..6].to_i
      date_time = DateTime.new(day.year, day.month, day.day, hour, mins)
      punch_card(date_time)
    end
  end
end

start_date = Date.parse('2018-05-25')
end_date = Date.parse('2018-06-15')

load_cards
show_balance(start_date, end_date)


