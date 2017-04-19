require "dnnbundler/zipFileGenerator"
require "dnnbundler/fileStringReplacer/fileStringReplacer"
require "thor"
require "json"

module Dnnbundler
    class CLI < Thor
        desc "build CONFIG [options]", "creates a zip package according to given configuration file"
        option :bumpBuild
        option :bumpSprint
        option :targetVersion, :type => :string
        def build( config )
            puts "Build with config #{config}"
            file = File.read(config)
            data_hash = JSON.parse(file)

            manifest_files = data_hash["manifests"]
            current_version = Dnnbundler::getVersionFromManifest manifest_files[0]
            version_numbers = current_version.split(".").map { |x| x.to_i }

            version_numbers[1] = version_numbers[1] + 1 if options[:bumpSprint]
            version_numbers[2] = 1 if options[:bumpSprint]
            version_numbers[2] = version_numbers[2] + 1 if options[:bumpBuild]
            version_numbers = options[:targetVersion].split(".").map { |x| x.to_i } if options[:targetVersion]

            new_version = Dnnbundler::formatVersion(version_numbers)
            puts "current version is #{current_version}"
            puts "new version is #{new_version}"

            data_hash["packages"].each do |package|
                package["name"].sub! "[PACKAGE_VERSION]", new_version
                Dnnbundler::replaceVersionInManifestFiles manifest_files, new_version

                generator = ZipFileGenerator.new(package)
                generator.write
            end
        end
    end

    def self.formatVersion(version)
        "#{version[0].to_s.rjust(4, "0")}.#{version[1].to_s.rjust(2, "0")}.#{version[2].to_s.rjust(4, "0")}"
    end
end
