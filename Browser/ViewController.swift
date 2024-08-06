import UIKit
import WebKit
import SwiftUI

class ViewController: UIViewController {

    private var webView: WKWebView!
    private var textField: UITextField!
    private var backButton: UIBarButtonItem!
    private var forwardButton: UIBarButtonItem!
    private var refreshButton: UIBarButtonItem!

    private var tabBar: UITabBar!
    private var backTabBarItem: UITabBarItem!
    private var forwardTabBarItem: UITabBarItem!
    private var clearTabBarItem: UITabBarItem!
    private var settingsTabBarItem: UITabBarItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        webView.navigationDelegate = self
        refreshNavigationControls()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

    @objc private func handleReturnPress(_ sender: UITextField) {
        guard let text = sender.text, let url = URL.httpURL(withString: text) else {
            return
        }
        webView.load(URLRequest(url: url))
    }

    @objc private func handleBackButtonPress(_ sender: UIBarButtonItem) {
        webView.stopLoading()
        webView.goBack()
    }

    @objc private func handleForwardButtonPress(_ sender: UIBarButtonItem) {
        webView.stopLoading()
        webView.goForward()
    }

    @objc private func handleRefreshButtonPress(_ sender: UIBarButtonItem) {
        webView.reload()
    }

    private func setupUI() {
        view.backgroundColor = .white

        textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter URL"
        textField.autocapitalizationType = .none // Prevent auto-capitalization
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(handleReturnPress(_:)), for: .editingDidEndOnExit)
        view.addSubview(textField)

        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        tabBar = UITabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.delegate = self
        view.addSubview(tabBar)

        backTabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "arrow.left"), tag: 0)
        forwardTabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "arrow.right"), tag: 1)
        clearTabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "trash"), tag: 2)
        settingsTabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "gear"), tag: 3)
        
        tabBar.items = [backTabBarItem, forwardTabBarItem, clearTabBarItem, settingsTabBarItem]

        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .white

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemGray
        ]
        
        let disabledAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemGray
        ]

        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemGray
        ]
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.disabled.titleTextAttributes = disabledAttributes
        appearance.stackedLayoutAppearance.disabled.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemGray

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            webView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func refreshNavigationControls() {
        backTabBarItem.isEnabled = webView.canGoBack
        forwardTabBarItem.isEnabled = webView.canGoForward
    }

    private func clearWebData() {
        removeWebView()
        createNewWebView()
        textField.text = ""
        loadHelloPage()
    }

    private func removeWebView() {
        webView.removeFromSuperview()
        webView.navigationDelegate = nil
        webView = nil
    }

    private func createNewWebView() {
        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
        ])
        refreshNavigationControls()
    }

    private func loadHelloPage() {
        let htmlString = ""
        webView.loadHTMLString(htmlString, baseURL: nil)
    }


    private func openSettings() {
        let settingsView = SettingsView()
        let hostingController = UIHostingController(rootView: settingsView)
        present(hostingController, animated: true, completion: nil)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        refreshNavigationControls()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if let urlString = webView.url?.absoluteString {
            if urlString != "about:blank" {
                textField.text = urlString
            } else {
                textField.text = ""
            }
        } else {
            textField.text = ""
        }
    }
}

extension ViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == backTabBarItem {
            webView.stopLoading()
            webView.goBack()
        } else if item == forwardTabBarItem {
            webView.stopLoading()
            webView.goForward()
        } else if item == clearTabBarItem {
            clearWebData()
        } else if item == settingsTabBarItem {
            openSettings()
        }
    }
}
