//
//  SearchTextField.swift
//  RyanairApp
//
//  Created by Cathal Farrell on 29/02/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//
//  Inspired by https://github.com/sinitame/customSearchField-medium

import UIKit

protocol ChildNotifiesParent: class {
    func updateDestinationStationsFor(selectedItem: Station)
}

class SearchTextField: UITextField {

    weak var parentDelegate: ChildNotifiesParent!
    var dataList: [Station] = [Station]()
    var resultsList: [Station] = [Station]()
    var selectedItem: Station!
    var tableView: UITableView!
    var isOrigin: Bool = false

    // Connecting the new element to the parent view
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        tableView?.removeFromSuperview()

    }

    func updateDataList(data: [Station]) {
        self.dataList = data
    }

    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        self.addTarget(self, action: #selector(SearchTextField.textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidBeginEditing), for: .editingDidBegin)
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidEndEditing), for: .editingDidEnd)
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        buildSearchTableView()

    }

    func showCompleteList() {
        resultsList = dataList
        updateSearchTableView()
        tableView?.isHidden = false
    }

    func showFilteredList() {
        filter()
        updateSearchTableView()
        tableView?.isHidden = false
    }

    @objc open func textFieldDidChange() {
        Log.v("⭐️ Text Changed \(isOrigin ? "ORIGIN" : "DESINATION")")
        showFilteredList()
    }

    @objc open func textFieldDidBeginEditing() {
        Log.v("⭐️ Begin Editing \(isOrigin ? "ORIGIN" : "DESINATION")")
        if self.text != "" {
            showFilteredList()
        } else {
            showCompleteList()
        }
    }

    @objc open func textFieldDidEndEditing() {
         Log.v("⭐️ End Editing \(isOrigin ? "ORIGIN" : "DESINATION")")
    }

    @objc open func textFieldDidEndEditingOnExit() {
         Log.v("⭐️ Did End On Exit \(isOrigin ? "ORIGIN" : "DESINATION")")
    }

    fileprivate func filter() {
        guard let searchTerm = self.text else {
            return
        }

        Log.v("⭐️ Filtering for \(searchTerm)")

        resultsList = dataList.filter { (station) -> Bool in
            // Need to allow for diacritics e.g. ü in Münster
            station.name.startsWith(string: searchTerm) ||
            station.code.startsWith(string: searchTerm)
        }

        tableView?.reloadData()
    }

    func hideList() {
        tableView.isHidden = true
        self.endEditing(true)
    }
}
extension SearchTextField {

    func buildSearchTableView() {

        //I tagged the fields origin = 1, destination = 2
        if self.tag == 1 {
            isOrigin = true
        }

        if let tableView = tableView {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchTextFieldCell")
            tableView.delegate = self
            tableView.dataSource = self
            self.window?.addSubview(tableView)

        } else {
            Log.v("⭐️ tableView created for \(isOrigin ? "ORIGIN" : "DESINATION")")
            tableView = UITableView(frame: CGRect.zero)
        }

        updateSearchTableView()
    }

    func updateSearchTableView() {

        if let tableView = tableView {
            superview?.bringSubviewToFront(tableView)
            var tableHeight: CGFloat = 0
            tableHeight = tableView.contentSize.height

            // Set a bottom margin of 10p
            if tableHeight < tableView.contentSize.height {
                tableHeight -= 10
            }

            // Set tableView frame
            var tableViewFrame = CGRect(x: 0, y: 0, width: frame.size.width - 4, height: tableHeight)
            tableViewFrame.origin = self.convert(tableViewFrame.origin, to: nil)
            tableViewFrame.origin.x += 2
            tableViewFrame.origin.y += frame.size.height + 2
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.tableView?.frame = tableViewFrame
            })

            //Setting tableView style
            tableView.layer.masksToBounds = true
            tableView.separatorInset = UIEdgeInsets.zero
            tableView.layer.cornerRadius = 5.0
            tableView.separatorColor = UIColor.lightGray
            tableView.backgroundColor = UIColor.white.withAlphaComponent(0.4)

            if self.isFirstResponder {
                superview?.bringSubviewToFront(self)
            }

            tableView.reloadData()
        }
    }
}
extension SearchTextField: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedItem = resultsList[indexPath.row]
        let code = resultsList[indexPath.row].code ?? "N/A"
        let name = resultsList[indexPath.row].name ?? "N/A"
        self.text = "\(code), \(name)"
        tableView.isHidden = true
        self.endEditing(true)

        //Notify parent of choice to help prepare destinations
        if let delegate = parentDelegate {
            delegate.updateDestinationStationsFor(selectedItem: self.selectedItem)
        }
    }
}
extension SearchTextField: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTextFieldCell",
                                                 for: indexPath) as UITableViewCell

        let code = resultsList[indexPath.row].code ?? "N/A"
        let name = resultsList[indexPath.row].name ?? "N/A"

        cell.backgroundColor = UIColor.systemBlue
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = "\(code), \(name)"

        return cell
    }
}
