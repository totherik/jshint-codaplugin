load('jshint.js');

var script = arguments[0],
	optList = arguments[1] ? arguments[1].split(',') : [],
	options = {},
	option = null;

if (script) {
	while (optList.length) {
		option = optList.shift();
		if (option) {
			options[option] = true;
		}
	}
	if (!JSHINT(script, options)) {
		print(JSHINT.report(true));
	}
}