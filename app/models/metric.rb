require 'logger'

class Metric
  def self.names
    %w(brakeman sandi_meter).sort
  end
end
