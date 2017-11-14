// Generated by Haxe 4.0.0 (git build development @ af56abb)
(function () { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var WeatherReporter = function(weatherService,locationManager) {
	this.locationManager = locationManager;
	this.weatherService = weatherService;
};
WeatherReporter.prototype = {
	report: function() {
		console.log("Main.hx:13:","Mostly clouded, 26 C\n");
	}
};
var WeatherService = function(logger,socket) {
	this.logger = logger;
	this.socket = socket;
};
var Logger = function() {
};
Logger.prototype = {
	log: function(msg) {
		console.log("Main.hx:29:",msg);
	}
};
var WebSocket = function() {
};
var LocationManager = function(logger,gpsProvider) {
	this.logger = logger;
	this.gpsProvider = gpsProvider;
};
var GPSProvider = function() {
};
var stiletto_Module = function() { };
var Services = function(valueForProvideLogger) {
	this.valueForProvideLogger = valueForProvideLogger;
};
Services.__super__ = stiletto_Module;
Services.prototype = $extend(stiletto_Module.prototype,{
	provideLogger: function() {
		return this.valueForProvideLogger;
	}
});
var Main = function() { };
Main.main = function() {
	var services = new Services(new Logger());
	new WeatherReporter(new WeatherService(services.provideLogger(),new WebSocket()),new LocationManager(services.provideLogger(),new GPSProvider())).report();
	services.valueForProvideLogger.log("Hi again");
	services.provideLogger().log("hi");
};
Main.main();
})();
