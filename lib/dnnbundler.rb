require "dnnbundler/version"
require "thor"
require "json"
require "zip"

module Dnnbundler
    class CLI < Thor
        desc "build CONFIG", ""
        option :bumpBuild
        def build( config )
            puts "Build withconfig #{config}"
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

    class ZipFileGenerator
        # Initialize with the directory to zip and the location of the output archive.
        def initialize(entries, ignore_entries, output_file)
            @entries = entries
            @ignore_entries = ignore_entries
            @output_file = output_file
        end

        # Zip the input directory.
        def write
            buffer = create_zip @entries
            File.open("newzip.zip", "wb") {|f| f.write buffer.string }
        end

        private

        def filter_entries(fileEntry)
            @ignore_entries.each do |entry|
                return false if fileEntry.name.include? entry
            end
        end

        def get_entries(name)
            if File.directory? name
                get_dir_entries_recursively name
            else
                FileEntry.new name
            end
        end

        def get_dir_entries_recursively(dir)
            (Dir.entries(dir) - %w(. ..)).map { |v|
                file = File.join(dir, v)
                if File.directory? file
                    get_dir_entries_recursively(file)
                else
                    FileEntry.new file
                end
            }
        end

        def compress(entries)
            buffer = Zip::File.add_buffer do |zio|
                entries.each do |file|
                    if file.type == FileEntryType::FILE
                        zio.add(file.name, file.name)
                    else
                        zio.get_output_stream(file.name) { |os| os.write file.buffer }
                    end
                end
            end
        end

        def create_zip(entries)
            compress entries.map { |x|
                if x.is_a? String
                    get_entries x
                elsif x["type"].casecmp(FileEntryType::FILE) == 0
                    get_entries x["name"]
                elsif x["type"].casecmp(FileEntryType::ZIP) == 0
                    zip_file_entry = FileEntry.new x["name"]
                    zip_file_entry.add_buffer create_zip x["entries"]
                end
            }.flatten.select{ |f| filter_entries f }.uniq{ |f| f.name }
        end
    end

    class FileEntry
        def initialize(file_name, entry_type = FileEntryType::FILE, flatten_structure = false)
            @type = entry_type
            @name = file_name
            @flatten = flatten_structure
        end

        def add_buffer(buffer)
            @buffer = buffer
        end

        def type
            @type
        end

        def name
            @name
        end

        def flatten
            @flatten
        end

        def buffer
            @buffer
        end
    end

    module FileEntryType
        ZIP = "ZIP"
        FILE = "FILE"
    end
end
