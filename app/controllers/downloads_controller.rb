class DownloadsController < ApplicationController
  def show
    file_path = session[:export_file]
    
    if file_path && File.exist?(file_path)
      filename = File.basename(file_path)
      send_file file_path, 
        filename: filename,
        type: 'text/csv',
        disposition: 'attachment'
      
      # Clean up after sending
      session.delete(:export_file)
    else
      render json: { error: "File not found" }, status: 404
    end
  end
end