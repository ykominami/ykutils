# frozen_string_literal: true

RSpec.describe Ykutils do
  it "has a version number" do
    expect(Ykutils::VERSION).not_to be nil
  end

  #  it "does something useful" do
  #    expect(false).to eq(true)
  #  end
  describe "Ykutils::Erubyx" do
    before(:all) do
      base_dir = "v103-3-189-127"
      @base_dir = Ykutils::TEST_DATA_DIR + base_dir
    end

    it "make_grid_list", version: true do
      expect(Ykutils::VERSION).not_to be nil
    end

    it "make_grid", grid: true do
      min_row = 1
      max_row = 2
      min_colum = 1
      max_colum = 5
      expect(Ykutils::Gridlist::make_grid_list(min_row, max_row, min_colum, max_colum).instance_of?(Array)).to be true
    end

    def make_path_complement(path)
      @base_dir + path
    end

    it "Ykutils::Nginxconfigfiles", nginx: true do
      ncf = Ykutils::Nginxconfigfiles.new
      re = /base.yml$/
      dir = "a.northern-cross.net"
      start_dir = make_path_complement(dir)
      file_list = ncf.get_file_list(start_dir, re)
      ncf.output(file_list)
    end

    it "Erubyx::erubi_render_with_file", rubyx: true do
      template_file_path = make_path_complement("template_ssl_www.erb")

      scope = nil
      ary = ["a.northern-cross.net/value_host.yml", "value_ssl.yml"]
      value_file_path_array = ary.reduce([]) { |list, path|
        list << make_path_complement(path)
        list
      }

      content = Ykutils::Erubyx::erubi_render_with_file(template_file_path, scope, value_file_path_array)
      expect(content).to_not be_nil
    end
  end
end
