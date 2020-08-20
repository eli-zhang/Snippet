//
//  Sockets.swift
//  Snippet
//
//  Created by Eli Zhang on 8/10/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import SocketIO
import SwiftyJSON
import Foundation

class Sockets {
    static let serverURL = "http://ec2-13-59-222-251.us-east-2.compute.amazonaws.com:8000"
    
    static var manager: SocketManager!
    static var socket: SocketIOClient!
    
    static func connect(completion: @escaping () -> Void) {
        Sockets.createConnection(queryParams: ["googleID": "\(UserInfo.getGoogleID())", "name": "\(UserInfo.getName())", "profilePic": "\(UserInfo.getProfilePhoto())", "sessionToken": "\(UserInfo.getSessionToken())"], completion: completion)
    }
    
    static func disconnect(completion: @escaping () -> Void) {
        if socket?.status == .connected {
            socket.disconnect()
            completion()
        }
    }
//
    static func createConnection(queryParams: [String:Any], completion: @escaping () -> Void = {}) {
        print("Creating connection...")
        self.manager = SocketManager(socketURL: URL(string: serverURL)!, config: [.log(false),.connectParams(queryParams)])
        self.socket = manager.defaultSocket
        socket.on("error") { data, ack  in
            if let arr = data as? [[String: Any]] {
                if let sessionToken = arr[0]["session_token"] as? String {
                    print("Updated session token successfully.")
                    UserInfo.setSessionToken(newToken: sessionToken)
                    Sockets.createConnection(queryParams: ["googleID": UserInfo.getGoogleID(),
                                                           "sessionToken": UserInfo.getSessionToken()])
                }
            }
            else {
                print("Socket error:")
                print(data)
            }
        }
        socket.on("connect") { data, ack in 
//            socket.emitWithAck("connection_test").timingOut(after: 5, callback: { response in
//                print("RESPONSE: \(response)")
//                if response as? [String] == ["NO ACK"] {
//                    print("Couldn't connect successfully.")
//                    Requests.updateSessionToken(updateToken: UserInfo.getUpdateToken(), completion: { newToken in
//                        print("Successfully updated session token. New token: \(newToken)")
//                        UserInfo.setSessionToken(newToken: newToken)
//                        createConnection(queryParams: ["googleID": UserInfo.getGoogleID(),
//                                                       "sessionToken": newToken], completion: completion)
//                    }, failure: {
//                        print("Failed to update session token.")
////                        let loginViewController = LoginViewController()
////                        if var topController = UIApplication.shared.keyWindow?.rootViewController {
////                            while let presentedViewController = topController.presentedViewController {
////                                topController = presentedViewController
////                            }
////                            loginViewController.modalPresentationStyle = .fullScreen
////                            topController.present(loginViewController, animated: true, completion: nil)
////                        }
//                    })
//                }
//                else {
//                    print("Connected successfully!")
//                    completion()
//                }
//            })
        }
        socket.on("disconnect") { data, ack in
//            self.unregisterMessageHandler()
        }
        socket.connect()
    }
//
    static func isConnected() -> Bool {
        if socket == nil {
            return false
        } else {
            while socket.status == .connecting {
                print("connecting...")
            }
            return socket.status == .connected
        }
    }
//
//    static func processJSONData(data: [Any], callback: @escaping (JSON) -> Void) {
//        guard let jsonData = data.first else {
//            return
//        }
//        if !JSONSerialization.isValidJSONObject(jsonData) {
//            return
//        }
//        guard let json = try? JSONSerialization.data(withJSONObject: jsonData) else {
//            return
//        }
//        do {
//            let jsonObject = try JSON(data: json)
//            callback(jsonObject)
//        } catch {
//            print("JSON Error: \(error)")
//        }
//    }
//
//    static func registerMessageHandler(messageFunction: @escaping (JSON) -> Void) {
//        if !isConnected() {
//            self.connect(completion: {
//                self.registerMessageHandler(messageFunction: messageFunction)
//            })
//            return
//        }
//        socket.on("message") { data, ack in
//            self.processJSONData(data: data, callback: { message in
//                print("Received message from server.")
//                messageFunction(message)
//            })
//        }
//    }
//
//    static func unregisterMessageHandler() {
//        if !isConnected() {
//            self.connect(completion: {
//                self.unregisterMessageHandler()
//            })
//            return
//        }
//        socket.off("message")
//    }
//
//    static func joinRoom(roomID: Int, name: String, callback: @escaping () -> Void) {
//        if !isConnected() {
//            self.connect(completion: {
//                self.joinRoom(roomID: roomID, name: name, callback: callback)
//            })
//            return
//        }
//        socket.emitWithAck("join", ["roomID": roomID]).timingOut(after: 5, callback: { _ in
//                                            callback()
//                                           })
//    }
//
//    static func leaveRoom(roomID: Int, name: String, callback: @escaping () -> Void) {
//        if !isConnected() {
//            self.connect(completion: {
//                leaveRoom(roomID: roomID, name: name, callback: callback)
//            })
//        }
//        socket.emitWithAck("leave", ["roomID": roomID]).timingOut(after: 5, callback: { _ in
//                                            callback()
//                                               })
//    }
//
//    static func messageRoom(parentMessageID: String, roomID: Int, name: String, photoLink: String, time: String, message: String, callback: @escaping () -> Void) {
//        if !isConnected() {
//            self.connect(completion: {
//                messageRoom(parentMessageID: parentMessageID, roomID: roomID, name: name, photoLink: photoLink, time: time, message: message, callback: callback)
//            })
//            return
//        }
//        else {
//            socket.emitWithAck("message", ["parentMessageID": parentMessageID,
//                                           "roomID": roomID,
//                                           "name": name,
//                                           "photoLink": photoLink,
//                                           "time": time,
//                                           "message": message]).timingOut(after: 5, callback: { _ in
//                                            callback()
//                                           })
//        }
//    }
//
//    static func smartMessageRoom(parentMessageID: String, roomID: Int, name: String, photoLink: String, time: String, message: String, command: String, parameters: [String: String], callback: @escaping () -> Void) {
//        if !isConnected() {
//            self.connect(completion: {
//                self.smartMessageRoom(parentMessageID: parentMessageID, roomID: roomID, name: name, photoLink: photoLink, time: time, message: message, command: command, parameters: parameters, callback: callback)
//            })
//            return
//        }
//        socket.emitWithAck("smart_message", ["parentMessageID": parentMessageID,
//                                         "roomID": roomID,
//                                         "name": name,
//                                         "photoLink": photoLink,
//                                         "time": time,
//                                         "message": message,
//                                         "command": command,
//                                         "parameters": parameters
//        ]).timingOut(after: 5, callback: { _ in
//            callback()
//        })
//    }
//
//    static func newRoom(otherUserID: String, otherUserName: String, otherUserPic: String, callback: @escaping (JSON) -> Void) {
//        if !isConnected() {
//            self.connect(completion: {
//                self.newRoomByName(otherUserName: otherUserName, callback: callback)
//            })
//            return
//        }
//        socket.emitWithAck("new_room", ["otherUserID": otherUserID, "otherUserName": otherUserName, "otherUserPic": otherUserPic]).timingOut(after: 5, callback: { data in
//            self.processJSONData(data: data, callback: { room in
//                print("Created room successfully.")
//                callback(room)
//            })
//        })
//    }
//
//    static func newRoomByName(otherUserName: String, callback: @escaping (JSON) -> Void) {
//        if !isConnected() {
//            self.connect(completion: {
//                self.newRoomByName(otherUserName: otherUserName, callback: callback)
//            })
//            return
//        }
//        socket.emitWithAck("new_room_by_name", ["otherUserName": otherUserName]).timingOut(after: 5, callback: { data in
//                self.processJSONData(data: data, callback: { room in
//                    print("Created room successfully.")
//                    callback(room)
//                })
//            })
//    }
//
//    static func react(messageID: String, reaction: String, callback: @escaping () -> Void) {
//        if !isConnected() {
//            self.react(messageID: messageID, reaction: reaction, callback: callback)
//            return
//        }
//        socket.emitWithAck("react", ["messageID": messageID, "reaction": reaction]).timingOut(after: 5, callback: { _ in
//            callback()
//        })
//    }
//
//    static func tagStar(messageID: String, command: String, value: String = "", callback: @escaping () -> Void) {
//        if !isConnected() {
//            self.tagStar(messageID: messageID, command: command, value: value, callback: callback)
//            return
//        }
//        socket.emitWithAck("tag_star", ["messageID": messageID, "command": command, "value": value]).timingOut(after: 5, callback: { _ in
//            callback()
//        })
//    }
//
//    static func getRoom(otherUserID: String, callback: @escaping () -> Void) {
//        if !isConnected() {
//            self.getRoom(otherUserID: otherUserID, callback: callback)
//            return
//        }
//        socket.emitWithAck("get_room", ["otherUserID": otherUserID]).timingOut(after: 5, callback: { _ in
//            callback()
//        })
//    }
//
//    static func getMessagesFromRoom(roomID: Int, callback: @escaping (JSON) -> Void) {
//        if !isConnected() {
//            self.connect(completion: {
//                self.getMessagesFromRoom(roomID: roomID, callback: callback)
//            })
//            return
//        }
//        socket.emitWithAck("get_messages", ["roomID": roomID]).timingOut(after: 5, callback: { data in
//            self.processJSONData(data: data, callback: { messages in
//                print("Got messages from server.")
//                callback(messages)
//            })
//        })
//    }
//
//    static func getThreadedMessagesFromRoom(roomID: Int, parentMessageID: String, callback: @escaping (JSON) -> Void) {
//        if !isConnected() {
//            self.connect(completion: {
//                self.getThreadedMessagesFromRoom(roomID: roomID, parentMessageID: parentMessageID, callback: callback)
//            })
//            return
//        }
//        socket.emitWithAck("get_threaded_messages", ["roomID": roomID, "parentMessageID": parentMessageID]).timingOut(after: 5, callback: { data in
//            self.processJSONData(data: data, callback: { messages in
//                print("Got threaded messages for parent message with ID \(parentMessageID) from server.")
//                callback(messages)
//            })
//        })
//    }
//
//    static func getUserInfo(callback: @escaping (JSON) -> Void) {
//        if !isConnected() {
//            self.connect(completion: {
//                self.getUserInfo(callback: callback)
//            })
//            return
//        }
//        print("Getting user info...")
//        socket.emitWithAck("get_user_info").timingOut(after: 5, callback: { data in
//            self.processJSONData(data: data, callback: { user in
//                print("Got user info from server.")
//                callback(user)
//            })
//        })
//    }
//
//    static func getFilteredUsers(query: String, callback: @escaping (JSON) -> Void) {
//        if !isConnected() {
//            self.connect(completion: {
//                self.getFilteredUsers(query: query, callback: callback)
//            })
//            return
//        }
//        socket.emitWithAck("get_filtered_users", ["query": query]).timingOut(after: 5, callback: { data in
//            self.processJSONData(data: data, callback: { filteredUsers in
//                print("Got filtered users.")
//                callback(filteredUsers)
//            })
//        })
//    }
}

