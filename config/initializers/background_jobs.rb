Thread.new do
  Rails.application.reloader.wrap do
    EmailSchedulerWorker.new.perform
  end
end unless defined?(Rails::Console) || Rails.env.test? || File.basename($0) == "rake"