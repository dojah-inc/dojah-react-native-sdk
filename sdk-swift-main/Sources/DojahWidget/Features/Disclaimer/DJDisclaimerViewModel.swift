//
//  DJDisclaimerViewModel.swift
//
//
//  Created by Isaac Iniongun on 07/12/2023.
//

import Foundation

final class DJDisclaimerViewModel: BaseViewModel {
    weak var viewProtocol: DJDisclaimerViewProtocol?
    var canSeeCountryPage: Bool {
        preference.DJCanSeeCountryPage
    }
    
    func checkSupportedCountry() {
        guard let countries = preference.preAuthResponse?.widget?.countries, countries.isNotEmpty, countries.contains(preference.DJIPCountry) else {
            showCountryNotSupportedError()
            return
        }
    }
    
    private func showCountryNotSupportedError() {
        viewProtocol?.enableContinueButton(false)
        viewProtocol?.showErrorMessage(DJSDKError.countryNotSupported.uiMessage)
    }
    
    func postStepCompletedEvent() {
        postEvent(
            request: .init(name: .stepCompleted, value: "index"),
            didSucceed: { [weak self] eventRes in
                runAfter { [weak self] in
                    self?.setNextAuthStep()
                }
            },
            didFail: { error in
                kprint("couldn't post index event")
            }
        )
    }
    
}
