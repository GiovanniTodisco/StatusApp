//
//  HealthMetricData.swift
//  StatusApp
//
//  Created by Area mobile on 12/04/25.
//
import UIKit
import HealthKit

struct HealthMetricData : Codable{
    let metric: HealthMetric
    let values: [MetricValue]
}

struct MetricValue : Codable {
    let date: String
    let value: String
}

enum HealthMetric: String, CaseIterable, Codable {
    case passi = "Passi"
    case frequenzaCardiaca = "Frequenza Cardiaca"
    case hrv = "HRV"
    case distanza = "Distanza"
    case energiaAttiva = "Energia Attiva"
    case sonno = "Sonno"
    case mindful = "Benessere mentale"
    
    var unit: String {
        switch self {
        case .passi: return NSLocalizedString("steps_lowercase", comment: "")
        case .frequenzaCardiaca: return NSLocalizedString("BPM", comment: "")
        case .hrv: return NSLocalizedString("ms", comment: "")
        case .distanza: return NSLocalizedString("m", comment: "")
        case .energiaAttiva: return NSLocalizedString("kcal", comment: "")
        case .sonno: return NSLocalizedString("ore", comment: "")
        case .mindful: return NSLocalizedString("min", comment: "")
        }
    }
    
    var iconName: String {
        switch self {
        case .passi: return "figure.walk"
        case .frequenzaCardiaca: return "heart.fill"
        case .hrv: return "waveform.path.ecg"
        case .distanza: return "location"
        case .energiaAttiva: return "flame.fill"
        case .sonno: return "bed.double.fill"
        case .mindful: return "brain.head.profile"
        }
    }
    
    var color: UIColor {
        switch self {
        case .passi: return AppColor.passiIconColor
        case .frequenzaCardiaca: return AppColor.heartIconColor
        case .hrv: return AppColor.heartIconColor
        case .distanza: return AppColor.distanceIconColor
        case .energiaAttiva: return AppColor.passiIconColor
        case .sonno: return AppColor.sleepIconColor
        case .mindful: return AppColor.mentalIconColor
        }
    }
    
    var attributedDescription: NSAttributedString {
        let titleFont = AppFont.title
        let bodyFont = AppFont.description
        let color = AppColor.primaryText

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 12

        let attributed = NSMutableAttributedString()

        switch self {
        case .passi:
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_passi_title1", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_passi_body1", comment: "") + "\n\n", attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_passi_title2", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_passi_body2", comment: ""), attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
        case .frequenzaCardiaca:
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_frequenzaCardiaca_title1", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_frequenzaCardiaca_body1", comment: "") + "\n\n", attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_frequenzaCardiaca_title2", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_frequenzaCardiaca_body2", comment: ""), attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
        case .hrv:
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_hrv_title1", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_hrv_body1", comment: "") + "\n\n", attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_hrv_title2", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_hrv_body2", comment: ""), attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
        case .distanza:
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_distanza_title1", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_distanza_body1", comment: "") + "\n\n", attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_distanza_title2", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_distanza_body2", comment: ""), attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
        case .energiaAttiva:
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_energiaAttiva_title1", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_energiaAttiva_body1", comment: "") + "\n\n", attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_energiaAttiva_title2", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_energiaAttiva_body2", comment: ""), attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
        case .sonno:
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_sonno_title1", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_sonno_body1", comment: "") + "\n\n", attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_sonno_title2", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_sonno_body2", comment: ""), attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
        case .mindful:
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_mindful_title1", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_mindful_body1", comment: "") + "\n\n", attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_mindful_title2", comment: "") + "\n", attributes: [
                .font: titleFont,
                .foregroundColor: color
            ]))
            attributed.append(NSAttributedString(string: NSLocalizedString("metric_mindful_body2", comment: ""), attributes: [
                .font: bodyFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]))
        }

        return attributed
    }

    static func metricFrom(type: HKObjectType) -> HealthMetric? {
        switch type {
        case HKObjectType.quantityType(forIdentifier: .heartRate): return .frequenzaCardiaca
        case HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN): return .hrv
        case HKObjectType.quantityType(forIdentifier: .stepCount): return .passi
        case HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning): return .distanza
        case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned): return .energiaAttiva
        case HKObjectType.categoryType(forIdentifier: .sleepAnalysis): return .sonno
        case HKObjectType.categoryType(forIdentifier: .mindfulSession): return .mindful
        default: return nil
        }
    }
}
