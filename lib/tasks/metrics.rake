namespace :metrics do
  def logger
    require 'logger'
    logger = Logger.new(Rails.root.join("log/metrics.log"), "monthly")
  end

  def metrics_path
    Rails.root.join('public/metrics/')
  end


  desc "Generate all metrics"
  task :generate do
    # expects all metrics to have :generate tasks
    Metric.names.each do |metric_name|
      metric_rake_task = "metrics:#{metric_name}:generate"
      Rake::Task[metric_rake_task].invoke
    end
  end

  namespace :brakeman do
    brakeman_path = metrics_path.join('brakeman')

    desc "Clean html pages at #{brakeman_path}"
    task :clean do
      message = "Removing brakeman pages #{brakeman_path}"
      logger.info message
      # puts message
      FileUtils.rm_rf(brakeman_path)
    end

    desc "Generates/updates brakeman html report"
    task :generate, [:verbose] do |t, args|
      args.with_defaults(verbose: 'true')
      verbose = (args[:verbose] == 'true') ? true : false

      FileUtils.mkdir(brakeman_path) unless Dir.exists?(brakeman_path)
      output_file = brakeman_path.join('index.html')
      cmd = "brakeman --output #{output_file}"
      cmd += " --quiet" unless verbose

      logger.info "Generating brakeman: #{cmd}"
      `#{cmd}`
    end
  end

  namespace :sandi_meter do
    sandi_pages_path = metrics_path.join('sandi_meter')

    desc "Generates/updates html pages for /metrics/sandi_meter"
    task :generate, [:verbose] do |t, args|
      args.with_defaults(verbose: 'true')
      verbose = (args[:verbose] == 'true') ? true : false

      # mms: using CLI because I could not find easy way to access anaylzer, for rails -> html, via code
      cmd = %Q(sandi_meter --quiet --graph --output-path "#{sandi_pages_path}")
      # cmd += " --details" if verbose
      message = "Generating sandi_meter metrics: #{cmd}"
      logger.info message
      puts message if verbose
      `#{cmd}`

      # update assets for rails public dir
      index_file = sandi_pages_path.join('index.html')
      text = File.read(index_file)
      # add leading slash
      new_contents = text.gsub(/href="assets/, 'href="/assets')
      new_contents = new_contents.gsub(/src="assets/, 'src="/assets')
      # write changes to index.html
      File.open(index_file, "w") {|file| file.puts new_contents }
    end

    desc "Clean html pages at #{sandi_pages_path}"
    task :clean do
      message = "Removing sandi_meter pages #{sandi_pages_path}"
      logger.info message
      # puts message
      FileUtils.rm_rf(sandi_pages_path)
    end
  end
end
