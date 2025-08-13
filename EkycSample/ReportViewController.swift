//
//  ReportViewController.swift
//  EkycSample
//
//  Created by Alchera on 2022/03/30.
//

import UIKit

class ReportViewController: UIViewController {
    static let storyboardID = "reportView"
    var result: String?
    var responseJson: String?
    private let NOTAVAILABLE = "N/A"
    private let alcheraColor = UIColor(named: "alcheraColor")
    
    @IBOutlet weak var txtEvent: UITextView!
    @IBOutlet weak var txtDetail: UITextView!
    
    @IBOutlet weak var idVerification: UIStackView!
    @IBOutlet weak var lblIdVerified: UILabel!
    @IBOutlet weak var imgIdMasking: UIImageView!
    @IBOutlet weak var imgIdOrigin: UIImageView!
    
    @IBOutlet weak var faceAuthentication: UIStackView!
    @IBOutlet weak var lblSimilarity: UILabel!
    @IBOutlet weak var imgIdCrop: UIImageView!
    @IBOutlet weak var imgSelfie: UIImageView!
    
    @IBOutlet weak var liveness: UIStackView!
    @IBOutlet weak var lblLive: UILabel!
    
    @IBOutlet weak var accountVerification: UIStackView!
    @IBOutlet weak var lblAccountVerification: UILabel!
    @IBOutlet weak var lblAccountUser: UILabel!
    @IBOutlet weak var lblAccountFinance: UILabel!
    @IBOutlet weak var lblFinanceCode: UILabel!
    @IBOutlet weak var lblAccountNumber: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "KYC Report"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    /* 완료 버튼 클릭 */
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        idVerification.isHidden = true
        faceAuthentication.isHidden = true
        liveness.isHidden = true
        accountVerification.isHidden = true
        
        txtEvent.layer.borderWidth = 1
        txtEvent.layer.borderColor = alcheraColor?.cgColor
        txtEvent.text = "result: \(result ?? "unknown")"
        
        if let jsonString = responseJson {
            txtDetail.text = prettyPrintedJson(jsonString)
            txtDetail.layer.borderWidth = 1
            txtDetail.layer.borderColor = alcheraColor?.cgColor
        }
        
        drawResponse()
    }
    
    /* KYC 응답 Message 결과에 따라 표시 */
    func drawResponse() {
        guard let responseJson = responseJson,
              let response = parsingJson(responseJson),
              let detail = response.review_result else { return }
        
        // 신분증 진위 확인
        if detail.module.id_card_ocr, detail.module.id_card_verification {
            idVerification.isHidden = false
            if let id_card = detail.id_card {
                lblIdVerified.text = id_card.verified ? "성공" : "실패"
                lblIdVerified.textColor = id_card.verified ? alcheraColor : .red
                imgIdMasking.image = UIImage(data: id_card.id_card_image ?? Data())
                imgIdOrigin.image = UIImage(data: id_card.id_card_origin ?? Data())
            } else {
                lblIdVerified.text = NOTAVAILABLE
            }
        }
        
        // 신분증 vs 셀피 유사도
        if detail.module.face_authentication {
            faceAuthentication.isHidden = false
            if let face_check = detail.face_check {
                lblSimilarity.text = (face_check.is_same_person != 0) ? "높음" : "낮음"
                lblSimilarity.textColor = (face_check.is_same_person != 0) ? alcheraColor : .red
                imgIdCrop.image = UIImage(data: detail.id_card?.id_crop_image ?? Data())
                imgSelfie.image = UIImage(data: face_check.selfie_image ?? Data())
            } else {
                lblSimilarity.text = NOTAVAILABLE
            }
        }
        
        // 얼굴 사진 진위 확인
        if detail.module.liveness {
            liveness.isHidden = false
            if let face_check = detail.face_check {
                lblLive.text = (face_check.is_live != 0) ? "성공" : "실패"
                lblLive.textColor = (face_check.is_live != 0) ? alcheraColor : .red
            } else {
                lblLive.text = NOTAVAILABLE
            }
        }
        
        // 1원 계좌 인증
        if detail.module.account_verification {
            accountVerification.isHidden = false
            if let account = detail.account {
                lblAccountVerification.text = account.verified ? "성공" : "실패"
                lblAccountVerification.textColor = account.verified ? alcheraColor : .red
                lblAccountUser.text = account.account_holder ?? NOTAVAILABLE
                lblAccountFinance.text = account.finance_company ?? NOTAVAILABLE
                lblFinanceCode.text = account.finance_code ?? NOTAVAILABLE
                lblAccountNumber.text = account.account_number ?? NOTAVAILABLE
            } else {
                lblAccountVerification.text = NOTAVAILABLE
            }
        }
    }
    
    /* 줄간격 적용된 JSON */
    func prettyPrintedJson(_ jsonString: String) -> String {
        if let jsonData = jsonString.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }
        
        return jsonString
    }
}
