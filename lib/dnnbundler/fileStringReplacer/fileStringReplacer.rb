module Dnnbundler
    def self.replaceVersionInManifestFiles(file_names, new_version)
        file_names.each do |file_name|
            text = File.read(file_name)
            replace_expr = '\1' + new_version + '\3'
            text.gsub!(ManifestVersionRegex::NewManifestRegex, replace_expr )
            text.gsub!(ManifestVersionRegex::OldManifestRegex, replace_expr )

            # To merely print the contents of the file, use:
            # puts new_contents

            # To write changes to the file, use:
            File.open(file_name, "w") {|file| file.puts text }
        end
    end

    def self.getVersionFromManifest(file_name)
        text = File.read(file_name)
        (ManifestVersionRegex::NewManifestRegex.match(text) || ManifestVersionRegex::OldManifestRegex.match(text)).captures[1]
    end

    module ManifestVersionRegex
        OldManifestRegex = /(<version>)(\d*?\.\d*?\.\d*)(<\/version>)/
        NewManifestRegex = /(<package .*? version=")(\d*?\.\d*?\.\d*)(.*?>)/
    end
end