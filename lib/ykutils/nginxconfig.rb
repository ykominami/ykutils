module Ykutils
  class Nginxconfig
    def initialize(yaml_path)
      #p "yaml_path=#{yaml_path}"
      yaml_pn = Pathname.new(yaml_path).cleanpath
      @virtual_domain_dir_pn = yaml_pn.parent
      @server_dir_pn = @virtual_domain_dir_pn.parent
      @common_dir_pn = @server_dir_pn.parent
      @hash = YAML.load_file(yaml_pn)
      #p @hash
      @root = @hash["_root"]
      #p @root
      root_template_0_pn = Pathname.new(@root["template"]).cleanpath
      @root_template_pn = @common_dir_pn + root_template_0_pn
      # puts "@root_template_pn=#{@root_template_pn}"
    end

    def extract(scope)
      hashx = {}
      @hash.each do |k, v|
        if k !~ /^_/
          # puts k
          #puts v
          pn = Pathname.new(v["template"]).cleanpath
          #Pathname.new(v).cleanpath
          template_pn = @server_dir_pn + pn
          # puts(template_pn)
          value_file_path_array = v["value"].map{|x|
            @virtual_domain_dir_pn + Pathname.new(x).cleanpath
          }
          hashx[k] = Ykutils::Erubyx::erubi_render_with_file(template_pn, scope, value_file_path_array)
        end
      end
      template = File.read(@root_template_pn)
      template_hash = { TEMPLATE: template,
        OBJ: nil
      }
      Ykutils::Erubyx::erubi_render(template_hash, scope, hashx)
    end
  end
end
