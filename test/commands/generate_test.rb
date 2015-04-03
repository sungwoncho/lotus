require 'test_helper'
require 'lotus/cli'
require 'lotus/commands/generate'

describe Lotus::Commands::Generate do
  let(:opts)     { default_options }
  let(:env)      { Lotus::Environment.new(opts) }
  let(:command)  { Lotus::Commands::Generate.new(target, app_name, target_name, env, cli) }
  let(:cli)      { Lotus::Cli.new }
  let(:app_name) { 'web' }

  def create_temporary_dir
    @tmp = Pathname.new(@pwd = Dir.pwd).join('tmp/generators/generate')
    @tmp.rmtree if @tmp.exist?
    @tmp.mkpath

    @tmp.join('apps', app_name).mkpath

    Dir.chdir(@tmp)
    @root = @tmp
  end

  def chdir_to_root
    Dir.chdir(@pwd)
  end

  def default_options
    Hash[path: 'apps']
  end

  before do
    create_temporary_dir
  end

  after do
    chdir_to_root
  end

  describe 'action' do
    let(:target)      { :action }
    let(:target_name) { 'dashboard#index' }

    describe 'with valid arguments' do
      before do
        capture_io { command.start }
      end

      describe 'apps/web/config/routes.rb' do
        it 'generates it' do
          content = @root.join('apps/web/config/routes.rb').read
          content.must_match %(get '/dashboard', to: 'dashboard#index')
        end
      end

      describe 'apps/web/controllers/dashboard/index.rb' do
        it 'generates it' do
          content = @root.join('apps/web/controllers/dashboard/index.rb').read
          content.must_match %(module Web::Controllers::Dashboard)
          content.must_match %(  class Index)
          content.must_match %(    include Web::Action)
          content.must_match %(    def call(params))
        end
      end

      describe 'spec/web/controllers/dashboard/index_spec.rb' do
        describe 'minitest (default)' do
          it 'generates it' do
            content = @root.join('spec/web/controllers/dashboard/index_spec.rb').read
            content.must_match %(require 'spec_helper')
            content.must_match %(require_relative '../../../../apps/web/controllers/dashboard/index')
            content.must_match %(describe Web::Controllers::Dashboard::Index do)
            content.must_match %(  let(:action) { Web::Controllers::Dashboard::Index.new })
            content.must_match %(  let(:params) { Hash[] })
            content.must_match %(  it "is successful" do)
            content.must_match %(    response = action.call(params))
            content.must_match %(    response[0].must_equal 200)
          end
        end

        describe 'rspec' do
          let(:opts) { default_options.merge(test: 'rspec') }

          it 'generates it' do
            content = @root.join('spec/web/controllers/dashboard/index_spec.rb').read
            content.must_match %(require 'spec_helper')
            content.must_match %(require_relative '../../../../apps/web/controllers/dashboard/index')
            content.must_match %(describe Web::Controllers::Dashboard::Index do)
            content.must_match %(  let(:action) { Web::Controllers::Dashboard::Index.new })
            content.must_match %(  let(:params) { Hash[] })
            content.must_match %(  it "is successful" do)
            content.must_match %(    response = action.call(params))
            content.must_match %(    expect(response[0]).to eq 200)
          end
        end
      end

      describe 'apps/web/views/dashboard/index.rb' do
        it 'generates it' do
          content = @root.join('apps/web/views/dashboard/index.rb').read
          content.must_match %(module Web::Views::Dashboard)
          content.must_match %(  class Index)
          content.must_match %(    include Web::View)
        end
      end

      describe 'spec/web/views/dashboard/index_spec.rb' do
        describe 'minitest (default)' do
          it 'generates it' do
            content = @root.join('spec/web/views/dashboard/index_spec.rb').read
            content.must_match %(require 'spec_helper')
            content.must_match %(require_relative '../../../../apps/web/views/dashboard/index')
            content.must_match %(describe Web::Views::Dashboard::Index do)
            content.must_match %(  let(:exposures) { Hash[foo: 'bar'] })
            content.must_match %(  let(:template)  { Lotus::View::Template.new('apps/web/templates/dashboard/index.html.erb') })
            content.must_match %(  let(:view)      { Web::Views::Dashboard::Index.new(template, exposures) })
            content.must_match %(  it "exposes #foo" do)
            content.must_match %(    view.foo.must_equal exposures.fetch(:foo))
            content.must_match %(  end)
          end
        end

        describe 'rspec' do
          let(:opts) { default_options.merge(test: 'rspec') }

          it 'generates it' do
            content = @root.join('spec/web/views/dashboard/index_spec.rb').read
            content.must_match %(require 'spec_helper')
            content.must_match %(require_relative '../../../../apps/web/views/dashboard/index')
            content.must_match %(describe Web::Views::Dashboard::Index do)
            content.must_match %(  let(:exposures) { Hash[foo: 'bar'] })
            content.must_match %(  let(:template)  { Lotus::View::Template.new('apps/web/templates/dashboard/index.html.erb') })
            content.must_match %(  let(:view)      { Web::Views::Dashboard::Index.new(template, exposures) })
            content.must_match %(  it "exposes #foo" do)
            content.must_match %(    expect(view.foo).to eq exposures.fetch(:foo))
            content.must_match %(  end)
          end
        end
      end

      describe 'apps/web/templates/dashboard/index.html.erb' do
        it 'generates it' do
          content = @root.join('apps/web/templates/dashboard/index.html.erb').read
          content.must_be :empty?
        end
      end
    end

    describe 'with unknown app' do
      before do
        # force not-existing app
        @tmp.join('apps', app_name).rmtree
      end

      let(:app_name) { 'unknown' }

      it 'raises error' do
        -> { capture_io { command.start } }.must_raise SystemExit
      end
    end
  end

  describe 'resource' do
    let(:target)      { :resource }
    let(:target_name) { 'user' }

    before do
      capture_io { command.start }
    end

    describe 'lib/web/entities/user.rb' do
      it 'generates it' do
        content = @root.join('lib/web/entities/user.rb').read
        content.must_match %(require "lotus/entity")
        content.must_match %(class User)
        content.must_match %(  include Lotus::Entity)
        content.must_match %(end)
      end
    end

    describe 'lib/web/repositories/user.rb' do
      it 'generates it' do
        content = @root.join('lib/web/repositories/user.rb').read
        content.must_match %(require "lotus/repository")
        content.must_match %(class UserRepository)
        content.must_match %(  include Lotus::Repository)
        content.must_match %(end)
      end
    end

    describe 'apps/web/config/routes.rb' do
      it 'inserts route rules in it' do
        content = @root.join('apps/web/config/routes.rb').read
        content.must_match %(get '/user', to: 'user#index')
        content.must_match %(get '/user/:id', to: 'user#show')
        content.must_match %(get '/user/new', to: 'user#new')
        content.must_match %(post '/user', to: 'user#create')
        content.must_match %(get '/user/:id/edit', to: 'user#edit')
        content.must_match %(patch '/user/:id', to: 'user#update')
        content.must_match %(delete '/user/:id', to: 'user#destroy')
      end
    end

    describe 'apps/web/controllers/user/index.rb' do
      it 'generates it' do
        content = @root.join('apps/web/controllers/user/index.rb').read
        content.must_match %(module Web::Controllers::User)
        content.must_match %(  class Index)
        content.must_match %(    include Web::Action)
        content.must_match %(    expose :user)
        content.must_match %(    def call(params))
        content.must_match %(      @user = UserRepository.all)
        content.must_match %(    end)
        content.must_match %(  end)
        content.must_match %(end)
      end
    end

    describe 'apps/web/controllers/user/show.rb' do
      it 'generates it' do
        content = @root.join('apps/web/controllers/user/show.rb').read
        content.must_match %(module Web::Controllers::User)
        content.must_match %(  class Show)
        content.must_match %(    include Web::Action)
        content.must_match %(    expose :user)
        content.must_match %(    def call(params))
        content.must_match %(      @user = UserRepository.find(params[:id]))
        content.must_match %(    end)
        content.must_match %(  end)
        content.must_match %(end)
      end
    end

    describe 'apps/web/controllers/user/new.rb' do
      it 'generates it' do
        content = @root.join('apps/web/controllers/user/new.rb').read
        content.must_match %(module Web::Controllers::User)
        content.must_match %(  class New)
        content.must_match %(    include Web::Action)
        content.must_match %(    expose :user)
        content.must_match %(    def call(params))
        content.must_match %(      @user = User.new)
        content.must_match %(    end)
        content.must_match %(  end)
        content.must_match %(end)
      end
    end

    describe 'apps/web/controllers/user/create.rb' do
      it 'generates it' do
        content = @root.join('apps/web/controllers/user/create.rb').read
        content.must_match %(module Web::Controllers::User)
        content.must_match %(  class Create)
        content.must_match %(    include Web::Action)
        content.must_match %(    def call(params))
        content.must_match %(      @user = User.new(user_params))
        content.must_match %(      UserRepository.persist(@user))
        content.must_match %(      redirect_to '/user')
        content.must_match %(    end)
        content.must_match %(    private)
        content.must_match %(    def user_params)
        content.must_match %(      params[:user])
        content.must_match %(    end)
        content.must_match %(  end)
        content.must_match %(end)
      end
    end

    describe 'apps/web/controllers/user/edit.rb' do
      it 'generates it' do
        content = @root.join('apps/web/controllers/user/edit.rb').read
        content.must_match %(module Web::Controllers::User)
        content.must_match %(  class Edit)
        content.must_match %(    include Web::Action)
        content.must_match %(    expose :user)
        content.must_match %(    def call(params))
        content.must_match %(      @user = UserRepository.find(params[:id]))
        content.must_match %(    end)
        content.must_match %(  end)
        content.must_match %(end)
      end
    end

    describe 'apps/web/controllers/user/update.rb' do
      it 'generates it' do
        content = @root.join('apps/web/controllers/user/update.rb').read
        content.must_match %(module Web::Controllers::User)
        content.must_match %(  class Update)
        content.must_match %(    include Web::Action)
        content.must_match %(    def call(params))
        content.must_match %(      @user = UserRepository.find(params[:id]))
        content.must_match %(      @user.update(user_params))
        content.must_match %(      UserRepository.update(@user))
        content.must_match %(      redirect_to '/user')
        content.must_match %(    end)
        content.must_match %(    private)
        content.must_match %(    def user_params)
        content.must_match %(      params[:user])
        content.must_match %(    end)
        content.must_match %(  end)
        content.must_match %(end)
      end
    end

    describe 'apps/web/controllers/user/destroy.rb' do
      it 'generates it' do
        content = @root.join('apps/web/controllers/user/destroy.rb').read
        content.must_match %(module Web::Controllers::User)
        content.must_match %(  class Destroy)
        content.must_match %(    include Web::Action)
        content.must_match %(    def call(params))
        content.must_match %(      @user = UserRepository.find(params[:id]))
        content.must_match %(      UserRepository.delete(@user))
        content.must_match %(      redirect_to '/user')
        content.must_match %(    end)
        content.must_match %(  end)
        content.must_match %(end)
      end
    end
  end
end
