prefix = File.dirname(__FILE__) + "/"
$LOAD_PATH.unshift prefix

module Lingua
  module EN
    module Readable
      module Flesch
      end
      module FleschKinkaid
      end
      module Fog
      end
    end
    module Paragraph
    end
    module Sentence
    end
    module Syllable 
    end
  end
end

Dir.glob(prefix + "**/*.rb").each do |f|
  require File.expand_path(f)
end
