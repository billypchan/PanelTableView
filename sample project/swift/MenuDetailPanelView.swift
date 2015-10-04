//
//  MenuDetailPanelView.swift
//  Wokin
//
//  Created by chan bill on 4/10/2015.
//  Copyright © 2015 chan bill. All rights reserved.
//

//import Cocoa

class MenuDetailPanelView: PanelView {

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override init(identifier: String)
  {
    super.init(identifier: identifier)
  }

}
