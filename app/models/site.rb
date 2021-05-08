require_relative 'chrome'

class Site < ApplicationRecord
  has_many :site_versions

  def next_fetch
    last_fetch + timer.minutes
  end
  
  def latest_version
    self.site_versions.order("created_at DESC").first
  end

  def latest_two_versions
    versions = self.site_versions.order("created_at DESC").limit(2)
    return [] if versions.count < 2
    versions.to_a
  end

  def simple_diff_versions(versions, format = :html)
    return nil if versions.blank?
    rows1 = versions[0].format(format).split(/\n/)
    rows2 = versions[1].format(format).split(/\n/)
    rows1.zip(rows2).map do |row_data|
      row_data[0] == row_data[1] ? nil : row_data
    end.compact
  end

  def simple_diff(format = :html)
    simple_diff_versions(latest_two_versions, format)
  end

  def diffy(format = :html)
    versions = latest_two_versions
    version1 = versions[0].format(format)
    version2 = versions[1].format(format)
    Diffy::Diff.new(version2, version1, context: 3).to_s
  end

  def screenshot(filename)
    path = Rails.root + filename
    screenshot_data = Chrome.screenshot_page(self.url)
    File.open(path, "wb") do |file|
      file.write(Base64.decode64(screenshot_data["data"]))
    end
  end
  
  def fetch
    begin
      html = HTTParty.get(self.url)
      self.update_attribute(:last_fetch, Time.now)
      html = html.encode("UTF-8")
      if !latest_version || latest_version.raw_html != html.to_s
        self.site_versions.create(raw_html: html.to_s)
      end
    rescue => e
      STDERR.puts e.backtrace
      STDERR.puts e.message
    end
  end

  def timed_fetch
    if next_fetch < Time.now
      fetch
    end
  end
  
  def self.fetch_all
    Site.all.each do |site|
      site.fetch
    end
  end

  def self.timed_fetch_all
    Site.all.each do |site|
      site.timed_fetch
    end
  end
end
