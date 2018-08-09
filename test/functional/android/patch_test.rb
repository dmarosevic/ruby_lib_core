require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/patch_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  class PathTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @@core ||= ::Appium::Core.for(self, Caps.android)
      @@driver ||= @@core.start_driver

      @@driver.start_activity app_package: 'io.appium.android.apis',
                              app_activity: 'io.appium.android.apis.ApiDemos'
    end

    def teardown
      save_reports(@@driver)
    end

    def test_method_missing_attributes
      e = @@core.wait { @@driver.find_element :accessibility_id, 'App' }

      assert_equal 'App', e.text
      assert_equal 'App', e.enabled
      assert_equal 'App', e.focused
      assert_equal 'App', e.content_desc
    end

    def test_type
      @@core.wait { @@driver.find_element :accessibility_id, 'App' }.click
      @@core.wait { @@driver.find_element :accessibility_id, 'Activity' }.click
      @@core.wait { @@driver.find_element :accessibility_id, 'Custom Title' }.click

      @@core.wait { @@driver.find_element :id, 'io.appium.android.apis:id/left_text_edit' }.type 'Pökémön'

      text = @@core.wait { @@driver.find_element :id, 'io.appium.android.apis:id/left_text_edit' }
      assert_equal 'Left is bestPökémön', text.text
    end

    def test_location_rel
      e = @@core.wait { @@driver.find_element :accessibility_id, 'App' }
      location = e.location_rel(@@driver)

      assert_match %r{\A[0-9]+\.[0-9]+ \/ [0-9]+\.[0-9]+\z}, location.x
      assert_match %r{\A[0-9]+\.[0-9]+ \/ [0-9]+\.[0-9]+\z}, location.y
    end
  end
end
