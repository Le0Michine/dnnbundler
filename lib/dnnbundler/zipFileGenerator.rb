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
            File.open(@output_file, "wb") {|f| f.write buffer.string }
        end

        private

        # True if +fileEntry+ isn't included into +@ignore_entries+ array'
        def filter_entries(fileEntry)
            @ignore_entries.each do |entry|
                return false if fileEntry.name.include? entry
            end
        end

        # Creates +FileEntry+ for file or array of entries for directory and subdirectories
        # Params:
        # +directory_or_file+:: path to directory or file
        # +entry_path+:: path with which the entry should be put into zip
        def get_entries(directory_or_file, entry_path)
            if File.directory? directory_or_file
                get_dir_entries_recursively directory_or_file, entry_path
            else
                FileEntry.new directory_or_file, entry_path
            end
        end

        # Collects all files from directory recursively
        # Params:
        # +dir+:: start directory
        # +entry_path+:: path with which file should be placed into zip
        # +replace_path+:: part of path which is being replaced by +entry_path+
        def get_dir_entries_recursively(dir, entry_path, replace_path = nil)
            replace_path = dir if replace_path == nil
            (Dir.entries(dir) - %w(. ..)).map { |v|
                path = File.join(dir, v)
                if File.directory? path
                    get_dir_entries_recursively(path, entry_path, replace_path)
                else
                    entry_path_in_zip = path.sub(replace_path, entry_path).gsub(/^[\/\\]+/, "")
                    FileEntry.new path, FileEntryType::FILE, false, entry_path_in_zip
                end
            }
        end

        # Creates zip file in memory from passed +FileEntry+ array, returns StringIO as result
        # Params:
        # +entries+:: array of +FileEntry+ objects
        def compress(entries)
            puts "adding the following entries into zip package"
            puts "#{ entries.map{ |x| x.name + ", " + x.path.to_s }.join("\n")}"
            buffer = Zip::File.add_buffer do |zio|
                entries.each do |file|
                    if file.type == FileEntryType::FILE
                        zio.add(file.path == nil ? file.name : file.path, file.name)
                    else
                        zio.get_output_stream(file.path == nil ? file.name : file.path) { |os| os.write file.buffer.string }
                    end
                end
            end
        end

        # Creates from json array of entries
        def create_zip(entries)
            compress entries.map { |x|
                if x.is_a? String
                    get_entries x, nil
                elsif x["type"].casecmp(FileEntryType::FILE) == 0
                    get_entries x["name"], x["path"]
                elsif x["type"].casecmp(FileEntryType::ZIP) == 0
                    zip_file_entry = FileEntry.new x["name"], FileEntryType::ZIP, false, x["path"]
                    zip_file_entry.add_buffer create_zip x["entries"]
                    result = zip_file_entry
                end
            }.flatten.select{ |f| filter_entries f }.uniq{ |f| f.name }
        end
    end
end