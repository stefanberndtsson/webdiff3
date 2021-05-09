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
    if self.site.xpaths_to_remove.present?
      self.site.xpaths_to_remove.each do |xpath|
        doc.search(xpath.xpath).remove
      end
    end
    docs = []
    if self.site.xpaths_to_select.present?
      self.site.xpaths_to_select.each do |xpath|
        docs += doc.search(xpath.xpath)
      end
    else
      return doc.to_s
    end
    Nokogiri::HTML(docs.map {|x| x.to_s}.join("\n")).to_s
  end

  def format(format = :html)
    return readable if format == :readable
    return text if format == :text
    return readable_text if format == :readable_text
    return raw_html if format == :raw
    html
  end
end
