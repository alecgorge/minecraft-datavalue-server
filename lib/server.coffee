express = require 'express'
app		= express()
fs		= require 'fs'

MinecraftData = require './mc_data'

mc_data = new MinecraftData

app.get '/', (req, res) ->
	res.sendfile(__dirname + '/index.html')

app.get '/blocks/', (req, res) -> res.jsonp mc_data.all()
app.get '/blocks/images/', (req, res) -> res.jsonp mc_data.imageNames()
app.get '/blocks/names/', (req, res) -> res.jsonp mc_data.names()
app.get '/blocks/ids/', (req, res) -> res.jsonp mc_data.ids()

_404 = (res) ->
	res.status(404).send()

app.get '/blocks/:id/', (req, res) ->
	blk = mc_data.item req.param 'id'
	return _404(res) if not blk
	res.jsonp blk

app.get '/blocks/:id/image/', (req, res) ->
	blk = mc_data.item req.param 'id'
	return _404(res) if not blk
	sendImage req, res, blk.pic_name		

app.get '/blocks/:id/:data_value/', (req, res) ->
	blk = mc_data.subItem req.param('id'), req.param('data_value')
	return _404(res) if not blk
	res.jsonp blk

app.get '/blocks/:id/:data_value/image/', (req, res) ->
	blk = mc_data.subItem req.param('id'), req.param('data_value')
	return _404(res) if not blk
	sendImage req, res, blk.pic_name		

sendImage = (req, res, fileName) ->
	f = __dirname + '/blocks/' + fileName

	fs.exists f, (exists) ->
		return res.sendfile(f) if exists
		return res.status(404).send()

app.get '/images/:pic_name.png', (req, res) ->
	sendImage req.param('pic_name') + '.png'

app.listen 3000
