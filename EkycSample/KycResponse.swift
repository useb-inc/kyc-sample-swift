//
//  KycResponse.swift
//  EkycSample
//
//  Created by Alchera on 2022/03/30.
//

import Foundation

struct KycResponse: Codable {
    let result: String
    let review_result: Review_result?
}

struct Review_result: Codable {
    let name: String
    let phone_number: String
    let birthday: String
    let module: Module
    let id_card: Id_card?
    let face_check: Face_check?
    let account: Account?
}

struct Module: Codable {
    let id_card_ocr: Bool
    let id_card_verification: Bool
    let face_authentication: Bool
    let account_verification: Bool
    let liveness: Bool
}

struct Id_card: Codable {
    let modified: Bool
    let verified: Bool
    let id_card_image: Data?
    let id_card_origin: Data?
    let id_crop_image: Data?
}

struct Face_check: Codable {
    let is_same_person: Int
    let is_live: Int
    let selfie_image: Data?
}

struct Account: Codable {
    let verified: Bool
    let account_holder: String?
    let finance_company: String?
    let finance_code: String?
    let account_number: String?
}

/* Json을 KycResponse로 변환합니다. */
func parsingJson(_ jsonString: String) -> KycResponse? {
    if let uriDecodedData = jsonString.data(using: .utf8) {
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(KycResponse.self, from: uriDecodedData)
            return response
        } catch let error {
            print("error: \(error)")
            return nil
        }
    }
    
    return nil
}
