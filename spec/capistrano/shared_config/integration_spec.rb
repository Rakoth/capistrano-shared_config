require 'spec_helper'
require 'capistrano/shared_config/integration'

describe Capistrano::SharedConfig::Integration do
  let(:cap) do
    Capistrano::Configuration.new.tap do |config|
      config.extend(Capistrano::Spec::ConfigurationExtension)
      config.extend(ConfigurationExtension)
      config.load do
        namespace :deploy do
          task(:default){}
          task(:update_code){}
          task(:assets_precompile){}
        end
      end
    end
  end

  describe 'set config files variables' do
    before do
      cap.set(:rails_env, 'staging')
    end

    it 'should should set empty config files set for default' do
      Capistrano::SharedConfig::Integration.load_into(cap)

      cap.fetch(:shared_config_files).should == []
      cap.fetch(:shared_config_symlinks).should == []
    end

    it 'should should use predefined shared_config_files' do
      cap.set(:shared_config_files, ['test'])
      Capistrano::SharedConfig::Integration.load_into(cap)

      cap.fetch(:shared_config_files).should == ['test']
      cap.fetch(:shared_config_symlinks).should == ['test']
    end

    it 'should should use predefined shared_config_symlinks' do
      cap.set(:shared_config_files, ['test', 'test_1'])
      cap.set(:shared_config_symlinks, ['test'])
      Capistrano::SharedConfig::Integration.load_into(cap)

      cap.fetch(:shared_config_files).should == ['test', 'test_1']
      cap.fetch(:shared_config_symlinks).should == ['test']
    end

    it 'should set _shared_config_files for internal use' do
      cap.set(:shared_config_files, ['test', 'test_1'])
      Capistrano::SharedConfig::Integration.load_into(cap)

      cap.fetch(:_shared_config_files).should have(2).items
      cap.fetch(:_shared_config_files).first.name.should == 'test.yml'
      cap.fetch(:_shared_config_files).last.name.should == 'test_1.yml'
    end

    it 'should set _shared_config_files for internal use when ENV[FILE] is present' do
      begin
        ENV['FILE'] = 'test_env'
        cap.set(:shared_config_files, ['test', 'test_1'])
        Capistrano::SharedConfig::Integration.load_into(cap)

        cap.fetch(:_shared_config_files).should have(1).item
        cap.fetch(:_shared_config_files).first.name.should == 'test_env.yml'
      ensure
        ENV.delete('FILE')
      end
    end
  end

  describe 'callbacks' do
    context 'default' do
      before do
        Capistrano::SharedConfig::Integration.load_into(cap)
      end

      it 'should run shared_config:symlinks after deploy:update_code' do
        cap.should callback('shared_config:symlinks').after('deploy:update_code')
      end

      it 'should run shared_config:sync after deploy:update_code' do
        cap.should callback('shared_config:sync').after('deploy:update_code')
      end

      it 'should run early shared_config:check before deploy:update_code' do
        cap.should callback('shared_config:check').before('deploy:update_code')
      end

      it 'should run shared_config:check before shared_config:sync' do
        cap.should callback('shared_config:check').before('shared_config:sync')
      end
    end

    context 'configured' do
      it 'should run configured shared_config:symlinks' do
        cap.set(:run_shared_config_symlinks, [:before, 'deploy:assets_precompile'])
        Capistrano::SharedConfig::Integration.load_into(cap)

        cap.should callback('shared_config:symlinks').before('deploy:assets_precompile')
      end

      it 'should run configured shared_config:sync' do
        cap.set(:run_shared_config_sync, [:after, 'deploy:assets_precompile'])
        Capistrano::SharedConfig::Integration.load_into(cap)

        cap.should callback('shared_config:sync').after('deploy:assets_precompile')
      end

      it 'should run configured early shared_config:check' do
        cap.set(:run_early_shared_config_check, [:before, 'deploy'])
        Capistrano::SharedConfig::Integration.load_into(cap)
        cap.should callback('shared_config:check').before('deploy')
      end
    end
  end

  describe 'tasks' do
    before do
      cap.set(:rails_env, 'production')
      cap.set(:shared_path, '/shared')
      cap.set(:shared_config_files, %w[database settings.local])
      Capistrano::SharedConfig::Integration.load_into(cap)
    end

    describe 'shared_config:setup' do
      before do
        cap.find_and_execute_task('shared_config:setup')
      end

      it 'should create symlinks for all config files' do
        cap.should have_run('mkdir -p /shared/config')
      end
    end

    describe 'shared_config:symlinks' do
      before do
        cap.set(:latest_release, '/release')
        cap.find_and_execute_task('shared_config:symlinks')
      end

      it 'should create symlinks for all config files' do
        cap.should have_run(
          'ln -nfs /shared/config/database.yml /release/config/database.yml && ' +
            'ln -nfs /shared/config/settings.local.yml /release/config/settings.local.yml'
        )
      end
    end

    describe 'shared_config:check' do
      let(:files){cap.fetch(:_shared_config_files)}

      it 'should pass silently if all configs are valid' do
        files.each{|file| file.stub(:valid?).and_return(true)}
        expect{cap.find_and_execute_task('shared_config:check')}.to_not raise_error
      end

      it 'should rollback deploy if config is invalid' do
        files.first.stub(:valid?).and_return(true)
        files.last.stub(valid?: false, error: 'test')
        expect{cap.find_and_execute_task('shared_config:check')}.to raise_error(Capistrano::CommandError, 'test')
      end
    end

    describe 'shared_config:sync' do
      let(:files){cap.fetch(:_shared_config_files)}

      it 'should upload all config files on server' do
        files.first.stub(:content).and_return('test')
        files.last.stub(:content).and_return('test_1')

        cap.find_and_execute_task('shared_config:sync')

        cap.should have_putted('/shared/config/database.yml').with('test')
        cap.should have_putted('/shared/config/settings.local.yml').with('test_1')
      end
    end
  end
end
