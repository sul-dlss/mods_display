class ModsDisplay::Language
  def initialize(language)
    @language = language
  end
  
  def label
    "Language"
  end
  
  def text
    output = []
    if @language.respond_to?(:displayForm)
      output << @language.displayForm.text
    else
      output << language_codes[@language.text.strip]
    end
    output.join(" ").strip
  end
  
  private
  
  def language_codes
    SEARCHWORKS_LANGUAGES
  end
  
end