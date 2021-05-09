require_relative 'chrome'

class Site < ApplicationRecord
  has_many :site_versions
  has_many :site_xpaths

  def next_fetch
    last_fetch + timer.minutes
  end

  def xpaths_to_remove
    site_xpaths.where(operation: "remove")
  end

  def xpaths_to_select
    site_xpaths.where(operation: "select")
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

  def style_diff(diff, format)
    return diff if format == :html
    diff.split(/\n/).map do |line|
      text = line[1..]
      if line[0] == "+"
        "* **#{text}**  \n"
      elsif line[0] == "-"
        "\n* ~~*#{text}*~~  "
      else
        text
      end
    end.join("\n")
  end

  def send_diff
    markdown_diff = diffy(:text)
    if markdown_diff
      puts " - Sending notification for #{self.name}"
      Notify.send(self.notification_tag, self.name, markdown_diff)
    end
  end
  
  def diffy(format = :html)
    versions = latest_two_versions
    return nil if versions.blank?
    version1 = versions[0].format(format)
    version2 = versions[1].format(format)
    return nil if version1 == version2
    diff = Diffy::Diff.new(version2, version1, context: 3).to_s
    style_diff(diff, format)
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
    return false if next_fetch > Time.now
    fetch
    true
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

  def self.timed_fetch_all_and_notify
    Site.all.each do |site|
      if site.timed_fetch
        puts "Fetched new version of #{site.name}"
        site.send_diff
      end
    end
  end
end
