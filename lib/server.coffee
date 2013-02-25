express = require 'express'
app		= express()
fs		= require 'fs'

MinecraftData = require './mc_data'

mc_data = new MinecraftData

app.get '/', (req, res) ->
	res.sendfile(__dirname + '/index.html')

app.get '/blocks/all.json', (req, res) ->
	res.jsonp mc_data.all()

app.get '/blocks/images.json', (req, res) ->
	res.jsonp mc_data.imageNames()

app.get '/blocks/:id/info.json', (req, res) ->
	res.jsonp mc_data.item req.param 'id'

app.get '/blocks/names.json', (req, res) ->
	res.jsonp mc_data.names()

app.get '/blocks/ids.json', (req, res) ->
	res.jsonp mc_data.ids()

app.get '/images/:pic_name.png', (req, res) ->
	f = __dirname + '/blocks/' + req.param('pic_name') + '.png'

	fs.exists f, (exists) ->
		return res.sendfile(f) if exists
		return res.status(404).send()

app.listen 3000
