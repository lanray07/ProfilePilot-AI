import SwiftUI
import UIKit

struct PDFExportService {
    @MainActor
    func render(title: String, sections: [(String, String)]) -> URL? {
        let page = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let url = FileManager.default.temporaryDirectory.appending(path: "\(title.replacingOccurrences(of: " ", with: "-")).pdf")

        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                var y: CGFloat = 44
                draw(title, font: .boldSystemFont(ofSize: 26), at: CGPoint(x: 44, y: y))
                y += 46
                for section in sections {
                    draw(section.0, font: .boldSystemFont(ofSize: 16), at: CGPoint(x: 44, y: y))
                    y += 24
                    y += drawBody(section.1, in: CGRect(x: 44, y: y, width: 524, height: 180))
                    y += 22
                }
                draw(ComplianceNotice.text, font: .italicSystemFont(ofSize: 10), at: CGPoint(x: 44, y: 740))
            }
            return url
        } catch {
            return nil
        }
    }

    private func draw(_ text: String, font: UIFont, at point: CGPoint) {
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
        text.draw(at: point, withAttributes: attributes)
    }

    private func drawBody(_ text: String, in rect: CGRect) -> CGFloat {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: paragraph
        ]
        let attributed = NSAttributedString(string: text, attributes: attributes)
        attributed.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return min(180, attributed.boundingRect(with: rect.size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height)
    }
}
