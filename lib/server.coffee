express = require 'express'
app		= express()

MinecraftData = require './mc_data'

mc_data = new MinecraftData

app.get '/blocks/all.json', (req, res) ->
	res.jsonp mc_data.all()

app.get '/blocks/:id/info.json', (req, res) ->
	res.jsonp mc_data.item req.param 'id'

app.get '/blocks/names.json', (req, res) ->
	res.jsonp mc_data.names()

app.get '/blocks/ids.json', (req, res) ->
	res.jsonp mc_data.ids()
