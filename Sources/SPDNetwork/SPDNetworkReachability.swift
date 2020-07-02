//
//  NetworkReachability.swift
//  SPDNetwork
//
//  Created by SAMBIT DASH on 27/06/20.
//  Copyright © 2020 SAMBIT DASH. All rights reserved.
//

import Network

open class SPDNetworkReachability {
    public static let shared = SPDNetworkReachability()
    
    private var monitor: NWPathMonitor?
    private var isMonitoring = false
    
    var didStartMonitoringHandler: (() -> Void)?
    var didStopMonitoringHandler: (() -> Void)?
    var networkStatusChangeHandler: (() -> Void)?
    
    var isConnected: Bool {
        guard let monitor = self.monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }
    
    var networkInterface: NWInterface.InterfaceType? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.map { $0.type }.first
    }
    
    private init() {
        
    }
    
    open func startMonitoring() {
        if !isMonitoring {
            monitor = NWPathMonitor()
            
            let monitorQueue = DispatchQueue(label: "monitorQueue")
            monitor?.start(queue: monitorQueue)
            monitor?.pathUpdateHandler = { path in
                self.networkStatusChangeHandler?()
            }
            isMonitoring = !isMonitoring
            self.didStartMonitoringHandler?()
        }
    }
    
    open func stopMonitoring() {
        if isMonitoring, let monitor = monitor {
            monitor.cancel()
            self.monitor = nil
            isMonitoring = false
            didStopMonitoringHandler?()
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
