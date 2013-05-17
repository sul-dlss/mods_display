# encoding: utf-8
class ModsDisplay::Abstract < ModsDisplay::Field

  def label
    super || "Abstract"
  end

  def text
    return link_value(super) unless super.nil?
    link_value(@value.text)
  end

  private

  def link_value(val)
    val = val.dup
    # http://daringfireball.net/2010/07/improved_regex_for_matching_urls
    url = /(?i)\b(?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\([^\s()<>]+|\([^\s()<>]+\)*\))+(?:\([^\s()<>]+|\([^\s()<>]+\)*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’])/i
    # http://www.regular-expressions.info/email.html
    email = /[A-Z0-9_\.%\+\-\']+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)/i
    matches = [val.scan(url), val.scan(email)].flatten
    matches.each do |match|
      if match =~ email
        val = val.gsub(match, "<a href='mailto:#{match}'>#{match}</a>")
      else
        val = val.gsub(match, "<a href='#{match}'>#{match}</a>")
      end
    end
    val
  end

end