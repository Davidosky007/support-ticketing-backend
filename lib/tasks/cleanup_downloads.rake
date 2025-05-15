namespace :downloads do
  desc 'Clean up old download files from tmp directory'
  task cleanup: :environment do
    # Keep files newer than this threshold (default: 7 days)
    threshold = ENV.fetch('DOWNLOADS_CLEANUP_DAYS', '7').to_i.days.ago

    puts "Cleaning up download files older than #{threshold}"
    cleanup_count = 0

    Dir.glob(Rails.root.join('tmp', '*.csv')).each do |file|
      next unless File.mtime(file) < threshold

      puts "  Removing old file: #{File.basename(file)}"
      File.delete(file)
      cleanup_count += 1
    end

    if cleanup_count.zero?
      puts 'No files needed cleanup'
    else
      puts "Removed #{cleanup_count} old download files"
    end
  end
end
