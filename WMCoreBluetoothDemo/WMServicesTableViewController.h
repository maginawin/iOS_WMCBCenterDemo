//
//  WMServicesTableViewController.h
//  WMCoreBluetoothDemo
//
//  Created by maginawin on 15/3/12.
//  Copyright (c) 2015年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMCBCenter.h"
#import "WMCharTableViewController.h"

@interface WMServicesTableViewController : UITableViewController

@property (nonatomic) CBPeripheral* mPeripheral;

@end
