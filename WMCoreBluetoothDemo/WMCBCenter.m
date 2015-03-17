//
//  WMCBCenter.m
//  WMCoreBluetoothDemo
//
//  Created by wangwendong on 15/3/11.
//  Copyright (c) 2015年 WM. All rights reserved.
//

#import "WMCBCenter.h"

@interface WMCBCenter()

@property (nonatomic) BOOL mIsScanningPeripherals;

@end

@implementation WMCBCenter
const char* gameObjectName;

+ (instancetype)sharedWMCBCenter {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [[self alloc] initWithDelegate];
    });
    return sharedInstance;
}

- (instancetype)initWithDelegate {
    self = [super init];
    if (self) {
        _iCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        _iPeripheralsArray = [[NSMutableArray alloc] init];
        _iConnectedPeripheralsArray = [[NSMutableArray alloc] init];
        _iCharacteristicsArray = [[NSMutableArray alloc] init];
        _mIsScanningPeripherals = NO;
    }
    return self;
}

#pragma mark - CB Central Manager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOff: {

            break;
        }
        case CBCentralManagerStatePoweredOn: {

            break;
        }
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

}

#pragma mark - CB Peripheral Delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

}

// iOS 5.0 and later but before iOS 8.0
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {

}

// iOS 8.0 and later
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {

}

#pragma mark - Handle CB Central And Peripheral

- (void)scanPeripheralsWithRepeat:(BOOL)repeat {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        if (_iCentralManager.state == CBCentralManagerStatePoweredOn) {
            if (!_mIsScanningPeripherals) {
                _mIsScanningPeripherals = YES;
                NSDictionary* scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
                [_iCentralManager scanForPeripheralsWithServices:nil options:scanOptions];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (_mIsScanningPeripherals) {
                        [_iCentralManager stopScan];
                        _mIsScanningPeripherals = NO;
                        if (repeat) {
                            [self scanPeripheralsWithRepeat:YES];
                        }
                    }
                });
            } else {
                [_iCentralManager stopScan];
                _mIsScanningPeripherals = NO;
                [self scanPeripheralsWithRepeat:repeat];
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:WM_CENTRAL_MANAGER_SCAN_POWEREDOFF object:nil];
        }
    });
}

- (void)rescanPeripheralsWithRepeat:(BOOL)repeat {
    _iPeripheralsArray = nil;
    _iPeripheralsArray = [[NSMutableArray alloc] init];
    [_iCentralManager stopScan];
    _mIsScanningPeripherals = NO;
    [self scanPeripheralsWithRepeat:repeat];
}

- (void)stopScanPeripherals {
    [_iCentralManager stopScan];
    _mIsScanningPeripherals = NO;
}

- (void)connectPeripheral:(CBPeripheral*)peripheral {
    if (peripheral) {
        [_iCentralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)disconnectPeripheral:(CBPeripheral*)peripheral {
    if (peripheral && peripheral.state == CBPeripheralStateConnected) {
        [_iCentralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)writeValue:(NSString*)value toPeripheral:(CBPeripheral*)peripheral toCharacteristic:(CBCharacteristic*)characteristic withResponse:(BOOL)response {
    if (value && peripheral && peripheral.state == CBPeripheralStateConnected) {
        if (response) {
            [peripheral writeValue:nil forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        } else {
            [peripheral writeValue:nil forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
}

- (void)readCharacteristic:(CBCharacteristic*)characteristic fromPeripheral:(CBPeripheral*)peripheral repeat:(BOOL)repeat everySeconds:(NSInteger)interval {
    if (characteristic && peripheral && peripheral.state == CBPeripheralStateConnected) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            [peripheral readValueForCharacteristic:characteristic];
            if (repeat) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self readCharacteristic:characteristic fromPeripheral:peripheral repeat:repeat everySeconds:interval];
                });
            }
        });
    }
}

#pragma mark - Methods for U3D

void connectBLEWithName() {
    [[WMCBCenter sharedWMCBCenter] rescanPeripheralsWithRepeat:YES];
}

void initiOSInteraction(const char * unityGameObjectName) {
    gameObjectName = unityGameObjectName;
}

@end
