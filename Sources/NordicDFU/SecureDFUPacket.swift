//
//  SecureDFUPacket.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

import Foundation
import Bluetooth
import GATT

/// Nordic Secure DFU Packet
public struct SecureDFUPacket: GATTProfileCharacteristic {
    
    public static let uuid = BluetoothUUID(rawValue: "8EC90002-F315-4F60-9FB8-838830DAEA50")!
    
    public static let properies: BitMaskOptionSet<GATT.Characteristic.Property> = [.writeWithoutResponse]
    
    public static var service: GATTProfileService.Type = SecureDFUService.self
    
    public init(data: Data) {
        
        self.data = data
    }
    
    public let data: Data
}

internal extension CentralProtocol {
    
    /**
     Sends the whole content of the data object.
     
     - parameter data: the data to be sent
     */
    func sendSecureInitPacket(for peripheral: Peripheral,
                              data: Data,
                              cache: GATTConnectionCache<Peripheral>,
                              timeout: Timeout) throws {
        
        // set chunk size
        let mtu = try maximumTransmissionUnit(for: peripheral)
        let packetSize = UInt32(mtu.rawValue - 3)
        
        // Data may be sent in up-to-20-bytes packets
        var offset: UInt32 = 0
        var bytesToSend = UInt32(data.count)
        
        repeat {
            
            let packetLength = min(bytesToSend, packetSize)
            let packet = data.subdata(in: Int(offset) ..< Int(offset + packetLength))
            
            let characteristicValue = SecureDFUPacket(data: packet)
            
            // peripheral.writeValue(packet, for: characteristic, type: .withoutResponse)
            try write(characteristicValue, for: cache, withResponse: false, timeout: timeout)
            
            offset += packetLength
            bytesToSend -= packetLength
            
        } while bytesToSend > 0
    }
    
    /**
     Sends a given range of data from given firmware over DFU Packet characteristic. If the whole object is
     completed the completition callback will be called.
     */
    func sendSecureNext(for peripheral: Peripheral,
                        prn prnValue: UInt16,
                        bytesSent: inout UInt32,
                        range: Range<Int>,
                        of firmware: DFUFirmware.FirmwareData,
                        cache: GATTConnectionCache<Peripheral>,
                        timeout: Timeout) throws {
        
        // set chunk size
        let mtu = try maximumTransmissionUnit(for: peripheral)
        let packetSize = UInt32(mtu.rawValue - 3)
        
        let objectData          = firmware.data.subdata(in: range)
        let objectSizeInBytes   = UInt32(objectData.count)
        let objectSizeInPackets = (objectSizeInBytes + packetSize - 1) / packetSize
        let packetsSent         = (bytesSent + packetSize - 1) / packetSize
        let packetsLeft         = objectSizeInPackets - packetsSent
        
        // Calculate how many packets should be sent before EOF or next receipt notification
        var packetsToSendNow = min(UInt32(prnValue), packetsLeft)
        
        // send first packet
        if prnValue == 0 {
            packetsToSendNow = packetsLeft
        }
        
        // This is called when we no longer have data to send (PRN received after the whole object was sent)
        if packetsToSendNow == 0 {
            return // done
        }
        
        // Calculate the total progress of the firmware, presented to the delegate
        //let totalBytesSent = UInt32(range.lowerBound) + bytesSent
        //let totalProgress = UInt8(totalBytesSent * 100 / UInt32(firmware.data.count))
        
        let originalPacketsToSendNow = packetsToSendNow
        
        while packetsToSendNow > 0 {
            
            let canSendPacket = true
            
            // If PRNs are enabled we will ignore the new API and base synchronization on PRNs only
            guard canSendPacket || prnValue > 0 else {
                break
            }
            
            let bytesLeft = objectSizeInBytes - bytesSent
            let packetLength = min(bytesLeft, packetSize)
            let packet = objectData.subdata(in: Int(bytesSent) ..< Int(packetLength + bytesSent))
            
            //peripheral.writeValue(packet, for: characteristic, type: .withoutResponse)
            let characteristicValue = SecureDFUPacket(data: packet)
            try write(characteristicValue, for: cache, timeout: timeout)
            
            bytesSent += packetLength
            packetsToSendNow -= 1
            
            // Calculate the total progress of the firmware, presented to the delegate
            //let totalBytesSent = UInt32(range.lowerBound) + bytesSent
            //let totalProgress = UInt8(totalBytesSent * 100 / UInt32(firmware.data.count))
            
            /*
            // Notify progress listener only if current progress has increased since last time
            if totalProgress > progress {
                // Calculate current transfer speed in bytes per second
                let now = CFAbsoluteTimeGetCurrent()
                let currentSpeed = Double(totalBytesSent - totalBytesSentSinceProgessNotification) / (now - lastTime!)
                let avgSpeed = Double(totalBytesSent - totalBytesSentWhenDfuStarted) / (now - startTime!)
                lastTime = now
                totalBytesSentSinceProgessNotification = totalBytesSent
                
                // Notify progress delegate of overall progress
                DispatchQueue.main.async(execute: {
                    aProgressDelegate?.dfuProgressDidChange(
                        for:   aFirmware.currentPart,
                        outOf: aFirmware.parts,
                        to:    Int(totalProgress),
                        currentSpeedBytesPerSecond: currentSpeed,
                        avgSpeedBytesPerSecond:     avgSpeed)
                })
                progress = totalProgress
            }*/
            
            // Notify handler of current object progress to start sending next one
            if bytesSent == objectSizeInBytes {
                
                if prnValue == 0 || originalPacketsToSendNow < UInt32(prnValue) {
                    
                    return
                    
                } else {
                    // The whole object has been sent but the DFU target will
                    // send a PRN notification as expected.
                    // The sendData method will be called again
                    // with packetsLeft = 0 (see line 112)
                    
                    // Do nothing
                }
            }
        }
    }
}
