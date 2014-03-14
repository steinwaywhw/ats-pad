angular.module("ats-pad").factory("$outputParser", function () {
	return {
		decorate: function (line) {
			var regexp = /(The actual term is)|(The needed term is)|(\d+\(line=\d+, offs=\d+\) -- \d+\(line=\d+, offs=\d+\))/

			return line.replace(regexp, function (match) {
				return "<span class='bg-danger'>" + match + "</span>"
			})
		}
	}
})