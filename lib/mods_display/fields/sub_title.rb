class ModsDisplay::SubTitle < ModsDisplay::Field
  def fields
    ModsDisplay::Title.new(@values[1, @values.length], @config, @klass).fields
  end
end