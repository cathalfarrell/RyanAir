//
//  SearchResultsVC.swift
//  RyanairApp
//
//  Created by Cathal Farrell on 29/02/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import UIKit
import Lottie

class SearchResultsVC: UIViewController {

    @IBOutlet weak var labelOrigin: UILabel!
    @IBOutlet weak var labelDestination: UILabel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!

    var loadingAnimationView: AnimationView!

    var searchParameters: [String: Any]!
    var currency: String!
    var trips: [Trip]!

    var useMockData = false

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let parameters = searchParameters else {
            Log.e("🛑 Missing Parameters")
            return
        }

        self.title = "Flights"

        setUpTable()

        //Work around the server being unavailable.
        startLoadingAnimation()

        if useMockData {
            getMockFlightDetails()
        } else {
            searchFlights(with: parameters)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        errorLabel.text = nil
    }

    func setMockData(onOrOff: Bool) {
        useMockData = onOrOff
    }

    func setUpTable() {

        //HeaderView in Table
        if let parameters = self.searchParameters {
            if let origin = parameters["origin"] as? String,
                let destination = parameters["destination"] as? String {
                self.labelOrigin.text = origin
                self.labelDestination.text = destination
            }
        }

        //Must register using nib for custom cell
        let flightsCell = UINib(nibName: "FlightsTableViewCell", bundle: Bundle.main)
        self.tableView.register(flightsCell, forCellReuseIdentifier: "FlightsTableViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    func searchFlights(with parameters: [String: Any]) {

        DispatchQueue.global(qos: .background).async {

            StationsService.shared.getSearch(parameters) { (resp) in

                switch resp {
                case .success(let resp):

                    self.displayResults(currency: resp.currency, trips: resp.trips)

                case .failure(let err):

                    self.displayError(message: err.localizedDescription)
                }
            }
        }
    }

    // MARK: - Update UI

    func displayError(message: String) {

        self.stopLoadingAnimation()

        DispatchQueue.main.async {

            Log.e("🛑 Error: \(message)")
            self.tableView.isHidden = true
            self.errorLabel.isHidden = false
            self.errorLabel.text = message
        }
    }

    func displayResults(currency: String!, trips: [Trip]!) {

        self.currency = currency
        self.stopLoadingAnimation()

        DispatchQueue.main.async {

            self.errorLabel.isHidden = true

            if let trips = trips {
                self.trips = trips
                Log.v("✅ Response: \(trips.count) TRIPS FOUND")
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
    }
}
extension SearchResultsVC {

    // Forced to use a MOCK Stub as this end-point is encountering a server error:
    // https://sit-nativeapps.ryanair.com/api/v4/Availability?

    func getMockFlightDetails() {

        if let jsonData = readJSONFromFile(fileName: "MockSearchFlight") {
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(APIResponseSearchFlights.self, from: jsonData)

                //Add delay - to simulate url request
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.displayResults(currency: response.currency, trips: response.trips)
                }

            } catch let error {
                Log.e("🛑 Unable to parse JSON response: \(error.localizedDescription)")
                Log.e("🛑 Error: \(error)")
            }

        } else {
             Log.e("🛑 Failed to read mock user data")
        }
    }

    func readJSONFromFile(fileName: String) -> Data? {
        var data: Data?
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)

            } catch let error {
                // Handle error here
                Log.e("🛑 Whoops error found: \(error)")
            }
        }
        return data
    }
}
extension SearchResultsVC: UITableViewDelegate {

}
extension SearchResultsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let trips = self.trips, let trip = trips.first, let dates = trip.dates {
            let flightDates = dates[section]
            if let flights = flightDates.flights, flights.count > 0 {
                return flights.count
            }
        }
        //Always want at least a row in each section - even if no flights
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FlightsTableViewCell",
                                                    for: indexPath) as? FlightsTableViewCell {

            if let trips = self.trips, let trip = trips.first, let dates = trip.dates {
                let flightDates = dates[indexPath.section]
                if let flights = flightDates.flights, flights.count > 0 {
                    print("✈️ FLIGHTS FOUND: \(flights)")
                    let flight = flights[indexPath.row]
                    cell.setFlight(flight, currency: self.currency)
                } else {
                    cell.setFlight(nil, currency: nil)
                }
            }

            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if let trips = self.trips, let trip = trips.first, let dates = trip.dates {
            return dates.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        view.backgroundColor = .systemBlue
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.bounds.width - 30, height: 30))
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.white

        label.text = "UNKNOWN"

        if let trips = self.trips, let trip = trips.first, let dates = trip.dates {
            if let dateForSection = dates[section].dateOut {
                let parsedDate = dateForSection.substring(upTo: 10)
                //2016-04-11T00:00:00.000 - > 2016-04-11
                    let jsonDateFormatter = DateFormatter()
                    jsonDateFormatter.dateFormat = "yyyy-MM-dd"
                    let headerDateFormatter = DateFormatter()
                    headerDateFormatter.dateFormat = "EEE dd-MM-yyyy"
                    headerDateFormatter.dateStyle = .full

                if let date = jsonDateFormatter.date(from: String(parsedDate)) {
                        let formattedDate = headerDateFormatter.string(from: date)
                        label.text = formattedDate
                    }
                }
            }

        view.addSubview(label)
        return view
    }
}
extension SearchResultsVC {

    // MARK: - Loading Animation

    func startLoadingAnimation() {

        let midX = UIScreen.main.bounds.midX
        let midY = UIScreen.main.bounds.midY

        if loadingAnimationView == nil {

            loadingAnimationView = AnimationView(name: "LoadingAnimation")

            let size: CGFloat = 100
            let offset: CGFloat = size/2
            loadingAnimationView.frame = CGRect(x: midX-offset, y: midY-offset, width: size, height: size)
            loadingAnimationView.loopMode = .loop

            if let animation = Animation.named("airplaneGlobe") {
                loadingAnimationView.animation = animation

                self.view.addSubview(loadingAnimationView)

            } else {
                Log.v("🛑 Animation not found.")
            }
        }

        DispatchQueue.main.async {
            self.loadingAnimationView.play()
        }
    }

    func stopLoadingAnimation() {
        if let animation = loadingAnimationView {
            DispatchQueue.main.async {
                animation.stop()
                animation.removeFromSuperview()
            }
        }
    }
}
