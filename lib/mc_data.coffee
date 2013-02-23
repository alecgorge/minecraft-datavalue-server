cheerio = require 'cheerio'
request = require 'request'
_ 		= require 'underscore'

page_to_scrape = "http://minecraftdatavalues.com/"

class MinecraftData
	constructor: () ->
		@json = {}
		@images = []

	refreshData: () ->
		request uri: page_to_scrape, (err, res, body) =>
			@processHTML body

			setTimeout ->
				@refreshData
			, 1000 * 1 * 60 * 60 * 24 # once per day

	processHTML: (html) ->
		$ = cheerio.load html
		@_process $('#values table tr td')

	resp: (_data) ->
		return
			last_update: @lastUpdate.toString()
			data: _data

	all: () -> @resp @json
	ids: () -> @resp @json['ids']
	names: () -> @resp @json['names']
	item: (id) -> @resp @json['items'][id]

	_process: (inp) ->
		inp.each ->
			$this = $ this

			return if not $this.attr 'tmd'

			s = $this.attr('tmd').split ':'
			id = s[1]
			dataValue = if s.length > 2 then s[2] else false
			imgSrc = $this.find('img')[0].src
			name = $this.find('div:eq(2)').text().trim()

			if dataValue
				if not json.items[id]
					json.items[id] = subitems: []

				json.items[id].subitems.push
					d: dataValue,
					itemname: name,
					image_url: "Blocks/" + imgSrc.substring(imgSrc.lastIndexOf('/') + 1)
			else
				if not json.items[id]
					json.items[id] = subitems: []

				json.items[id].item_name = name
				json.items[id].image_url = "Blocks/" + imgSrc.substring(imgSrc.lastIndexOf('/') + 1)

				json.ids.push id
				json.names.push name

		json.ids = _.uniq json.ids
		json.names = (_.uniq(json.names)).sort()
		json.ids.sort (a, b) ->
			a = parseInt a
			b = parseInt b
			return 1 if a > b
			return -1 if a < b
			return 0

		if not _.isEqual json, @json
			@images = []
			@lastUpdate = new Date

			$.each $('#values img'), (k, $v) ->
				@images.push "http://minecraftdatavalues.com/" + $($v).attr('src')

			@json = json


module.exports = MinecraftData
