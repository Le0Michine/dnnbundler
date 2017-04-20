require "dnnbundler/packageVersionReplacer"
require "dnnbundler/jsonConfig"
require "thor"
require "json"
require "zipper"

module Dnnbundler
    class CLI < Thor
        desc "build CONFIG [options]", "creates a zip package according to given configuration file"
        option :bumpBuild
        option :bumpSprint
        option :targetVersion, :type => :string
        def build( config )
            puts "Build with config #{config}"
            file = File.read(config)
            json_config = JSON.parse(file)

            manifest_files = json_config[JsonConfig::Manifests]
            current_version = Dnnbundler::getVersionFromManifest manifest_files[0]
            version_numbers = Dnnbundler::splitVersionNumbers current_version

            version_numbers[1] = version_numbers[1] + 1 if options[:bumpSprint]
            version_numbers[2] = 1 if options[:bumpSprint]
            version_numbers[2] = version_numbers[2] + 1 if options[:bumpBuild]
            version_numbers = Dnnbundler::splitVersionNumbers(options[:targetVersion]) if options[:targetVersion]

            new_version = Dnnbundler::formatVersion(version_numbers)
            puts "current version is #{current_version}"
            puts "new version is #{new_version}"

            json_config[JsonConfig::Packages].each do |package|
                package[JsonConfig::Name].sub!(JsonConfig::PackageVersionPlaceholder, new_version)
                Dnnbundler::replaceVersionInManifestFiles manifest_files, new_version

                generator = Zipper::ZipFileGenerator.new(package)
                generator.write
            end
        end
    end

    # converts version numbers array into string <year>.<sprint>.<build>
    # Params:
    # +version+:: integer array: [year, sprint, build]
    def self.formatVersion(version)
        "#{version[0].to_s.rjust(4, "0")}.#{version[1].to_s.rjust(2, "0")}.#{version[2].to_s.rjust(4, "0")}"
    end

    # splits string version into integers
    # Params:
    # +version_string+:: string version, format is dot separated numbers <year>.<sprint>.<build>
    def self.splitVersionNumbers(version_string)
        version_string.split(".").map { |x| x.to_i }
    end
end
