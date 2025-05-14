class DownloadsController < ApplicationController
  def show
    filename = params[:filename]
    filepath = Rails.root.join('tmp', filename)

    if File.exist?(filepath)
      send_file filepath,
                disposition: 'attachment',
                filename: filename,
                type: 'text/csv'
    else
      render json: { error: 'File not found' }, status: 404
    end
  end
end
