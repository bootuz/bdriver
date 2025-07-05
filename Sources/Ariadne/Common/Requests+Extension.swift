//
//  Requests+Extension.swift
//  Ariadne
//
//  Created by Астемир Бозиев on 05.03.2025.
//
import WebDriver

public extension Requests {

    struct DismissAlert: Request {
        public var session: String

        public var pathComponents: [String] { ["session", session, "alert", "dismiss"] }
        public var method: HTTPMethod { .post }
    }

    struct AcceptAlert: Request {
        public var session: String
        
        public var pathComponents: [String] { ["session", session, "alert", "accept"] }
        public var method: HTTPMethod { .post }
    }

    struct GetAlertText: Request {
        public var session: String
        
        public var pathComponents: [String] { ["session", session, "alert", "text"] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<String>
    }

    struct SendAlertText: Request {

        public var session: String
        public var text: String
        
        public var pathComponents: [String] { ["session", session, "alert"] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(text: text) }

        public struct Body: Codable {
            public var text: String
        }
    }
}
