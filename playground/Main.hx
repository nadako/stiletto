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

class Main {
	static function main() {
		var logger = new Logger();
		var reporter = Stiletto.resolve(WeatherReporter.new, [
			WeatherService.new,
			() -> logger,
			WebSocket.new,
			LocationManager.new,
			GPSProvider.new,
		]);
		reporter.report();
	}
}
