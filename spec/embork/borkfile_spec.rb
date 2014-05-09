require 'spec_helper'
require 'embork/borkfile'

borkfile_dir = File.expand_path '../borkfile', __FILE__
empty_borkfile_path = File.join borkfile_dir, 'Borkfile.empty'
full_borkfile_path = File.join borkfile_dir, 'Borkfile.full'
relative_root_borkfile_path = File.join borkfile_dir, 'Borkfile.relative'
rack_based_borkfile_path = File.join borkfile_dir, 'Borkfile.rack'

describe 'Embork::Borkfile' do
  describe 'defaults' do
    let(:borkfile) { Embork::Borkfile.new empty_borkfile_path }

    it 'uses the files directory as project root' do
      expect(borkfile.project_root).to match(/.*\/embork\/spec\/embork\/borkfile$/)
    end

    it 'includes source path' do
      expect(borkfile.asset_paths).to include('app')
    end

    it 'includes :development config in path' do
      expect(borkfile.asset_paths).to include('config/development')
    end

    it 'includes components path' do
      expect(borkfile.asset_paths).to include('components')
    end

    it 'has no defined helpers' do
      expect(borkfile.helpers).to be_empty
    end
  end

  describe 'basic config' do
    let(:borkfile) { Embork::Borkfile.new full_borkfile_path }

    it 'doesn\'t expand absolute paths' do
      expect(borkfile.project_root).to eq('/tmp/project_root')
    end

    it 'adds arbitrary asset_paths' do
      expect(borkfile.asset_paths).to include('foo/css')
    end

    it 'adds arbitrary helpers' do
      expect(borkfile.helpers[0].call).to eq(:empty_span)
    end

    it 'evaluates code in the current enviroment' do
      expect(borkfile.asset_paths).to include('foo/dev/js')
    end

    it 'does not evaluate code from other environments' do
      expect(borkfile.asset_paths).not_to include('foo/prod/js')
    end

    it 'registered sprockets post-processor' do
      expect(borkfile.sprockets_postprocessors.length).to eq(1)
    end

    it 'registered sprockets engines' do
      expect(borkfile.sprockets_engines.length).to eq(1)
    end

    it 'uses pushstate middleware to respond with index.html' do
      expect(borkfile.backend).to eq(:static_index)
    end
  end

  describe 'relative root' do
    let(:borkfile) { Embork::Borkfile.new relative_root_borkfile_path }

    it 'expands the relative path' do
      expect(borkfile.project_root).to match(/.*\/embork\/spec\/embork\/borkfile\/project_root$/)
    end
  end

  describe 'rack backed' do
    let(:borkfile) { Embork::Borkfile.new rack_based_borkfile_path }

    it 'specifies that any missing routes are driven by a rack app' do
      expect(borkfile.backend.class.name.to_sym).to eq(:MyRackApp)
    end
  end
end