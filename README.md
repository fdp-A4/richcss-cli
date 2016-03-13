# Richcss-cli

Richcss CLI is a tool to manage your CSS using the RichCSS framework.
It also includes a package manager to help install and create your own RichCSS parts for others to use.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'richcss'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install richcss


## Usage

### Using RichCSS in your project

To start, in the directory where you want to put all your CSS, run  

    $ richcss init

to create the skeleton structure.

#### Using RichCSS parts

In the directory created using `richcss init`, you can install third-party parts using

    $ richcss install <PART> [VERSION]

The version is optional and will default to the latest version of that part.

### Creating your own RichCSS Part

Generate the necessary files for your Part with

    $ richcss part init <PART_NAME>

#### Publishing your Part for others to use

Before releasing your Part to the public, you may run

    $ richcss part check [PART_PATH]

to make sure everything is valid. Then publish it to CSSParts with

    $ richcss part push <PART_NAME> 


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fdp-A4/richcss-cli


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

