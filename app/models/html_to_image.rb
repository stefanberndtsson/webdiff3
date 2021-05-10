class HtmlToImage
  STYLE = "
  <style>
    body { font-family: sans; font-size: 150%; }
  </style>
  " 
  
  def self.from_markdown(markdown, image_filename, width = 600)
    html = CommonMarker.render_html(markdown, [:HARDBREAKS, :UNSAFE])
    Tempfile.open(['html', '.html'], encoding: 'ascii-8bit') do |file|
      file.write(STYLE)
      file.write(html)
      file.flush

      IO.popen(["wkhtmltoimage", "-f", "png", "--quality", "1", "--width", "#{width}",
                file.path, image_filename], :err => [:child, :out]) do |io|
        # Read and ignore output
        io.read
      end
      
      file.unlink
    end
  end

  def self.screenshot_page(url, image_subdir, image_filename, width = 1280)
    screenshot_dir = Rails.application.credentials.screenshot_dir
    dir = "#{screenshot_dir}/#{image_subdir}"
    FileUtils.mkdir_p(dir)
    path = "#{dir}/#{image_filename}"
    IO.popen(["wkhtmltoimage", "-f", "png", "--quality", "1", "--width", "#{width}",
              url, path], :err => [:child, :out]) do |io|
      # Read and ignore output
      io.read
    end
  end
end

