import UIKit
import OpenTok
import os

class InCallViewController: UIViewController {
    var apiKey: String!
    var sessionId: String!
    var token: String!
    @IBOutlet var fullView: UIView!
    @IBOutlet var pipView: UIView!

    lazy var session: OTSession = {
        return OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)!
    }()
    
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    var subscriber: OTSubscriber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try AVAudioSession.sharedInstance().setPrefersNoInterruptionsFromSystemAlerts(true)
        } catch {
            os_log("Error: %@", log: .default, type: .error, String(describing: error))
        }
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // keep app from sleeping during survey
        UIApplication.shared.isIdleTimerDisabled = true

        showSpinner(message: "Connecting...", timeout: 0)
        
        doConnect()
    }
    
    /**
     * Asynchronously begins the session connect process. Some time later, we will
     * expect a delegate method to call us back with the results of this action.
     */
    fileprivate func doConnect() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.connect(withToken: token, error: &error)
    }

    func doDisconnect() {
        var error: OTError?
        session.disconnect(&error)
        if error != nil {
            os_log("Error: %@", log: .default, type: .error, String(describing: error))
        }
        performSegue(withIdentifier: "showCallEnded", sender: self)
    }
    
    /**
     * Sets up an instance of OTPublisher to use with this session. OTPubilsher
     * binds to the device camera and microphone, and will provide A/V streams
     * to the OpenTok session.
     */
    fileprivate func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.publish(publisher, error: &error)

        if let pubView = publisher.view {
            addTokBoxViewToView(pubView, pipView)
        }
    }

    func addTokBoxViewToView(_ tokBoxView: UIView, _ parentView: UIView) {
        // make sure it's not attached to another view
        tokBoxView.removeFromSuperview()

        parentView.addSubview(tokBoxView)

        // set constraint to match parentView's storyboard constraint
        tokBoxView.translatesAutoresizingMaskIntoConstraints = false
        tokBoxView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        tokBoxView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        tokBoxView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        tokBoxView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
    }
    
    /**
     * Instantiates a subscriber for the given stream and asynchronously begins the
     * process to begin receiving A/V content for this stream. Unlike doPublish,
     * this method does not add the subscriber to the view hierarchy. Instead, we
     * add the subscriber only after it has connected and begins receiving data.
     */
    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        
        session.subscribe(subscriber!, error: &error)
    }
    
    fileprivate func cleanupSubscriber() {
        subscriber?.view?.removeFromSuperview()
        subscriber = nil
    }
    
    fileprivate func cleanupPublisher() {
        publisher.view?.removeFromSuperview()
    }
    
    fileprivate func processError(_ error: OTError?) {
        if let err = error {
            DispatchQueue.main.async {
                let controller = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - OTSession delegate callbacks
extension InCallViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        os_log("Session connected", log: .default, type: .debug)
        doPublish()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        os_log("Session disconnected", log: .default, type: .debug)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        os_log("Session streamCreated: %@", log: .default, type: .debug, stream.streamId)
        if subscriber == nil {
            doSubscribe(stream)
        }
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        os_log("Session streamDestroyed: %@", log: .default, type: .debug, stream.streamId)
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            os_log("subscriber left session", log: .default, type: .debug)
            cleanupSubscriber()
        }
        doDisconnect()
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        os_log("session Failed to connect: %@", log: .default, type: .debug, error.localizedDescription)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
}

// MARK: - OTPublisher delegate callbacks
extension InCallViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        os_log("Publishing", log: .default, type: .debug)
        updateSpinnerMessage(message: "Other party is connecting...")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        os_log("Stream Destroyed", log: .default, type: .debug)
        cleanupPublisher()
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        os_log("Publisher failed: %@", log: .default, type: .debug, error.localizedDescription)
    }
}

// MARK: - OTSubscriber delegate callbacks
extension InCallViewController: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        if let subsView = subscriber?.view {
            removeSpinner()
            self.addTokBoxViewToView(subsView, self.fullView)
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        os_log("Subscriber failed: %@", log: .default, type: .debug, error.localizedDescription)
    }
}
