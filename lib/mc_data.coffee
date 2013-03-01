cheerio = require 'cheerio'
request = require 'request'
_ 		= require 'underscore'
fs		= require 'fs'
AsyncQueue = require 'async-queue'

page_to_scrape = "http://minecraftdatavalues.com/"

class MinecraftData
	constructor: () ->
		@base_json = {
			items: {},
			ids: [],
			names: []
		}
		@json = _.clone @base_json
		@images = []
		@image_names = []
		@refreshData()

	refreshData: () ->
		console.log "Refreshing"
		request uri: page_to_scrape, (err, res, body) =>
			@processHTML body

			setTimeout ->
				@refreshData
			, 1000 * 1 * 60 * 60 * 24 # once per day

	processHTML: (html) ->
		$ = cheerio.load html
		@_process $, $('#values table tr td')

	resp: (_data) -> _data

	all: () -> @resp @json
	ids: () -> @resp @json['ids']
	names: () -> @resp @json['names']
	item: (id) -> @resp @json['items'][id]
	subItem: (id, data_value) ->
		return null if not @json['items'][id]

		return _.find @json['items'][id].subitems, (v) -> return v.data_value == data_value

	imageNames: () -> @resp _.map(@image_names, (v) -> return "/images/" + v)

	downloadImages: (images) ->
		queue = new AsyncQueue

		that = this
		fs.mkdir __dirname + '/blocks/', (err) ->
			_.each images, (v) ->
				n = v.split('/').pop()
				f = __dirname + '/blocks/' + n

				that.image_names.push n

				queue.add (err, job) ->
					job.fail(err) if err

					fs.exists f, (exists) ->
						if exists
							return job.success()

						ff = fs.createWriteStream(f)
						ff.on 'close', () ->
							console.log 'Saved: ' + n
							job.success()

						request(v).pipe ff

			queue.add (err, job) ->
				console.log "Saved all images!"
				job.success()

			queue.start()

	_process: ($, inp) ->
		that = @
		json = _.clone that.base_json

		inp.each ->
			$this = $ this

			return if not $this.attr 'tmd'

			s = $this.attr('tmd').split ':'
			id = s[1]
			dataValue = if s.length > 2 then s[2] else false
			imgSrc = $this.find('img').eq(0).attr 'src'
			name = $this.find('div').eq(2).text().trim()

			if not json.items[id]
				json.items[id] = subitems: []

			if dataValue
				json.items[id].subitems.push
					data_value: dataValue,
					item_name: name,
					pic_name: imgSrc.substring(imgSrc.lastIndexOf('/') + 1),
					image_url: "/blocks/" + id + "/" + dataValue + "/image/"

			json.items[id]["id"] = id
			json.items[id].item_name = name
			json.items[id].pic_name = imgSrc.substring(imgSrc.lastIndexOf('/') + 1)
			json.items[id].image_url = "/blocks/" + id + "/image/"

			json.ids.push id
			json.names.push name

		json.ids = _.uniq json.ids
		json.names = (_.uniq(json.names)).sort()
		json.ids.sort (a, b) ->
			a = parseInt a
			b = parseInt b
			return  1 if a > b
			return -1 if a < b
			return 0

		if not _.isEqual json, @json
			@images = []
			@image_names = []
			@lastUpdate = new Date

			_.each $('#values img'), ($v, k) =>
				@images.push "http://minecraftdatavalues.com/" + $($v).attr('src')

			@downloadImages @images

			@json = json

module.exports = MinecraftData
