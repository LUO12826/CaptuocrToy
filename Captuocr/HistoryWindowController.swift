//
//  HistoryWindow.swift
//  Captuocr
//
//  Created by Gragrance on 2017/12/4.
//  Copyright © 2017年 Gragrance. All rights reserved.
//

import Cocoa

class HistoryWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet var tableView: NSTableView!
    @IBOutlet var contentView: NSView!
    
    let viewmodel = HistoryViewModel()
    var setting: Settings!
    var historyCenter: HistoryCenter!
    
    var items: [HistoryRecord]!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        setting = AppDelegate.container.resolve(Settings.self)!
        historyCenter = AppDelegate.container.resolve(HistoryCenter.self)!
        tableView.register(NSNib(nibNamed: NSNib.Name(HistoryCell.name), bundle: nil),
                           forIdentifier: NSUserInterfaceItemIdentifier(rawValue: HistoryCell.name))
//        bindViewmodel()
//        initialize()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func reload() {
//        initialize()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if items == nil {
            items = historyCenter.getRecordList()
        }
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: HistoryCell.name),owner: self)
                    as! HistoryCell
        
        let model = items[row]
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMMM dd HH:mm"
        
        cell.tfMain?.stringValue = model.txt
        cell.tfAt.stringValue = dateformatter.string(from: model.updateAt)
        cell.type = model.type
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let rowCount = items.count
        guard tableView.selectedRow >= 0 && tableView.selectedRow < rowCount else {
            return
        }
        
        let model = items[tableView.selectedRow]
        
        if let base64 = self.historyCenter.getImgBase64(id: model.id) {
            let recognizeVc = RecognizeBoxViewController(nibName: NSNib.Name("RecognizeBox"), bundle: Bundle.main)
            // recognizeVc.view.frame = NSRect(x: 0, y: 0, width: 834, height: 474)
            recognizeVc.viewmodel.image.value = base64
            recognizeVc.viewmodel.recognizedText.value = model.txt
            self.contentView.subviews.removeAll()

            self.contentView.addSubview(recognizeVc.view)
            
            self.contentView.reactive.keyPath("frame", ofExpectedType: NSRect.self, context: .immediateOnMain)
                .observeNext {
                    self.contentView.subviews.first?.frame = NSRect(x: 0, y: 0, width: $0.width, height: $0.height)
                }
                .dispose(in: self.contentView.bag)
        }
    }

}
