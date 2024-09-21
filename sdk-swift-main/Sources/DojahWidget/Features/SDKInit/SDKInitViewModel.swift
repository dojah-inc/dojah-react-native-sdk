//
//  SDKInitViewModel.swift
//
//
//  Created by Isaac Iniongun on 01/12/2023.
//

import Foundation
import UIKit
import WebKit
import IQKeyboardManagerSwift
import GooglePlaces

 final class SDKInitViewModel {
    weak var viewProtocol: SDKInitViewProtocol?
    private let widgetID: String
    private var preference: PreferenceProtocol
    private let countriesDatasource: CountriesLocalDatasourceProtocol
    private let authenticationRemoteDatasource: AuthenticationRemoteDatasourceProtocol
    private var authResponse: DJAuthResponse?
    private var preAuthRes: DJPreAuthResponse?
    private let referenceID: String?
    private let emailAddress: String?
    
    init(
        widgetID: String,
        referenceID: String? = nil,
        emailAddress: String? = nil,
        preference: PreferenceProtocol = PreferenceImpl(),
        countriesDatasource: CountriesLocalDatasourceProtocol = CountriesLocalDatasource(),
        authenticationRemoteDatasource: AuthenticationRemoteDatasourceProtocol = AuthenticationRemoteDatasource()
    ) {
        self.widgetID = widgetID
        self.referenceID = referenceID
        self.emailAddress = emailAddress
        self.preference = preference
        self.preference.DJWidgetID = widgetID
        self.countriesDatasource = countriesDatasource
        self.authenticationRemoteDatasource = authenticationRemoteDatasource
    }
    
    
     @MainActor func initialize() {
        IQKeyboardManager.shared.enable = true
        
        GMSPlacesClient.provideAPIKey("AIzaSyCGc1Yvx5sbnMklpcwg6A8bkKuDzNMbWu4")
        
        preference.DJAuthStep = .index
        
        viewProtocol?.showLoader(true)
        getUserAgent()
        
        guard !preference.DJConfigurationInitialized else {
            preAuthenticate()
            return
        }
        
        guard let countriesJsonData = jsonData(from: "countries"),
              let governmentIDConfigJsonData = jsonData(from: "government_data_config"),
              let pricingConfigJsonData = jsonData(from: "pricing_config")
        else {
            initializationDidFail()
            return
        }
        
        do {
            let countries = try countriesJsonData.decode(into: [DJCountry].self)
            let dbCountries = countries.map { $0.countryDB }
            try countriesDatasource.saveCountries(dbCountries)
            
            let governmentIDConfig = try governmentIDConfigJsonData.decode(into: DJGovernmentIDConfig.self)
            preference.DJGovernmentIDConfig = governmentIDConfig
            
            let pricingServicesConfig = try pricingConfigJsonData.decode(into: PricingServicesConfig.self)
            preference.DJPricingServicesConfig = pricingServicesConfig
            
            preference.DJConfigurationInitialized = true
            preAuthenticate()
        } catch {
            initializationDidFail(error: error)
        }
    }
    
    private func initializationDidFail(error: Error? = nil) {
        if let error {
            kprint("\(error)")
        }
        viewProtocol?.showLoader(false)
        viewProtocol?.showSDKInitFailedView()
    }
    
    private func preAuthenticate() {
        let params = ["widget_id": widgetID]
        authenticationRemoteDatasource.getPreAuthenticationInfo(params: params) { [weak self] result in
            switch result {
            case let .success(preAuthRes):
                self?.didGetPreAuthenticationResponse(preAuthRes)
            case .failure(let error):
                self?.initializationDidFail(error: error)
            }
        }
    }
    
    private func didGetPreAuthenticationResponse(_ preAuthRes: DJPreAuthResponse) {
        guard preAuthRes.widget?.pages?.isNotEmpty ?? false else {
            initializationDidFail()
            return
        }
        self.preAuthRes = preAuthRes
        preference.preAuthResponse = preAuthRes
        if let appConfig = preAuthRes.appConfig {
            preference.DJAppConfig = appConfig
        }
        preference.DJCanSeeCountryPage = preAuthRes.widget?.countries?.isNotEmpty ?? false
        authenticate(using: preAuthRes)
    }
    
    private func authenticate(using preAuthRes: DJPreAuthResponse) {
        var params: DJParameters = [
            "app_id": preAuthRes.appConfig?.id ?? "",
            "public_key": preAuthRes.publicKey.orEmpty,
            "type": "kyc",
            "review_process": preAuthRes.widget?.reviewProcess ?? "Automatic",
            "steps": createStepsParameters()
        ]
        
        if let referenceID, referenceID.isNotEmpty {
            params["reference_id"] = referenceID
        }
        
        if let emailAddress, emailAddress.isNotEmpty {
            params["email"] = emailAddress
        }
        
        authenticationRemoteDatasource.authenticate(params: params) { [weak self] result in
            switch result {
            case let .success(authResponse):
                self?.didGetAuthenticationResponse(authResponse: authResponse)
            case let .failure(error):
                if error == .verificationCompleted {
                    self?.viewProtocol?.showVerificationSuccessful()
                } else {
                    self?.initializationDidFail(error: error)
                }
            }
        }
    }
    
    private func didGetAuthenticationResponse(authResponse: DJAuthResponse) {
        guard authResponse.initData.isNotNil else {
            initializationDidFail()
            return
        }
        self.authResponse = authResponse
        cacheWidgetID()
        guard let preAuthRes else { return }
        preference.DJRequestHeaders = [
            "authorization": UUID().uuidString,
            "app-id": preAuthRes.appConfig?.id ?? authResponse.appConfig?.id ?? "",
            "p-key": preAuthRes.publicKey.orEmpty,
            "session": authResponse.sessionID.orEmpty,
            "reference": authResponse.initData?.data?.referenceID ?? ""
        ]
        preference.DJVerificationID = authResponse.initData?.data?.verificationID ?? 0
        if (referenceID.orEmpty.isNotEmpty || emailAddress.orEmpty.isNotEmpty),
            let steps = authResponse.initData?.data?.steps?.by(statuses: [.notdone, .pending, .failed]), 
            steps.isNotEmpty {
            preference.DJSteps = steps
        } else {
            preference.DJSteps = authResponse.initData?.data?.steps ?? []
        }
        
        getIPAddress()
    }
    
    private func createStepsParameters() -> [DJParameters] {
        guard let preAuthRes else { return [] }
        var steps = [DJAuthStep]()
        var currentID = 0
        steps.append(.init(name: .index, id: 0, config: .init()))
        
        let emailPageConfig = preAuthRes.widget?.pages?.by(pageName: .email)?.config ?? .init()
        currentID += 1
        steps.append(.init(name: .email, id: currentID, config: emailPageConfig))
        
        if (preAuthRes.widget?.countries ?? []).countGreaterThan(1) {
            currentID += 1
            steps.append(.init(name: .countries, id: currentID, config: .init(configDefault: "")))
        }
        
        let userDataPage = preAuthRes.widget?.pages?.by(pageName: .userData)
        if let userDataPage {
            currentID += 1
            steps.append(.init(name: .userData, id: currentID, config: userDataPage.config ?? .init()))
        }
        
        let pages = preAuthRes.widget?.pages?.filter { ![.userData, .email].contains($0.pageName) } ?? []
        guard pages.isNotEmpty else {
            return steps.map { $0.dictionary }
        }
        
        for page in pages {
            if let pageName = page.pageName {
                currentID += 1
                switch pageName {
                case .governmentData:
                    steps.append(.init(name: .governmentData, id: currentID, config: page.config ?? .init()))
                    let verifications = [page.config?.otp ?? false, page.config?.selfie ?? false]
                    if verifications.contains(true) {
                        currentID += 1
                        steps.append(.init(name: .governmentDataVerification, id: currentID, config: page.config ?? .init()))
                    }
                case .id:
                    steps.append(.init(name: .idOptions, id: currentID, config: .init()))
                    currentID += 1
                    steps.append(.init(name: .id, id: currentID, config: page.config ?? .init()))
                default:
                    steps.append(.init(name: pageName, id: currentID, config: page.config ?? .init()))
                }
            }
        }
        
        kprint(String(describing: steps.dictionaryArray))
        
        return steps.map { $0.dictionary }
    }
    
    private func getIPAddress() {
        authenticationRemoteDatasource.getIPAddress { [weak self] result in
            switch result {
            case let .success(ipAddress):
                self?.saveIPAddress(ipAddress)
            case let .failure(error):
                self?.initializationDidFail(error: error)
            }
        }
    }
    
    private func saveIPAddress(_ ipAddress: DJIPAddress) {
        guard ipAddress.ip != "" else {
            initializationDidFail()
            return
        }
        let parameters: DJParameters = [
            "ip": ipAddress.ip.orEmpty,
            "device_info": preference.DJUserAgent
        ]
        authenticationRemoteDatasource.saveIPAddress(params: parameters) { [weak self] result in
            switch result {
            case let .success(ipAddressResponse):
                runOnMainThread {
                    self?.didSaveIPAddress(response: ipAddressResponse)
                }
            case let .failure(error):
                self?.initializationDidFail(error: error)
            }
        }
    }
    
    private func didSaveIPAddress(response: DJIPAddressResponse) {
        guard let country = response.entity?.country, country.isNotEmpty else {
            initializationDidFail()
            return
        }
        
        guard let dbCountry = countriesDatasource.getCountryByName(country),
              let preAuthCountries = preference.preAuthResponse?.widget?.countries,
              preAuthCountries.isNotEmpty,
              preAuthCountries.contains(dbCountry.iso2)
        else {
            viewProtocol?.showCountryNotSupportedError()
            return
        }
        
        preference.DJIPCountry = dbCountry.iso2
        viewProtocol?.showDisclaimer()
    }
    
    private func getUserAgent() {
        guard preference.DJUserAgent.isEmpty else { return }
        if let userAgent = WKWebView().value(forKey: "userAgent") as? String {
            kprint("UserAgent: \(userAgent)")
            preference.DJUserAgent = userAgent
        } else {
            kprint("Unable to get UserAgent")
        }
    }
    
    private func cacheWidgetID() {
        let widgetIDAlreadyCached = preference.WidgetIDCache.first { $0.widgetID.insensitiveEquals(widgetID) }
        guard let authResponse, widgetIDAlreadyCached == nil  else { return }
        preference.WidgetIDCache.append(.init(companyName: authResponse.companyName ?? "", widgetID: widgetID))
    }
}
