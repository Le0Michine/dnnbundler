module Dnnbundler
    class FileEntry
        def initialize(file_name, entry_type = FileEntryType::FILE, flatten_structure = false, file_path = nil)
            @type = entry_type
            @name = file_name
            @path = file_path
            @flatten = flatten_structure
        end

        # Saves +StringIO+ buffer into object, intended to store nested zip files in memory
        def add_buffer(buffer)
            @buffer = buffer
        end

        # Entry type: ZIP or FILE
        def type
            @type
        end

        # Entry name, used as a real path in file system
        def name
            @name
        end

        # True if existing directory structure shouldn't be preserved'
        def flatten
            @flatten
        end

        # +StringIO+ buffer with nested zip file
        def buffer
            @buffer
        end

        # Path of entry in a zip archive
        def path
            @path
        end
    end
end
