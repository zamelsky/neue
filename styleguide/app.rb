require 'sinatra'
require 'sinatra/export'
require 'mustache'
require 'kss'
require 'json'
require 'redcarpet'

set :public_folder, Proc.new { File.join(root, "..") }
set :views, Proc.new { File.join(root) }

get '/' do
  @package = JSON.parse( File.read('package.json') )
  @version = "v#{@package["version"]}"

  @styleguide = Kss::Parser.new('scss/')
  erb :index
end

helpers do
  # Generates a styleguide block. A little bit evil with @_out_buf, but
  # if you're using something like Rails, you can write a much cleaner helper
  # very easily.
  def styleguide_block(section, &block)
    # Initializes a Markdown parser
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, highlight: true)

    @section = @styleguide.section(section)
    @description = markdown.render(@section.description)
    @link = @section.section.scan(/\d/)[0,3].join();
    @example_html = capture{ block.call }
    @escaped_html = ERB::Util.html_escape @example_html
    @_out_buf << erb(:_styleguide_block)
  end

  # Captures the result of a block within an erb template without spitting it
  # to the output buffer.
  def capture(&block)
    out, @_out_buf = @_out_buf, ""
    yield
    @_out_buf
  ensure
    @_out_buf = out
  end

  # @EXPERIMENTAL: Render Mustache UI component
  def neue_component(path, *args)
    @template = File.open("components/#{path}.mustache") { |f| f.read }

    Mustache.render(@template, *args)
  end

  def styleguide_component(section, component, *args)
    # Initializes a Markdown parser
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, highlight: true)

    @section = @styleguide.section(section)
    @description = markdown.render(@section.description)
    @link = @section.section.scan(/\d/)[0,3].join();

    @example_html = neue_component(component, *args)
    @example_js = "neue_component(\"#{component}\", #{args.join(", ")});"
    @example_ruby = "neue_component(\"#{component}\", #{args.join(", ")[1..-1]})"
    @example_php = "neue_component(\"#{component}\", array( #{args.join(", ")[1..-1]}) );"

    @escaped_html = ERB::Util.html_escape @example_html
    @escaped_js = ERB::Util.html_escape @example_js
    @escaped_ruby = ERB::Util.html_escape @example_ruby
    @escaped_php = ERB::Util.html_escape @example_php
    erb :_styleguide_component
  end
end

