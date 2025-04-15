import SwiftUI
import WebKit

struct PowerOf10View: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
            }
            
            WebView(url: URL(string: "https://www.thepowerof10.info/")!) { loading in
                isLoading = loading
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct ResourcesListView: View {
    @StateObject private var resourceManager = CoachResourceManager.shared
    
    var body: some View {
        List {
            ForEach(resourceManager.resources) { resource in
                ResourceRow(resource: resource)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct VideosListView: View {
    @StateObject private var videoManager = VideoManager.shared
    
    var body: some View {
        List {
            ForEach(videoManager.videos) { video in
                VideoRow(video: video)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct ArticlesListView: View {
    @StateObject private var articleManager = ArticleManager.shared
    
    var body: some View {
        List {
            ForEach(articleManager.articles) { article in
                ArticleRow(article: article)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct ResourceRow: View {
    let resource: CoachResource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(resource.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(resource.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Label(resource.category, systemImage: "folder")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Label(resource.dateAdded.formatted(date: .abbreviated, time: .omitted),
                      systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

struct VideoRow: View {
    let video: Video
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(video.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(video.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Label(video.duration, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Label(video.dateAdded.formatted(date: .abbreviated, time: .omitted),
                      systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

struct ArticleRow: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(article.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Label(article.author, systemImage: "person")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Label(article.dateAdded.formatted(date: .abbreviated, time: .omitted),
                      systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - WebView

struct WebView: UIViewRepresentable {
    let url: URL
    var onLoadStatusChange: ((Bool) -> Void)? = nil
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.onLoadStatusChange?(true)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onLoadStatusChange?(false)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.onLoadStatusChange?(false)
        }
    }
} 