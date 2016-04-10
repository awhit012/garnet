class MetricsController < ApplicationController
  def index
    @metrics = Metric.names
  end
end
