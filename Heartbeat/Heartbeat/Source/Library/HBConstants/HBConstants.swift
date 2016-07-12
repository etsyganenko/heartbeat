//
//  HBConstants.swift
//  HeartBeat
//
//  Created by IDAP on 1/22/16.
//  Copyright © 2016 IDAP. All rights reserved.
//

import Foundation
import UIKit

let kHBMainStoryboardName               = "Main"

let kHBKeyFilterName                    = "filterName"
let kHBKeyParameterName                 = "parameterName"
let kHBKeyParameterDescription          = "parameterDescription"
let kHBKeyParameters                    = "parameters"
let kHBKeyMinimumValue                  = "minimumValue"
let kHBKeyMaximumValue                  = "maximumValue"
let kHBKeyDefaultValue                  = "defaultValue"
let kHBKeyEnabled                       = "enabled"

// AKBandPassFilter
let kHBCenterFrequencyDefaultValue      = 140.0 // Hz
let kHBBandwidthDefaultValue            = 600.0 // Cents

// AKBooster
let kHBGainDefaultValue                 = 1.0

// AKToneFilter
let kHBHalfPowerPointDefaultValue       = 1000.0 // Hz

// AKParametricEQ
let kHBQDefaultValue                    = 1.0 // Hz
let kHBEqGainDefaultValue               = 0.0 // dB

// AKPitchShifter
let kHBPitchShiftDefaultValue           = 12.0 // semitones
let kHBWindowSizeDefaultValue           = 4096.0 // samples
let kHBCrossfadeDefaultValue            = 10.0 // samples

// AKTimePitch
let kHBRateDefaultValue                 = 1.0
let kHBPitchDefaultValue                = 1.0 // Cents
let kHBOverlapDefaultValue              = 8.0

// AKLowPassFilter, AKHighPassFilter
let kHBCutoffFrequencyDefaultValue      = 6900.0 // Hz
let kHBResonanceDefaultValue            = 0.0 // dB

// bandpass 140 -> pitchshifter -> bandpass + delay
// lowpass -> ps -> highpass -> booster
