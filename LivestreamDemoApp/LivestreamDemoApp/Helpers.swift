//
//  Helpers.swift
//  LivestreamDemoApp
//
//  Created by Martin Mitrevski on 6.8.24.
//

import SwiftUI

struct CircleRectangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Define the height of the circular part
        let circleHeight = rect.height / 3
        let radius = circleHeight
        let circleCenter = CGPoint(x: rect.midX, y: radius)

        // Draw the circular part at the top
        path.addArc(center: circleCenter,
                    radius: radius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: false)
        
        let maxX = circleCenter.x + radius
        let minX = circleCenter.x - radius

        // Move to the bottom of the circle
        path.addLine(to: CGPoint(x: maxX, y: circleHeight))

        // Draw the rectangular part
        path.addLine(to: CGPoint(x: maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: minX, y: circleHeight))

        // Close the path to complete the shape
        path.addLine(to: CGPoint(x: minX + radius, y: circleHeight))

        return path
    }
}

struct ShareButton: View {
    
    var content: [Any]
    @State var isSharePresented = false

    var body: some View {
        Button(action: {
            self.isSharePresented = true
        }, label: {
            Image(systemName: "square.and.arrow.up")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 28)
        })
        .foregroundColor(Color.pink)
        .sheet(isPresented: $isSharePresented) {
            ShareActivityView(activityItems: content)
        }
    }
}


struct ShareActivityView: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ShareActivityView>
    ) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.popoverPresentationController?.sourceView = UIApplication.shared.windows.first?.rootViewController?.view

        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ShareActivityView>
    ) { /* Not needed. */ }
}

struct ButtonModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.all, 8)
            .padding(.horizontal, 8)
            .background(Color.pink)
            .foregroundColor(.white)
            .cornerRadius(16)
    }
}

extension View {
    func addButtonStyle() -> some View {
        self.modifier(ButtonModifier())
    }
}
