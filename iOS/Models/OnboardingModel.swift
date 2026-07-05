//
//  OnboardingModel.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 05/07/26.
//

import SwiftUI

struct OnboardingModel {
    let title: String = "RAN UP"
    let subtitle: String = "YOUR HEALTH, YOUR PACE,\nYOUR JOURNEY"
    let totalPages: Int = 2

    let backgroundGradientStops: [Gradient.Stop] = [
        .init(color: Color(hex: "0B1313").opacity(0.98), location: 0.0),
        .init(color: Color(hex: "143534"), location: 0.39),
        .init(color: Color(hex: "275957"), location: 1.0)
    ]

    var backgroundGradient: LinearGradient {
        LinearGradient(
            stops: backgroundGradientStops,
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
 
        let r = Double((rgbValue >> 16) & 0xFF) / 255
        let g = Double((rgbValue >> 8) & 0xFF) / 255
        let b = Double(rgbValue & 0xFF) / 255
 
        self.init(red: r, green: g, blue: b)
    }
}

struct RightHeartbeat: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width
        let h = rect.height
        let mid = h / 2

        path.move(to: CGPoint(x: 0, y: mid))

        path.addLine(to: CGPoint(x: w * 0.15, y: mid))
        path.addLine(to: CGPoint(x: w * 0.3, y: h))
        path.addLine(to: CGPoint(x: w * 0.45, y: 0))
        path.addLine(to: CGPoint(x: w * 0.6, y: mid))
        path.addLine(to: CGPoint(x: w, y: mid))

        return path
    }
}

struct LeftHeartbeat: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width
        let h = rect.height
        let mid = h / 2

        path.move(to: CGPoint(x: 0, y: mid))
        path.addLine(to: CGPoint(x: w * 0.35, y: mid))
        path.addLine(to: CGPoint(x: w * 0.45, y: 0))
        path.addLine(to: CGPoint(x: w * 0.55, y: h))
        path.addLine(to: CGPoint(x: w * 0.7, y: mid))
        path.addLine(to: CGPoint(x: w, y: mid))

        return path
    }
}



struct RoundedCornerShape: Shape {
    var radius: CGFloat = 30
    var corners: UIRectCorner = .allCorners
 
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct EllipseTopShape: Shape {
    var curveHeight: CGFloat = 40
 
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: 0, y: curveHeight))

        path.addQuadCurve(
            to: CGPoint(x: width, y: curveHeight),
            control: CGPoint(x: width / 2, y: -curveHeight)
        )
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
 
        return path
    }
}
