require 'spec_helper'
require 'capistrano/shared_config/config_file'

describe Capistrano::SharedConfig::ConfigFile do
  describe '.name' do
    it 'should use .yml extension by default' do
      described_class.name('test').should == 'test.yml'
    end

    it 'should not override known extensions' do
      described_class.name('test.yml').should == 'test.yml'
      described_class.name('test.rb').should == 'test.rb'
      described_class.name('test.conf').should == 'test.conf'
      described_class.name('test.pem').should == 'test.pem'
      described_class.name('test.ppk').should == 'test.ppk'
    end
  end

  describe '#location' do
    before do
      File.stub(:exists?).and_return(false)
      File.stub(:exists?).with('./config/production.config.yml').and_return(true)
      File.stub(:exists?).with('./config/development.config.yml.erb').and_return(true)
      File.stub(:exists?).with('./config/config.yml').and_return(true)
    end

    it 'should find local config with given environment' do
      rails_env = 'staging'
      described_class.new('config.yml', binding).location.should == './config/config.yml'

      rails_env = 'production'
      described_class.new('config.yml', binding).location.should == './config/production.config.yml'

      rails_env = 'development'
      described_class.new('config.yml', binding).location.should == './config/development.config.yml.erb'
    end
  end

  describe '#content' do
    let(:file_content) do
      <<-YAML
      staging:
        test: 1
        path: <%= deploy_to %>
      YAML
    end

    before do
      File.stub(:read).and_return(file_content)
    end

    it 'should eval erb template with given binding' do
      deploy_to = 'test/path'
      rails_env = 'staging'
      described_class.new('test', binding).content.should == <<-YAML
      staging:
        test: 1
        path: test/path
      YAML
    end
  end

  describe '#valid?' do
    context 'yaml file' do
      subject{described_class.new('test.yml', double(rails_env: 'staging'))}

      it 'should return true for valid file' do
        subject.stub(:content).and_return <<-YAML
        test:
          valid: yaml
        YAML

        subject.should be_valid
        subject.error.should be_nil
      end

      it 'should return false for invalid file and set error' do
        subject.stub(:content).and_return <<-YAML
        test:
          invalid: yaml
         valid: yaml
        YAML

        subject.should_not be_valid
        subject.error.should be
      end
    end

    context 'rb file' do
      subject{described_class.new('test.rb', double(rails_env: 'staging'))}

      it 'should return true for valid file' do
        subject.stub(:content).and_return <<-CODE
        god.watch do
          test
        end
        CODE

        subject.should be_valid
        subject.error.should be_nil
      end

      it 'should return false for invalid file and set error' do
        subject.stub(:content).and_return <<-CODE
        god.watch do
          (test
        end
        CODE

        subject.should_not be_valid
        subject.error.should be
      end
    end

    context 'other files' do
      subject{described_class.new('test.conf', double(rails_env: 'staging'))}

      it 'should return true' do
        subject.stub(:content).and_return <<-CONFIG
        test = 1
        conf.test = 1
        CONFIG

        subject.should be_valid
        subject.error.should be_nil
      end
    end
  end
end
