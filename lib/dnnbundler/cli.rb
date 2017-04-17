require "zipFileGenerator"
require "thor"

module Dnnbundler
    class CLI < Thor
        desc "build CONFIG", ""
        option :bumpBuild
        def build( config )
            puts "Build with config #{config}"
            file = File.read(config)
            data_hash = JSON.parse(file)
            # puts "file: #{data_hash}, #{data_hash["files"]}"

            input_entries = data_hash["entries"]
            ignore_entries = data_hash["excludeEntries"]
            zip_file_name = data_hash["outFileName"]
            generator = ZipFileGenerator.new(input_entries, ignore_entries, zip_file_name)
            generator.write
        end
    end
end
