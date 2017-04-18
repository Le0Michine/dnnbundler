require "dnnbundler/fileEntryType"
require "dnnbundler/fileEntry"
require "dnnbundler/jsonConfig"
require "zip"

module Dnnbundler
    class ZipFileGenerator
        # Initialize with the directory to zip and the location of the output archive.
        def initialize(data)
            @entries = data[JsonConfig::Entries]
            @ignore_entries = data[JsonConfig::IgnoreEntries]
            @output_file = data[JsonConfig::Name]
        end

        # Zip the input directory.
        def write
            buffer = create_zip @entries, @ignore_entries
            File.open(@output_file, "wb") {|f| f.write buffer.string }
        end

        private

        # True if +fileEntry+ isn't included into +ignore_entries+ array'
        def filter_entries(fileEntryName, fileEntryType, ignore_entries)
            return true if ignore_entries == nil
            ignore_entries.each do |entry|
                return false if (fileEntryType.casecmp(FileEntryType::FILE) == 0) && (fileEntryName.include? entry)
            end
            return true
        end

        # Creates +FileEntry+ for file or array of entries for directory and subdirectories
        # Params:
        # +directory_or_file+:: path to directory or file
        # +entry_path+:: path with which the entry should be put into zip
        def get_entries(directory_or_file, entry_path, ignore_entries)
            if File.directory? directory_or_file
                get_dir_entries_recursively directory_or_file, entry_path, ignore_entries
            else
                FileEntry.new directory_or_file, FileEntryType::FILE, false, entry_path
            end
        end

        # Collects all files from directory recursively
        # Params:
        # +dir+:: start directory
        # +entry_path+:: path with which file should be placed into zip
        # +replace_path+:: part of path which is being replaced by +entry_path+
        def get_dir_entries_recursively(dir, entry_path, ignore_entries, replace_path = nil)
            replace_path = dir.clone if replace_path.nil?
            (Dir.entries(dir) - %w(. ..)).map { |v| File.join(dir, v) }.select { |path| filter_entries path, FileEntryType::FILE, ignore_entries }.map { |path|
                if File.directory? path
                    get_dir_entries_recursively(path, entry_path, ignore_entries, replace_path)
                else
                    entry_path_in_zip = (entry_path.nil? ? path : path.sub(replace_path, entry_path)).gsub(/^[\/\\]+/, "")
                    FileEntry.new path, FileEntryType::FILE, false, entry_path_in_zip
                end
            }
        end

        # Creates zip file in memory from passed +FileEntry+ array, returns StringIO as result
        # Params:
        # +entries+:: array of +FileEntry+ objects
        def compress(entries)
            puts "\nadding the following entries into zip package"
            puts "#{ entries.map{ |x| x.name + ", " + x.path.to_s + ", " + x.type.to_s }.join("\n")}"
            buffer = Zip::File.add_buffer do |zio|
                entries.each do |file|
                    if file.type.casecmp(FileEntryType::FILE) == 0
                        zio.add(file.path == nil ? file.name : file.path, file.name)
                    else
                        zio.get_output_stream(file.name) { |os| os.write file.buffer.string }
                    end
                end
            end
        end

        # Creates from json array of entries
        def create_zip(entries, ignore_entries)
            compress entries.map { |x|
                if x.is_a? String
                    get_entries x, nil, ignore_entries
                elsif x[JsonConfig::Type].nil? || x[JsonConfig::Type].casecmp(FileEntryType::FILE) == 0
                    get_entries x[JsonConfig::Name], x[JsonConfig::Path], ignore_entries
                elsif x[JsonConfig::Type].casecmp(FileEntryType::ZIP) == 0
                    zip_file_entry = FileEntry.new x[JsonConfig::Name], FileEntryType::ZIP, false, x[JsonConfig::Path]
                    zip_file_entry.add_buffer create_zip x[JsonConfig::Entries], x[JsonConfig::IgnoreEntries]
                    result = zip_file_entry
                end
            }.flatten.select{ |f| filter_entries f.name, f.type, ignore_entries }.uniq{ |f| f.name }
        end
    end
end