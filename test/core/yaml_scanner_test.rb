require File.dirname(__FILE__) + '/../test_helper'

class YamlScannerTest < Test::Unit::TestCase
  
  def setup
    # init
  end
  
  protected
  
  def some_complex_test_yaml
    test_code = <<'EOY'
test:
  a:
    b: text
    'q1':
      empty: nothing
    "q2":
      empty: nothing
test2:
  x:
   - entry1
   - entry2
   - entry3
  x2: |
    this is test text
  x3: {inline: hash}
  a:
    empty: nothing
empty:

EOY
  end
  
end
