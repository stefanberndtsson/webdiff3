class SiteVersion < ApplicationRecord
  belongs_to :site

  def readable
    Readability::Document.new(html).content
  end

  def text
    Html2Text.convert(html)
  end

  def readable_text
    Html2Text.convert(readable)
  end
  
  def html
    doc = Nokogiri::HTML(raw_html)
    doc.search('script').remove
    if self.site.xpath_remove.present?
      doc.search(self.site.xpath_remove).remove
    end
    if self.site.xpath_select.present?
      doc = doc.search(self.site.xpath_select)
    end
    doc.to_s
  end
  
  def format(format = :html)
    return readable if format == :readable
    return text if format == :text
    return readable_text if format == :readable_text
    return raw_html if format == :raw
    html
  end
end
