class ModsDisplay::SubTitle < ModsDisplay::Field
  def fields
    ModsDisplay::Title.new(@value[1, @value.length], @config, @klass).fields
  end
end