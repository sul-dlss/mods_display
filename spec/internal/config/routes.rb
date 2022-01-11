# frozen_string_literal: true

Rails.application.routes.draw do
  resources 'searches', only: :index
end
