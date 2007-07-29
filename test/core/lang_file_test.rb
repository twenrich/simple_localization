require File.dirname(__FILE__) + '/../test_helper'

class LangFileTest < Test::Unit::TestCase
  
  def setup
    @lang_file_root_dir = File.join(File.dirname(__FILE__), 'lang_file_test')
    @lang_file_dirs = %w(sl_languages another_lang_dir rails_app_languages).collect do |lang_file_dir|
      File.join(@lang_file_root_dir, lang_file_dir)
    end
    @lang_file = ArkanisDevelopment::SimpleLocalization::LangFile.new :en, @lang_file_dirs
    
  end
  
  def test_lookup_parts
    assert_equal @lang_file_dirs, @lang_file.lang_file_dirs
    yaml_parts, ruby_parts = @lang_file.send :lookup_parts
    
    expected_yaml_parts = {
      File.join(@lang_file_root_dir, 'sl_languages') => %w(en.yml en.part.yml en.empty.yml),
      File.join(@lang_file_root_dir, 'another_lang_dir') => %w(en.app.my_plugin.yml),
      File.join(@lang_file_root_dir, 'rails_app_languages') => %w(en.app.yml en.part.yml)
    }
    assert_equal expected_yaml_parts.keys.sort.collect{|dir| File.expand_path(dir)}, yaml_parts.keys.sort.collect{|dir| File.expand_path(dir)}
    expected_yaml_parts.each do |lang_dir, lang_files|
      assert_equal lang_files.sort, yaml_parts[lang_dir].sort
    end
    
    expected_ruby_part_order = %w(sl_languages/en.rb rails_app_languages/en.rb).collect do |part|
      File.join(@lang_file_root_dir, part)
    end
    assert_equal expected_ruby_part_order, ruby_parts
  end
  
  def test_sort_yaml_parts_for_loading
    yaml_parts, ruby_parts = @lang_file.send :lookup_parts
    ordered_yaml_parts = @lang_file.send :sort_yaml_parts_for_loading, yaml_parts
    
    expected_part_order = [
      File.join(@lang_file_root_dir, 'sl_languages', 'en.yml'),
      File.join(@lang_file_root_dir, 'sl_languages', 'en.part.yml'),
      File.join(@lang_file_root_dir, 'sl_languages', 'en.empty.yml'),
      File.join(@lang_file_root_dir, 'another_lang_dir', 'en.app.my_plugin.yml'),
      File.join(@lang_file_root_dir, 'rails_app_languages', 'en.app.yml'),
      File.join(@lang_file_root_dir, 'rails_app_languages', 'en.part.yml')
    ]
    assert_equal expected_part_order.collect{|f| File.expand_path(f)}, ordered_yaml_parts.collect{|f| File.expand_path(f)}
  end
  
  def test_sort_yaml_parts_for_writing
    yaml_parts, ruby_parts = @lang_file.send :lookup_parts
    ordered_yaml_parts = @lang_file.send :sort_yaml_parts_for_writing, yaml_parts
    
    expected_part_order = [
      File.join(@lang_file_root_dir, 'another_lang_dir', 'en.app.my_plugin.yml'),
      File.join(@lang_file_root_dir, 'rails_app_languages', 'en.app.yml'),
      File.join(@lang_file_root_dir, 'rails_app_languages', 'en.part.yml'),
      File.join(@lang_file_root_dir, 'sl_languages', 'en.part.yml'),
      File.join(@lang_file_root_dir, 'sl_languages', 'en.empty.yml'),
      File.join(@lang_file_root_dir, 'sl_languages', 'en.yml')
    ]
    assert_equal expected_part_order.collect{|f| File.expand_path(f)}, ordered_yaml_parts.collect{|f| File.expand_path(f)}
  end
  
  def test_load
    assert @lang_file.data.empty?, "The data of the language file isn't empty"
    $LANG_FILE_RUBY_PARTS_LOADED = []
    @lang_file.load
    
    assert !@lang_file.data.empty?, 'After loading all parts the language file data is still empty'
    assert_equal File.expand_path(File.join(@lang_file_root_dir, 'sl_languages', 'en.rb')), File.expand_path($LANG_FILE_RUBY_PARTS_LOADED.first)
    assert_equal File.expand_path(File.join(@lang_file_root_dir, 'rails_app_languages', 'en.rb')), File.expand_path($LANG_FILE_RUBY_PARTS_LOADED[1])
    
    yaml_part_data = load_all_yaml_parts_into_a_hash
    assert_equal yaml_part_data['sl_languages/en.yml']['base'], @lang_file.data['base']
    assert_equal yaml_part_data['sl_languages/en.part.yml']['sl_languages'], @lang_file.data['part', 'sl_languages']
    assert_equal yaml_part_data['rails_app_languages/en.part.yml']['rails_app_languages'], @lang_file.data['part', 'rails_app_languages']
    assert_equal yaml_part_data['rails_app_languages/en.part.yml']['description'], @lang_file.data['part', 'description']
    assert_equal yaml_part_data['rails_app_languages/en.app.yml']['title'], @lang_file.data['app', 'title']
    assert_equal yaml_part_data['another_lang_dir/en.app.my_plugin.yml']['title'], @lang_file.data['app', 'my_plugin', 'title']
  end
  
  def test_reload
    @lang_file.load
    
    new_lang_file = File.join(@lang_file_root_dir, 'rails_app_languages', 'en.yml')
    new_lang_file_content = { 'base' => 'overwritten', 'new' => 'added entry' }
    File.open(new_lang_file, 'wb') do |f|
      f.write YAML.dump(new_lang_file_content)
    end
    
    begin
      updated_memory_value = 'changed this entry in the memory data'
      new_memory_value = 'added this entry only in memory'
      @lang_file.data['base'] = updated_memory_value
      @lang_file.data['new_mem'] = new_memory_value
      
      assert_equal updated_memory_value, @lang_file.data['base']
      assert_equal new_memory_value, @lang_file.data['new_mem']
      assert_raises ArkanisDevelopment::SimpleLocalization::EntryNotFound do
        @lang_file.data['new']
      end
      
      @lang_file.reload
      
      assert_equal new_lang_file_content['base'], @lang_file.data['base']
      assert_equal new_lang_file_content['new'], @lang_file.data['new']
      assert_equal new_memory_value, @lang_file.data['new_mem']
    ensure
      File.delete new_lang_file
    end
  end
  
  def test_find_part_for_new_entry
    @lang_file.load
    
    new_entry_keys_to_target_part_mapping = {
      %w(app new) => [File.join('rails_app_languages', 'en.app.yml'), %w(new)],
      %w(part new) => [File.join('rails_app_languages', 'en.part.yml'), %w(new)],
      %w(app my_plugin new) => [File.join('another_lang_dir', 'en.app.my_plugin.yml'), %w(new)],
      %w(empty new) => [File.join('sl_languages', 'en.empty.yml'), %w(new)],
      %w(empty test x) => [File.join('sl_languages', 'en.empty.yml'), %w(test x)],
      %w(just new) => [File.join('sl_languages', 'en.yml'), %w(just new)]
    }
    
    new_entry_keys_to_target_part_mapping.each do |new_entry_keys, expected_results|
      expected_target_part = File.join(@lang_file_root_dir, expected_results.first)
      expected_remaining_keys = expected_results.last
      
      actual_target_part, actual_remaining_keys = @lang_file.send(:find_part_for_new_entry, new_entry_keys)
      assert_kind_of String, actual_target_part
      assert_equal expected_remaining_keys, actual_remaining_keys
      assert_equal File.expand_path(expected_target_part), File.expand_path(actual_target_part),
        "The new entry #{new_entry_keys.inspect} was maped to #{expected_target_part.inspect} but #{actual_target_part.inspect} was calculated"
    end
  end
  
  def test_reconstruct_yaml_key
    yaml_code = <<-EOY
      - test1
      - 'test''2'
      - "test3"
    EOY
    parsed_yaml_nodes = YAML.parse(yaml_code).value.to_a
    
    assert_equal 'test1', parsed_yaml_nodes[0].value
    assert_equal "test'2", parsed_yaml_nodes[1].value
    assert_equal 'test3', parsed_yaml_nodes[2].value
    
    assert_equal 'test1', @lang_file.send(:reconstruct_yaml_key, parsed_yaml_nodes[0])
    assert_equal "'test''2'", @lang_file.send(:reconstruct_yaml_key, parsed_yaml_nodes[1])
    assert_equal '"test3"', @lang_file.send(:reconstruct_yaml_key, parsed_yaml_nodes[2])
  end
  
  def test_find_line_for_new_entry_with_empty_part
    yaml_code = ''
    assert_equal [0, 0, %w(new)], @lang_file.send(:find_line_for_new_entry, %w(new), yaml_code)
  end
  
  def test_find_line_for_new_entry_with_small_part
    yaml_code = "test:\n"
    assert_equal [1, 0, %w(new)], @lang_file.send(:find_line_for_new_entry, %w(new), yaml_code)
    assert_equal [1, 1, %w(new)], @lang_file.send(:find_line_for_new_entry, %w(test new), yaml_code)
  end
  
  def test_find_line_with_existing_entry
    yaml_code = 'test: I am here'
    assert_raises ArkanisDevelopment::SimpleLocalization::EntryAlreadyExistsError do
      @lang_file.send(:find_line_for_new_entry, %w(test), yaml_code)
    end
  end
  
  def test_find_line_for_new_entry
    yaml_code = some_complex_test_yaml
    assert_equal [16, 0, %w(new)], @lang_file.send(:find_line_for_new_entry, %w(new), yaml_code)
    assert_equal [7, 1, %w(x)], @lang_file.send(:find_line_for_new_entry, %w(test x), yaml_code)
    assert_equal [7, 2, %w(c)], @lang_file.send(:find_line_for_new_entry, %w(test a c), yaml_code)
    assert_equal [5, 3, %w(new)], @lang_file.send(:find_line_for_new_entry, %w(test a q1 new), yaml_code)
    assert_equal [5, 3, %w(new a b)], @lang_file.send(:find_line_for_new_entry, %w(test a q1 new a b), yaml_code)
    assert_equal [7, 3, %w(new)], @lang_file.send(:find_line_for_new_entry, %w(test a q2 new), yaml_code)
    assert_equal [15, 1, %w(x4 new)], @lang_file.send(:find_line_for_new_entry, %w(test2 x4 new), yaml_code)
    
    # That the following line works is acutally an error. The aim is to add a
    # new key to an inline hash but inline hashes are not supported. However
    # since the output is invalid YAML an ProducedInvalidYamlError error will be
    # raised. So we at least know that this error is still around...
    assert_equal [15, 2, %w(new)], @lang_file.send(:find_line_for_new_entry, %w(test2 x3 new), yaml_code)
  end
  
  def test_create_key
    test_data = YAML.load some_complex_test_yaml
    test_file = File.join(@lang_file_root_dir, 'sl_languages', 'en.create.yml')
    File.open(test_file, 'wb') {|f| f.write some_complex_test_yaml }
    
    begin
      @lang_file.load
      assert_equal test_data['test2']['x2'], @lang_file.data['create', 'test2', 'x2']
      
      assert_nothing_raised do @lang_file.create_key %w(create test x) end
      assert_nil YAML.load_file(test_file)['test']['x']
      
      assert_nothing_raised do @lang_file.create_key %w(create test new), 'new val' end
      assert_equal 'new val', YAML.load_file(test_file)['test']['new']
      
      assert_nothing_raised do @lang_file.create_key %w(create new_section a b c), 'new val' end
      assert_equal 'new val', YAML.load_file(test_file)['test']['new']
      
      assert_nothing_raised do @lang_file.create_key %w(create test a q1 new), 'new val' end
      assert_equal 'new val', YAML.load_file(test_file)['test']['a']['q1']['new']
    ensure
      File.delete test_file
    end
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
empty:

EOY
    assert_nothing_raised do YAML.load test_code end
    test_code
  end
  
  def load_all_yaml_parts_into_a_hash
    expanded_root_dir = File.expand_path(@lang_file_root_dir)
    file_hash = {}
    Dir.glob(File.join(@lang_file_root_dir, '**', '*.yml')).each do |part|
      key = File.expand_path(part).gsub("#{expanded_root_dir}/", '')
      file_hash[key] = YAML.load_file(part)
    end
    file_hash
  end
  
  
=begin
  def test_simple_loading
    lang_file = ArkanisDevelopment::SimpleLocalization::LangFile.new LANG_FILE_DIR, :en
    assert_equal LANG_FILE_DIR, lang_file.lang_dir
    assert_equal :en, lang_file.lang_code
    assert_kind_of ArkanisDevelopment::SimpleLocalization::NestedHash, lang_file.data
    assert lang_file.data.empty?, 'Language data should be empty because the lang file is not yet loaded, but it contains data.'
    
    lang_file.load
    assert_kind_of ArkanisDevelopment::SimpleLocalization::NestedHash, lang_file.data
    assert_equal 'English', lang_file.data['about', 'language']
  end
  
  def test_multipart_loading
    lang_file = ArkanisDevelopment::SimpleLocalization::LangFile.new LANG_FILE_DIR, :de
    lang_file.load
    assert_equal @lang_files['de']['about']['language'], lang_file.data['about', 'language']
    assert_equal @lang_files['de.app.about']['title'], lang_file.data['app', 'about', 'title']
    assert_equal @lang_files['de.countries']['Germany'], lang_file.data['countries', 'Germany']
  end
  
  def test_save
    with_copied_lang_files do |lang_dir_for_test|
      
      lang_file = ArkanisDevelopment::SimpleLocalization::LangFile.new lang_dir_for_test, :de
      lang_file.load
      
      lang_file.data['about', 'language'] = 'Deutsch geändert'
      lang_file.data['app', 'about', 'title'] = 'Titel geändert'
      lang_file.data['countries', 'Germany'] = 'Deutschland geändert'
      lang_file.save
      
      de_data = YAML.load_file("#{lang_dir_for_test}/de.yml")
      de_app_about_data = YAML.load_file("#{lang_dir_for_test}/de.app.about.yml")
      de_countries_data = YAML.load_file("#{lang_dir_for_test}/de.countries.yml")
      
      assert_equal 'Deutsch geändert', de_data['about']['language']
      assert_nil de_data['app']['about']
      assert_nil de_data['countries']
      assert_equal 'Titel geändert', de_app_about_data['title']
      assert_nil de_app_about_data['about']
      assert_nil de_app_about_data['app']
      assert_nil de_app_about_data['countries']
      assert_equal 'Deutschland geändert', de_countries_data['Germany']
      assert_nil de_countries_data['about']
      assert_nil de_countries_data['app']
      
    end
  end
  
  def test_reload
    with_copied_lang_files do |lang_dir_for_test|
      
      lang_file = ArkanisDevelopment::SimpleLocalization::LangFile.new lang_dir_for_test, :de
      lang_file.load
      
      # Add a new entry and edit an entry of the memory data
      lang_file.data['app', 'test', 'new_from_mem'] = 'Neuer Eintrag (in memory)'
      lang_file.data['app', 'test', 'section'] = 'Geänderte Zeichenkette (in memory)'
      
      # Add a new entry and an changed entry to the base lang file
      file_data = YAML.load_file "#{lang_dir_for_test}/de.yml"
      file_data['app']['test']['new_from_file'] = 'Neuer Eintrag (in file)'
      file_data['app']['test']['section'] = 'Geänderte Zeichenkette (in file)'
      File.open("#{lang_dir_for_test}/de.yml", 'wb'){|f| YAML.dump(file_data, f)}
      
      assert_equal 'Neuer Eintrag (in memory)', lang_file.data['app', 'test', 'new_from_mem']
      assert_equal 'Geänderte Zeichenkette (in memory)', lang_file.data['app', 'test', 'section']
      
      lang_file.reload
      
      assert_equal 'Neuer Eintrag (in memory)', lang_file.data['app', 'test', 'new_from_mem']
      assert_equal 'Neuer Eintrag (in file)', lang_file.data['app', 'test', 'new_from_file']
      assert_equal 'Geänderte Zeichenkette (in file)', lang_file.data['app', 'test', 'section']
      
    end
  end
  
  protected
  
  def with_copied_lang_files(temp_dir = nil)
    temp_dir = "#{File.dirname(__FILE__)}/lang_files_for_running_test" unless temp_dir
    FileUtils.cp_r LANG_FILE_DIR, temp_dir
    yield temp_dir
    FileUtils.rm_r temp_dir
  end
=end
  
end
