//
//  HealthMetricData.swift
//  StatusApp
//
//  Created by Area mobile on 12/04/25.
//
import UIKit

struct HealthMetricData {
    let metric: HealthMetric
    let values: [MetricValue]
}

struct MetricValue {
    let date: String
    let value: String
}

enum HealthMetric: String {
    case passi = "Passi"
    case frequenzaCardiaca = "Frequenza Cardiaca"
    case hrv = "HRV"
    case distanza = "Distanza"
    case energiaAttiva = "Energia Attiva"
    case sonno = "Sonno"
    case mindful = "Benessere mentale"
    
    var unit: String {
        switch self {
        case .passi: return "passi"
        case .frequenzaCardiaca: return "BPM"
        case .hrv: return "ms"
        case .distanza: return "km"
        case .energiaAttiva: return "kcal"
        case .sonno, .mindful: return "minuti"
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
}
