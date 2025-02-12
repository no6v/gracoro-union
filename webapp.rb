# -*- coding: utf-8; -*-
#
# webapp.rb : gracoro-union web application
#
# Copyright (C) 2011 by TADA Tadashi <t@tdtds.jp>
#

require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'json'

require './lib/connect'
require './lib/person'

class GracoroUnion < Sinatra::Base
	set :haml, { format: :html5, escape_html: true }

	get '/' do
		haml :index
	end

	get '/rule' do
		haml :rule
	end

	get %r|/(\d{4})$| do
		@year = params[:captures].first
		begin
			haml :archive
		rescue Errno::ENOENT
			return 404
		end
	end

:private
	def ranking( limit )
		Person.all( sort: [[:count, :desc]], limit: limit ).each_with_index do |person, index|
			yield person, index
		end
	end

	def ranking_archive( year )
		JSON::parse( File::open( "data/people.#{year}.json", &:read ) ).sort{|a, b|
			b['count'] <=> a['count']
		}.each_with_index{|person, index|
			yield person, index
		}
	end
end

GracoroUnion::run! if __FILE__ == $0
