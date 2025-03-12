class Mime
  @mimeHash = {
        '.css' => 'text/css',
        '.mp4' => 'video/mp4',
        '.arj' => 'application/arj',
        '.bmp' => 'image/bmp',
        '.cab' => 'application/cab',
        '.csv' => 'text/plain',
        '.doc' => 'application/msword',
        '.gif' => 'image/gif',
        '.htm' => 'text/html',
        '.html' => 'text/html',
        '.jpg' => 'image/jpeg',
        '.js' => 'text/js',
        '.log' => 'text/plain',
        '.md' => 'text/plain',
        '.mp3' => 'audio/mpeg',
        '.ods' => 'application/vnd.oasis.opendocument.spreadsheet',
        '.pdf'  => 'application/pdf',
        '.php' => 'application/x-httpd-php',
        '.png' => 'image/png',
        '.rar' => 'application/rar',
        '.swf' => 'application/x-shockwave-flash',
        '.tar' => 'application/tar',
        '.tmpl' => 'text/plain',
        '.txt' => 'text/plain',
        '.xls' => 'application/vnd.ms-excel',
        '.xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        '.xml' => 'text/xml',
        '.zip' => 'application/zip'
  }

  def self.to_mime(ext)
    @mimeHash[ext]
  end
end

