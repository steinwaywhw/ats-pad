client = 
	primus : null
	term: null

	testOpts: () ->
		url: "http://127.0.0.1:8223"
		cols: 140
		rows: 19
		parent: document.getElementById("terminal")

	openTerm: (opts) ->
		@term = new Terminal 
			cols: opts.cols
			rows: opts.rows
			useStyle: true
			screenKeys: true

		@term.open(opts.parent)
		@term.on "data", (data) =>
			if @primus?
				@primus.write(data)

	openConnection: (opts) ->
		if @primus? then @primus.end()

		@primus = Primus.connect opts.url
		@primus.on 'data', (data) => @term.write(data)
		@primus.on 'open', () =>
			@term.emit "data", "clear\n"

	open: () ->
		opts = @testOpts()
		@openTerm(opts)
		@openConnection(opts)

client.open()