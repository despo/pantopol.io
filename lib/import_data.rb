# encoding: UTF-8
require 'spreadsheet'
class ImportData

  CITIES = ["ΛΕΥΚΩΣΙΑ", "ΛΕΜΕΣΟΣ", "ΛΑΡΝΑΚΑ", "ΠΑΦΟΣ", "ΑΜΜΟΧΩΣΤΟΣ" ]

  def run_spreadsheets
    Dir.entries('./data/unprocessed').each do |d|
      unless d == "." or d == ".."
      s = Spreadsheet.open("./data/unprocessed/#{d}")
      @spreadsheet = s
      run s
      end
    end
  end

  def run spreadsheet
    @sheet = spreadsheet.worksheet CITIES.first
    @names = []
    @units = []
    setup_cities

    @cities.each do |city|
      load_city_data city
    end
  end

  def setup_cities
    @cities = CITIES.map do |city|
      City.find_or_create_by name: city
    end
  end

  def load_city_data city
    sheet = @spreadsheet.worksheet city.name

    name = nil
    date =  sheet.row(4)[4]
    unit =  sheet.row(10)[4]

    stores = sheet.row(6)[5..sheet.row(6).size].map do |s|
      unless s.nil? or s.eql? "Μέσος Όρος Τιμής Ανά Προϊόν"
        Store.find_or_create_by identifier_string: s.strip, city: city
      end
    end


    sheet.each_with_index 3 do |row, index|
      row[3..row.size].each_with_index do |c, i|

        if i < 2
          unit = !c.eql?("\"") ? c : unit if i == 1

          if @sheet.eql? sheet and i == 0
            name = "#{c.nil? ? nil : c}"
            @names << name unless name.eql? "Κατηγορία / Είδος" or name.eql? "ΛΑΧΑΝΙΚΑ" or name.eql? "Όνομα Φρουταρίας"
          else
            name = @sheet.row(index+3)
            name =  name[3]
          end

          unless unit.nil? and i == 1
            if unit.is_a?(String) and @sheet.eql? sheet
              @units << unit
            else
              unit = @units[index]
            end
          end
        else
          unless name.blank? or c.nil? or unit.eql? "Μονάδα" or name.eql? "ΗΜΕΡΟΜΗΝΙΑ ΚΑΤΑΓΡΑΦΗΣ:"
            begin
              a = i-2
              if a > stores.length
                a = i-stores.length
              end
              s = stores[a]
              product = Product.new
              product.name = name
              product.date = date
              product.unit = unit
              product.store = s
              product.price = c
              product.save
            rescue Exception => e
              puts e.message
            end
          end
        end
      end
    end
  end

  private
  def spreadsheet2
    #@spreadsheet ||= Spreadsheet.open("./data/2013-08-08-frui_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-08-01-fruit_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-07-25-fruit_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-07-18-fruit_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-01-31-frui_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-03-14-fruit_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-03-21-fruit_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-04-11-fruit_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-06-06-fruit_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-07-04-fruit_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-06-27-fruit_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-07-11-fruit_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-06-13-fruit_and_veg.xls")
    @spreadsheet ||= Spreadsheet.open("./data/2013-06-20-fruit_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-04-18-fruit_and_veg.xls")
    #@spreadsheet ||= Spreadsheet.open("./data/2013-02-21-fruit_and_veg.xls")
  end
end

