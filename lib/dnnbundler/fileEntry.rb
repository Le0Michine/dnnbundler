module Dnnbundler
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
end
