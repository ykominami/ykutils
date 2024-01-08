require "ykutils/version"

require "ykutils/datastructop"
require "ykutils/debugutils"
require "ykutils/erubyx"
require "ykutils/gridlist"
require "ykutils/fileoputils"
require "ykutils/filepermision"
require "ykutils/hasharray"
require "ykutils/lines"
require "ykutils/lsutils"
require "ykutils/nginxconfig"
require "ykutils/nginxconfigfiles"
require "ykutils/nkfutil"
require "ykutils/nkfutil19"
require "ykutils/osutil"
require "ykutils/pathop"
require "ykutils/retcodex"
require "ykutils/specfileop"
require "ykutils/stext"
require "ykutils/stextx"
require "ykutils/stringutils"
require "ykutils/treemanager"
require "ykutils/treemanagera"
require "ykutils/xlines"
require "ykutils/yamlop"
require "ykutils/yamlxop"

require "pathname"
module Ykutils
  TEST_DATA_DIR = "#{Pathname.new(__dir__).parent}test_data".freeze
  # Your code goes here...

  class YkutilsError < StandardError
  end
end
