require 'vmstat'

class ServerInfo < ActiveRecord::Base
  after_initialize :init
  attr_accessor :cpu_load, :mem_total, :mem_used, :disk_total, :disk_used, :uptime

  def init
    mem = Vmstat.memory
    # Getting disk info for main partition is, temprorarily, for only
    # UN*X-like systems, such as GNU/Linux, BSD, Mac OS X etc.
    # Windows implementation will be added in future
    disk = Vmstat.disk('/')
    # CPU load data => Float typed
    self.cpu_load = Vmstat.load_average.five_minutes
    # All size data => Megabytes (MB)
    self.mem_total = mem.total_bytes / 1024**2
    self.mem_used = (mem.total_bytes - mem.free_bytes) / 1024**2
    self.disk_total = disk.total_bytes / 1024**2
    self.disk_used = (disk.total_bytes - disk.free_bytes) / 1024**2
    # Uptime data => Minutes
    self.uptime = (Time.now - Vmstat.boot_time).to_i / 60
  end

  def as_json
    { "CPU" => self.cpu_load,
      "Memory" => {
        "Total" => self.mem_total,
        "Used" => self.mem_used,
      },
      "Disk" => {
        "Total" => self.disk_total,
        "Used" => self.disk_used
      },
      "Uptime" => self.uptime
    }.to_json
  end
end
