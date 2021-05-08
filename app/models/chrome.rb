class Chrome
  def self.client
    chromium_ip = IPSocket::getaddress("chromium")
    @@client ||= ChromeRemote.client(
      host: chromium_ip,
      port: 9222,
      new_tab: false,
    )
  end

  def self.reset
    @@client = nil
    client
  end
  
  def self.page_size(client)
    layout_metrics = client.send_cmd "Page.getLayoutMetrics"
    {
      width: layout_metrics["contentSize"]["width"],
      height: layout_metrics["contentSize"]["height"]
    }
  end

  def self.screenshot_page(url)
    client.send_cmd "Network.enable"
    client.send_cmd "Page.enable"
    client.send_cmd "Page.navigate", url: url
    client.wait_for "Page.loadEventFired"
    size = page_size(client)
    client.send_cmd("Emulation.setDeviceMetricsOverride", {
                      width: size[:width],
                      height: size[:height],
                      deviceScaleFactor: 1,
                      mobile: false,
                      screenOrientation: {
                        type: "portraitPrimary",
                        angle: 0
                      }})
    client.send_cmd("Page.captureScreenshot", {format: "png", fromSurface: true})
  end
end

