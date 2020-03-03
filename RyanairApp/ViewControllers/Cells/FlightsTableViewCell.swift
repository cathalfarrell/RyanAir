//
//  FlightsTableViewCell.swift
//  RyanairApp
//
//  Created by Cathal Farrell on 01/03/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import UIKit

class FlightsTableViewCell: UITableViewCell {

    var flight: Flight!
    var currency: String!

    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet weak var labelOutTime: UILabel!
    @IBOutlet weak var labelInTime: UILabel!
    @IBOutlet weak var labelFlightNumber: UILabel!
    @IBOutlet weak var labelAdultFare: UILabel!
    @IBOutlet weak var labelTeenFare: UILabel!
    @IBOutlet weak var labelChildFare: UILabel!
    @IBOutlet weak var labelTotal: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialiseCell()
    }

    func initialiseCell() {
        labelFlightNumber.text = nil
        labelAdultFare.text = nil
        labelTeenFare.text = nil
        labelChildFare.text = nil
        labelTotal.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setFlight(_ flight: Flight!, currency: String!) {

        self.currency = currency

        if let flight = flight {

            self.flight = flight

            let adtCount = self.getCountFor(type: "ADT")
            let teenCount = self.getCountFor(type: "TEEN")
            let chdCount = self.getCountFor(type: "CHD")

            let adtFare = self.getFareFor(type: "ADT")
            let teenFare = self.getFareFor(type: "TEEN")
            let chdFare = self.getFareFor(type: "CHD")

            var total = (adtFare * Double(adtCount))
                total += (teenFare * Double(teenCount))
                total += (chdFare * Double(chdCount))

            DispatchQueue.main.async {
                if let time = flight.time, let outTime = time.first, let inTime = time.last {
                    //2016-04-11T00:00:00.000 - > 00:00
                    let displayOutTime = outTime.substring(with: 11..<16)
                    let displayInTime = inTime.substring(with: 11..<16)
                    self.labelOutTime.text = displayOutTime
                    self.labelInTime.text = displayInTime
                }
                self.detailsStackView.isHidden = false
                self.labelFlightNumber?.text = flight.flightNumber ?? "Unknown Flight Number"
                self.labelAdultFare.text = "(\(adtCount)) \(self.getCurrency()) \(adtFare)"
                self.labelTeenFare.text = "(\(teenCount)) \(self.getCurrency()) \(teenFare)"
                self.labelChildFare.text = "(\(chdCount)) \(self.getCurrency()) \(chdFare)"
                self.labelTotal.text = String(format: "\(self.getCurrency()) %.2f", total)
            }
        } else {
            DispatchQueue.main.async {
                self.labelFlightNumber?.text = "No flights Available"
                self.labelOutTime.text = nil
                self.labelInTime.text = nil
                self.detailsStackView.isHidden = true
            }
        }

    }

    func getCurrency() -> String {
        guard let currency = self.currency else {
            return ""
        }

        switch currency {
        case "EUR":
            return "€"
        default:
            return currency
        }
    }

    func getFareFor(type: String) -> Double {
        if let regularFare = self.flight.regularFare,
            let fares = regularFare.fares,
            fares.count > 0 {

            let results = fares.filter { (fare) -> Bool in
                fare.type == type
            }

            if results.count == 1,
                let fareFound = results.first,
                let publishedFare = fareFound.publishedFare {
                return publishedFare
            }
        }
        return 0
    }

    func getCountFor(type: String) -> Int {
        if let regularFare = self.flight.regularFare,
            let fares = regularFare.fares,
            fares.count > 0 {

            let results = fares.filter { (fare) -> Bool in
                fare.type == type
            }

            if results.count == 1,
                let fareFound = results.first,
                let fareCount = fareFound.count {
                return fareCount
            }
        }
        return 0
    }
}
