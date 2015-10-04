//
//  MenuDetailViewController.swift
//  Wokin
//
//  Created by chan bill on 4/10/2015.
//  Copyright © 2015 chan bill. All rights reserved.
//

import UIKit

class MenuDetailViewController: PanelsViewController {
  
  var panelsArray = Array<Array<String>>()
  
  func initAction()
  {
    let numberOfPanels = 10;
    for var i = 0; i < numberOfPanels; i++
    {
      let numberOfRows = Int(arc4random()%20)
      var rows = Array<String>()
      
      for var j = 0; j < numberOfRows; j++
      {
        rows.append("")
      }
      panelsArray.append(rows)
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    initAction()
  }
  
  //    override func didReceiveMemoryWarning() {
  //        super.didReceiveMemoryWarning()
  //        // Dispose of any resources that can be recreated.
  //    }
  
  // MARK: panel views delegate/datasource
  
  /**
  *
  * - (NSInteger)numberOfPanels
  * set number of panels
  *
  */
  override func numberOfPanels() -> NSInteger
  {
    self.title = "\(panelsArray.count) panel(s)"
    return panelsArray.count
  }

  
  /**
  *
  * - (NSInteger)panelView:(PanelView *)panelView numberOfRowsInPage:(NSInteger)page section:(NSInteger)section
  * set number of rows for different panel & section
  *
  */
  override func panelView(panelView: AnyObject, numberOfRowsInPage page: Int, section: Int) -> Int {
    return panelsArray[page].count
  }
  
  /**
  *
  * - (UITableViewCell *)panelView:(PanelView *)panelView cellForRowAtIndexPath:(PanelIndexPath *)indexPath
  * use this method to change table view cells for different panel, section, and row
  *
  */
  override func panelView(panelView: AnyObject, cellForRowAtIndexPath indexPath: PanelIndexPath) -> UITableViewCell {
    let identity = "UITableViewCell"
    
//    var cell:UITableViewCell = panelView.tableView!.dequeueReusableCellWithIdentifier(identity)!
    
    var cell = panelView.tableView!.dequeueReusableCellWithIdentifier(identity) as UITableViewCell?
    
    if(cell == nil)
    {
      cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: identity)
    }

    cell?.textLabel!.text = "panel \(indexPath.page) section \(indexPath.section) row \(indexPath.row+1)"
    
    return cell!
  }
  
  /**
  *
  * - (PanelView *)panelForPage:(NSInteger)page
  * use this method to change panel types
  * SamplePanelView should subclass PanelView
  *
  */
  func panelForPage(page:Int) -> PanelView
  {
    let identifier = "SamplePanelView"
    
    var panelView = dequeueReusablePageWithIdentifier(identifier)
    if(panelView == nil)
    {
      panelView = MenuDetailPanelView.init(identifier: identifier)
    }
    
    return panelView
  }
}
