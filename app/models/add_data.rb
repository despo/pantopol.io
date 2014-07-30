require 'import_data'
class AddData
  def initialize
    ImportData.new.run_spreadsheets
  end

end
