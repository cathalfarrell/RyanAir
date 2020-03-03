//
//  SearchVC.swift
//  RyanairApp
//
//  Created by Cathal Farrell on 28/02/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import UIKit
import Lottie

class SearchVC: UIViewController {

    @IBOutlet weak var textFieldOrigin: SearchTextField!
    @IBOutlet weak var textFieldDestination: SearchTextField!
    @IBOutlet weak var textFieldDate: UITextField!
    @IBOutlet weak var textFieldAdultCount: UITextField!
    @IBOutlet weak var textFieldTeenCount: UITextField!
    @IBOutlet weak var textFieldChildCount: UITextField!

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var mockDataSwitch: UISwitch!

    var dateForRequest: Date = Date() // Now initially

    var loadingAnimationView: AnimationView!

    var stations: [Station]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideFirstResponder)))
        getAllStations()
        loadInitialValues()
    }

    func loadInitialValues() {

        self.title = "Search Flights"

        textFieldOrigin.parentDelegate = self

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YY"
        textFieldDate.text = dateFormatter.string(from: dateForRequest)

        textFieldAdultCount.text = "1"
        textFieldTeenCount.text = "0"
        textFieldChildCount.text = "0"

        errorLabel.text = nil

        self.view.backgroundColor = .systemYellow

    }

    func getAllStations() {

        self.startLoadingAnimation()

        DispatchQueue.global(qos: .background).async {

            StationsService.shared.getStations { (resp) in

                switch resp {
                case .success(let resp):

                    if let stations = resp.stations {
                        self.displayResults(stations: stations)
                    }

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
            self.errorLabel.text = message
        }
    }

    func displayResults(stations: [Station]) {

        self.stopLoadingAnimation()

        DispatchQueue.main.async {

                self.stations = stations
                Log.v("✅ Response: \(stations.count) STATIONS FOUND")
                self.textFieldOrigin.updateDataList(data: stations)
                self.textFieldDestination.updateDataList(data: stations)

        }
    }

    // MARK: - Pickers

    @IBAction func pickADate(_ sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        datePickerView.backgroundColor = .white
        datePickerView.locale = Locale.current
        textFieldDate.inputView = datePickerView

        //Show current date to begin with
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YY"

        datePickerView.date = dateForRequest

        //Listen for date changes
        datePickerView.addTarget(self, action: #selector(self.datePickerFromValueChanged),
                                 for: UIControl.Event.valueChanged)

    }

    @objc func datePickerFromValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YY"
        textFieldDate.text = dateFormatter.string(from: sender.date)
        dateForRequest = sender.date
    }

    func getRequestDate() -> String {
        //Used in the search parameters, requires date format 2020-02-29
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFormattedForRequest = dateFormatter.string(from: dateForRequest)
        return dateFormattedForRequest
    }

    @IBAction func pickANumber(_ sender: UITextField) {
        let numberPickerView: UIPickerView = UIPickerView()
        numberPickerView.backgroundColor = .white
        numberPickerView.dataSource = self
        numberPickerView.delegate = self
        //tag = 1,2,3 for ADT, TEEN, CHD fields
        numberPickerView.tag = sender.tag
        sender.inputView = numberPickerView

        //Show selected row
        if let numberSelected = sender.text, let rowInt = Int(numberSelected) {
            var selectedRow = rowInt
            if sender.tag == 1 {
                selectedRow -= 1
            }
            numberPickerView.selectRow(selectedRow, inComponent: 0, animated: true)
        }
    }

    @objc func hideFirstResponder() {
        self.view.endEditing(true)
    }

    // MARK: - Navigation

    @IBAction func openSearchResults(_ sender: Any) {

        if gatherParameters() != nil {
            self.performSegue(withIdentifier: "showResults", sender: self)
        } else {
            Log.e("User must complete form - to proceed")
            DispatchQueue.main.async {
                self.errorLabel.text = "You must fill all fields."
            }
        }

    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        hideFirstResponder()

        let parameters = gatherParameters()

        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let searchResultsVC = segue.destination as? SearchResultsVC {
            searchResultsVC.searchParameters = parameters
            searchResultsVC.setMockData(onOrOff: self.mockDataSwitch.isOn)
        }
    }

    func gatherParameters() -> [String: Any]? {

        guard let originSelected = textFieldOrigin.selectedItem,
              let destinationSelected = textFieldDestination.selectedItem,
              textFieldDate.text != nil else {
                return nil
        }

        let origin = originSelected.code ?? ""
        let destination = destinationSelected.code ?? ""
        let adtCount = Int(textFieldAdultCount.text ?? "") ?? 1
        let childCount = Int(textFieldChildCount.text ?? "") ?? 0
        let teenCount = Int(textFieldTeenCount.text ?? "") ?? 0

        let parameters = [ "origin": origin,
           "destination": destination,
           "dateOut": getRequestDate(),
           "dateIn": "",
           "adt": adtCount,
           "teen": teenCount,
           "chd": childCount,
           "flexdaysbeforeout": 3,
           "flexdaysout": 3,
           "flexdaysbeforein": 3,
           "flexdaysin": 3,
           "roundTrip": false,
           "ToUS": "AGREED"
        ] as [String: Any]

        return parameters

    }
}
extension SearchVC: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return "\(row + 1)"
        }
        return "\(row)"
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        switch pickerView.tag {
        case 1:
            textFieldAdultCount.text = "\(row + 1)"
        case 2:
            textFieldTeenCount.text = "\(row)"
        case 3:
            textFieldChildCount.text = "\(row)"
        default:
            Log.e("Not handling this tag")
        }
    }

}
extension SearchVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return 6
        }
        return 7
    }
}
extension SearchVC: ChildNotifiesParent {

    func updateDestinationStationsFor(selectedItem: Station) {

        // Update the valid destination options based on the origin selected
        // Also clear out any previous destination selection when origin changes

        Log.v("⭐️ Selected Item: \(selectedItem)")
        let validStations = getValidStationsFor(selectedItem: selectedItem)

        if validStations.count > 0 {
            self.textFieldDestination.updateDataList(data: validStations)
        }

        DispatchQueue.main.async {
            self.textFieldDestination.text = nil
            self.textFieldDestination.hideList()
            self.errorLabel.text = nil
        }
    }

    func getValidStationsFor(selectedItem: Station) -> [Station] {

        var validStations = [Station]()
        if let availableMarkets = selectedItem.markets, availableMarkets.count > 0 {

            for market in availableMarkets {
                let validStationResults = self.stations.filter { (station) -> Bool in
                    station.code == market.code
                }

                if let validStation = validStationResults.first {
                    validStations.append(validStation)
                }
            }

            Log.v("⭐️ Now have \(validStations.count) valid destination stations")
        }

        return validStations

    }
}
extension SearchVC {

    // MARK: - Loading Animation

    func startLoadingAnimation() {

        let midX = UIScreen.main.bounds.midX
        let midY = UIScreen.main.bounds.midY

        if loadingAnimationView == nil {

            loadingAnimationView = AnimationView(name: "LoadingAnimation")
            loadingAnimationView.backgroundColor = .white

            let size: CGFloat = 100
            let offset: CGFloat = size/2
            loadingAnimationView.frame = CGRect(x: midX-offset, y: midY-offset+100, width: size, height: size)
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
