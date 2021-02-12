# frozen_string_literal: true

require 'action_controller/railtie'
require 'action_view/railtie'

class ModsDisplayTestApp < Rails::Application
end

Rails.application.routes.draw do
  resources 'searches', only: :index
end

class ApplicationController < ActionController::Base; end
class SearchesController < ApplicationController
  def index; end
end

Object.const_set(:ApplicationHelper, Module.new)
