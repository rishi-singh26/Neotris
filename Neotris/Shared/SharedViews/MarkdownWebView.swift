//
//  MarkdownWebView.swift
//  Neotris
//
//  Created by Rishi Singh on 31/03/25.
//

import SwiftUI
import MarkdownUI
import UniformTypeIdentifiers

struct MarkdownWebView: View {
    @Environment(\.dismiss) var dismiss

    let url: URL

    @State private var markdownContent: String?
    @State private var isLoading = true
    @State private var error: Error?
    @State private var showingFileExporter = false
    @State private var fileExportURL: URL?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else if let markdown = markdownContent {
                ScrollView {
                    Markdown(markdown)
                        .markdownTextStyle {
                            FontSize(16)
                        }
                        .padding()
                }
            } else if let error = error {
                Text("Error loading content: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                Text("Content not found")
            }
        }
        .onAppear {
            loadMarkdown()
        }
        .toolbar {
            if let markdownContent = markdownContent, !markdownContent.isEmpty {
                Button("Export") {
                    exportMarkdown()
                }
            }
        }
        .fileExporter(isPresented: $showingFileExporter, document: MarkdownDocument(markdownContent ?? ""), contentType: UTType(filenameExtension: "md")!, defaultFilename: url.lastPathComponent) { result in
            switch result {
            case .success(let url):
                fileExportURL = url
                print("Exported to \(url)")
            case .failure(let error):
                print("Export error: \(error)")
            }
        }
#if os(macOS)
        .toolbar {
            Button("Done") {
                dismiss()
            }
        }
#else
        .toolbar(content: {
            ToolbarItem {
                Button {
                    dismiss()
                } label: {
                    Label("Dismiss", systemImage: "xmark.circle.fill")
                }
                
            }
        })
#endif
    }

    private func loadMarkdown() {
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    self.error = error
                    return
                }

                guard let data = data, let markdown = String(data: data, encoding: .utf8) else {
                    self.error = NSError(domain: "MarkdownWebView", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])
                    return
                }

                self.markdownContent = markdown
            }
        }.resume()
    }
    
    func exportMarkdown() {
        showingFileExporter = true
    }
}

struct MarkdownDocument: FileDocument {
    static var readableContentTypes: [UTType] { [UTType(filenameExtension: "md")!] }
    static var writableContentTypes: [UTType] { [UTType(filenameExtension: "md")!] }

    var text: String

    init(_ text: String) {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    //    https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/main/Assets/TermsOfUse.md
    //    https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/main/Assets/PrivacyPolicy.md
    if let url = URL(string: "https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/main/LICENSE") {
        MarkdownWebView(url: url)
    } else {
        Text("Invalid URL")
    }
}
