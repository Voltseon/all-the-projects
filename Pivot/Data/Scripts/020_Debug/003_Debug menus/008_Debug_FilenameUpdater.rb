#===============================================================================
#
#===============================================================================
module FilenameUpdater
  module_function

  def readDirectoryFiles(directory, formats)
    files = []
    Dir.chdir(directory) {
      formats.each do |format|
        Dir.glob(format) { |f| files.push(f) }
      end
    }
    return files
  end

  def rename_files
    Console.echo_h1 "Updating file names and locations"
    change_record = []
    # Warn if any map data has been changed
    if !change_record.empty?
      change_record.each { |msg| Console.echo_warn msg }
      Console.echo_warn _INTL("RMXP data was altered. Close RMXP now to ensure changes are applied.")
    end
    echoln ""
    Console.echo_h2("Finished updating file names and locations", text: :green)
  end
end
