require 'test_helper'
require 'webmock/minitest'
require 'base64'

# $ rake test:unit TEST=test/unit/android/device/mjsonwp/commands_test.rb
class AppiumLibCoreTest
  module Android
    module Device
      module MJSONWP
        class DeviceLockTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(self, Caps.android)
            @driver ||= android_mock_create_session
          end

          def test_device_locked?
            stub_request(:post, "#{SESSION}/appium/device/is_locked")
              .to_return(headers: HEADER, status: 200, body: { value: 'true' }.to_json)

            @driver.device_locked?

            assert_requested(:post, "#{SESSION}/appium/device/is_locked", times: 1)
          end

          def test_unlock
            stub_request(:post, "#{SESSION}/appium/device/unlock")
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.unlock

            assert_requested(:post, "#{SESSION}/appium/device/unlock", times: 1)
          end

          def test_lock
            stub_request(:post, "#{SESSION}/appium/device/lock")
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.lock 5

            assert_requested(:post, "#{SESSION}/appium/device/lock", times: 1)
          end
        end # class DeviceLockTest
      end # module MJSONWP
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
