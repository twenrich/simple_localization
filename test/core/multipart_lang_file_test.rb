require File.dirname(__FILE__) + '/../test_helper'

# Load the specified language file and no features
simple_localization :lang_file_dir => LANG_FILE_DIR, :language => [:de, :en], :only => []

class MultipartLangFileTest < Test::Unit::TestCase
  
  def setup
    @lang_files = load_language_file_contents
    @lang = ArkanisDevelopment::SimpleLocalization::Language
    @lang.use :en
    raise @lang.entry!(:tests).inspect
  end
  
  def test_proper_loading
    assert_equal @lang_files['de']['about']['language'], @lang.entry(:about, :language)
    assert_equal @lang_files['de.countries'], @lang.entry(:countries)
    assert_equal @lang_files['de.app.about']['description'], @lang.entry(:app, :about, :description)
  end
  
end
