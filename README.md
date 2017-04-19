# Dnnbundler

DNNBundler is intended to automate creation of zip packages for DotNetNuke.
Put your Ruby code in the file `lib/dnnbundler`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dnnbundler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dnnbundler

## Usage

To configure packaging create a json config with the following schema:

    {
        "packages": [
            {
                "name": "out.[PACKAGE_VERSION].zip", // [PACKAGE_VERSION] is a placeholder for package version which will be taken from manifest file
                "entries": [
                    "path_to_file",
                    "path_to_directory",             // real path in file system to file or directory
                    {
                        "type": "file",              // type of entry, if absent will be treated as 'file'
                        "name": "test.json",         // real path in file system to file or directory
                        "path": "new_path_in_zip"    // optional
                    },
                    {
                        "type": "zip",               // nested zip archive
                        "name": "test.zip",          // name of nested zip archive, can include directories. 'path' property is being ignored for this kind of entries
                        "ignoreEntries": [ ... ]     // local array of entries to ignore
                        "entries": [                 // array of entries for nested zip file, same format as above
                            "file",
                            "dir",
                            ...
                        ]
                    }
                ],
                "ignoreEntries": [
                    ".DS_Store"
                ]
            }
        ],
        "manifests": [
            "path_to_dnn_manifest"                   // dnn manifest file
        ]
    }

to create package run:

    dnnbundler build path_to_config.json

it is possible to increment build or sprint numbers:

    dnnbundler build path_to_config.json --bumpBuild
    dnnbundler build path_to_config.json --bumpSprint

it is also possible to specify custom version number:

    dnnbundler build path_to_config.json --targetVersion 2017.08.0004

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Le0Michine/dnnbundler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

