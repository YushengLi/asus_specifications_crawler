require 'watir'
require 'highline'

class ProductCrawler
  attr_accessor :group, :series, :url, :browser

  def initialize
    cli = HighLine.new
    group_name  = cli.ask "What's the Group name you want to fetch?\n"
    @group   = Group.find_or_create_by(name: group_name)
    series_name = cli.ask "What's the Series name you want to fetch?\n"
    @series  = Series.find_or_create_by(name: series_name, group_id: @group.id)
    @url     = cli.ask "What's the URL to fetch?"
    @browser = Watir::Browser.new
    screen_width  = @browser.execute_script("return screen.width;")
    screen_height = @browser.execute_script("return screen.height;")
    @browser.driver.manage.window.resize_to(screen_width,screen_height)
    @browser.driver.manage.window.move_to(0,0)
    @browser.goto @url
    @pages = []
  end

  def extract_product_links
    @product_links = []
    @browser.div(class: 'hot-product-unit').wait_until_present
    morePage = false
    # Handle Pagination
    begin
      if @browser.div(class: 'pagination btn-group pull-right').exists?
        @product_links += @browser.divs(class: 'hot-product-unit').map{ |x| x.as.first.href }
        extract_pages
        @browser.goto @url
        @pages.each do |page|
          @browser.div(class: 'pagination btn-group pull-right').a(text: page).click
          @browser.div(class: 'hot-product-unit').wait_until_present
          sleep 2
          @product_links += @browser.divs(class: 'hot-product-unit').map{ |x| x.link.href }
        end
        @product_links
      else
        @product_links += @browser.divs(class: 'hot-product-unit').map{ |x| x.as.first.href }
      end
    rescue => e
      binding.pry
    end
  end

  def extract_specifications
    extract_product_links
    @product_links.each do |product|
      # Go to Product Specification Page
      @browser.goto product+'specifications'
      # Extract Model Name
      @browser.span(id: 'ctl00_ContentPlaceHolder1_ctl00_span_model_name').wait_until_present
      model_name       = @browser.span(id: 'ctl00_ContentPlaceHolder1_ctl00_span_model_name').text
      # 作業系統
      begin
        @browser.span(class: 'spec-item', text: 'Operating System').element(:xpath => './following-sibling::*').wait_until_present
        @browser.screenshot.save "#{Nrb.root}/public/screenshots/#{model_name}_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.png"
      rescue => e
        @browser.screenshot.save "#{Nrb.root}/public/screenshots/[Error]_#{model_name}_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.png"
      end
      operating_system = @browser.span(class: 'spec-item', text: 'Operating System').element(:xpath => './following-sibling::*').text rescue nil
      # 光學設備
      optical_device   = @browser.span(class: 'spec-item', text: 'Optical Drive').element(:xpath => './following-sibling::*').text rescue nil
      # 音效
      audio            = @browser.span(class: 'spec-item', text: 'Audio').element(:xpath => './following-sibling::*').text rescue nil
      # 隨附軟體
      software         = @browser.span(class: 'spec-item', text: 'Software').element(:xpath => './following-sibling::*').text rescue nil
      Specification.create(
        name: model_name,
        operating_system: operating_system,
        optical_device: optical_device,
        audio: audio,
        software: software,
        source_url: @browser.url,
        series: @series
      )
    end
  end

  def extract_pages
    if @browser.div(class: 'pagination btn-group pull-right').ul.lis.to_a.slice!(1...-1).first.link(text: '...').exist?
      @pages += @browser.div(class: 'pagination btn-group pull-right').ul.lis.to_a.slice!(3...-1).map { |page| page.link.text  }
      if @browser.div(class: 'pagination btn-group pull-right').ul.lis.to_a.slice!(2...-1).last.link(text: '...').exist?
        @pages << '...'
        @browser.div(class: 'pagination btn-group pull-right').ul.lis.link(text: '...').click
        @browser.div(class: 'pagination btn-group pull-right').wait_until_present
        extract_pages
      end
      @pages
    elsif @browser.div(class: 'pagination btn-group pull-right').ul.lis.to_a.slice!(2...-1).last.link(text: '...').exist?
      @pages += @browser.div(class: 'pagination btn-group pull-right').ul.lis.to_a.slice!(2...-1).map { |page| page.link.text  }
      @browser.div(class: 'pagination btn-group pull-right').ul.link(text: '...').click
      @browser.div(class: 'pagination btn-group pull-right').wait_until_present
      extract_pages
    else
      @pages += @browser.div(class: 'pagination btn-group pull-right').ul.lis.to_a.slice!(2...-1).map { |page| page.link.text  }
    end
  end
end
