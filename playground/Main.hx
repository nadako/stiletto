// example classes from https://medium.com/@isoron/a-friendly-introduction-to-dagger-2-part-1-dbdf2f3fb17b

class WeatherReporter {
	final weatherService:WeatherService;
	final locationManager:LocationManager;

	public function new(weatherService, locationManager) {
		this.locationManager = locationManager;
		this.weatherService = weatherService;
	}

	public function report() {
		trace("Mostly clouded, 26 C\n");
	}
}

class WeatherService {
	final logger:Logger;
	final socket:WebSocket;

	public function new(logger, socket) {
		this.logger = logger;
		this.socket = socket;
	}
}

class Logger {
	public function new() {}
	public function log(msg) trace(msg);
}

class WebSocket {
	public function new() {}
}

class LocationManager {
	final logger:Logger;
	final gpsProvider:GPSProvider;

	public function new(logger, gpsProvider) {
		this.logger = logger;
		this.gpsProvider = gpsProvider;
	}
}

class GPSProvider {
	public function new() {}
}

// say we'd like to have a service locator kind of thing
class Services extends stiletto.Module {
	function provideLogger():Logger;
}

class Main {
	static function main() {
		// create a service locator, which is also an injector
		var services = Stiletto.resolve(Services.new, [
			Logger.new,
		]);

		var reporter = Stiletto.resolve(WeatherReporter.new, [
			WeatherService.new,
			WebSocket.new,
			LocationManager.new,
			GPSProvider.new,
			services, // use service locator as a sub-injector
		]);

		reporter.report();

		// use service locator as service locator :)
		services.provideLogger().log("Hi again");

		// use service locator as an injector
		services.resolve(function(logger:Logger) {
			logger.log("hi");
		});
	}
}
