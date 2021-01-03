# frozen_string_literal: true

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/driver_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  class DriverTest < AppiumLibCoreTest::Function::TestCase
    private

    def alert_view_cell
      over_ios13?(@@driver) ? 'Alert Controller' : 'Alert Views'
    end

    def uicatalog
      over_ios13?(@@driver) ? 'UIKitCatalog' : 'UICatalog'
    end

    public

    def setup
      @@core = ::Appium::Core.for(Caps.ios)
      @@driver = @@core.start_driver

      require 'pry'
      binding.pry
    end

    def teardown
      save_reports(@@driver)
    end

    def test_appium_server_version
      v = @@core.appium_server_version

      refute_nil v['build']['version']
    end

    def test_platform_version
      # Just make sure the value is not nil
      assert @@core.platform_version
    end

    def test_screenshot
      file = @@core.screenshot 'ios_test.png'

      assert File.exist?(file.path)

      File.delete file.path
      assert !File.exist?(file.path)
    end

    def test_wait_true
      e = @@core.wait_true { @@driver.find_element :accessibility_id, uicatalog }
      assert e.name
    end

    def test_wait
      e = @@core.wait { @@driver.find_element :accessibility_id, uicatalog }
      assert_equal uicatalog, e.name
    end

    def test_click_back
      skip_as_appium_version '1.8.0' # 1.7.2- have a bit different behaviour

      e = @@driver.find_element :accessibility_id, alert_view_cell
      e.click
      sleep 1 # wait for animation
      if over_ios13?(@@driver)
        begin
          e.click # nothing happens
        rescue ::Selenium::WebDriver::Error::StaleElementReferenceError
          # This case also could happen
          assert true
        end
      else
        error = assert_raises do
          e.click
        end
        assert [::Selenium::WebDriver::Error::UnknownError,
                ::Selenium::WebDriver::Error::ElementNotVisibleError,
                ::Selenium::WebDriver::Error::InvalidSelectorError].include? error.class
        assert error.message.include? ' is not visible on the screen and thus is not interactable'
      end
      @@driver.back
    end

    # @since Appium 1.15.0
    def test_default_keyboard_pref
      skip_as_appium_version '1.15.0'

      bundle_id = @@driver.session_capabilities['CFBundleIdentifier']
      begin
        @@driver.terminate_app('com.apple.Preferences') # To ensure the app shows the top view
        @@driver.activate_app('com.apple.Preferences')
        @@driver.find_element(:accessibility_id, 'General').click
        @@driver.find_element(:accessibility_id, 'Keyboard').click

        eles = @@driver.find_elements :class, 'XCUIElementTypeSwitch'
        switches_status = eles.each_with_object({}) { |e, acc| acc[e.name] = e.value }
      ensure
        @@driver.activate_app(bundle_id)
      end
      assert_equal '0', switches_status['Auto-Correction']
      assert_equal '0', switches_status['Predictive']
    end

    # @since Appium 1.15.0
    def test_batch
      skip_as_appium_version '1.15.0'

      script = <<~SCRIPT
        const status = await driver.status();
        console.warn('warning message');
        return [status];
      SCRIPT

      r = @@driver.execute_driver(script: script, type: 'webdriverio', timeout_ms: 10_000)
      assert(r.result.first['build'])
      assert('warning message', r.logs['warn'].first)
    end

    # @since Appium 1.15.0
    def test_batch_only_return
      skip_as_appium_version '1.15.0'

      script = <<-SCRIPT
      SCRIPT

      r = @@driver.execute_driver(script: script, type: 'webdriverio')
      assert(r.result.nil?)
      assert([], r.logs['warn'])
    end

    # @since Appium 1.15.0
    def test_batch_combination_ruby_script
      skip_as_appium_version '1.15.0'

      script = <<~SCRIPT
        console.warn('warning message');
        const element = await driver.findElement('accessibility id', 'Buttons');
        const rect = await driver.getElementRect(element.ELEMENT);
        return [element, rect];
      SCRIPT

      r = @@driver.execute_driver(script: script)
      ele = @@driver.convert_to_element(r.result.first)
      rect = ele.rect
      assert_equal(rect.x, r.result[1]['x'])
      assert_equal(rect.y, r.result[1]['y'])
      assert_equal(rect.width, r.result[1]['width'])
      assert_equal(rect.height, r.result[1]['height'])
    end

    # TODO: call @driver.quit after tests
  end
end
# rubocop:enable Style/ClassVars
