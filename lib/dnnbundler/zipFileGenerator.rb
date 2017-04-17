require "dnnbundler/fileEntryType"
require "dnnbundler/fileEntry"
require "zip"

module Dnnbundler
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

        def get_entries(directory_or_file)
            if File.directory? directory_or_file
                get_dir_entries_recursively directory_or_file
            else
                FileEntry.new directory_or_file
            end
        end

        def get_dir_entries_recursively(dir)
            (Dir.entries(dir) - %w(. ..)).map { |v|
                path = File.join(dir, v)
                if File.directory? path
                    get_dir_entries_recursively(path)
                else
                    FileEntry.new path
                end
            }
        end

        def compress(entries)
            buffer = Zip::File.add_buffer do |zio|
                entries.each do |file|
                    if file.type == FileEntryType::FILE
                        zio.add(file.name, file.name)
                    else
                        zio.get_output_stream(file.name) { |os| os.write file.buffer.string }
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
                    zip_file_entry = FileEntry.new x["name"], FileEntryType::ZIP
                    zip_file_entry.add_buffer create_zip x["entries"]
                    result = zip_file_entry
                end
            }.flatten.select{ |f| filter_entries f }.uniq{ |f| f.name }
        end
    end
end