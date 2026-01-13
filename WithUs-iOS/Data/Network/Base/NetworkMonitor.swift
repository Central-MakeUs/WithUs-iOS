//
//  NetworkMonitor.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import Foundation
import Network

public final class NetworkMonitor {
    public static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    public private(set) var isConnected: Bool = true
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}


