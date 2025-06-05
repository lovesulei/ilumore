//
//  MainView.swift
//  ilumore
//
//  Created by Love, Su Lei on 6/4/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import SDWebImageSwiftUI
import WidgetKit

struct MainScreen: View {
    @EnvironmentObject var appState: AppState
    
    @State private var yourData: LoveData?
    @State private var partnerData: LoveData?
    
    let dailyTarget = 50 // goal

    private let db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            Color(red: 0xFE / 255, green: 0xDC / 255, blue: 0xDB / 255)
                           .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20){
                HStack {
                    Spacer()
                    Button(action: signOut) {
                        Text("Sign Out")
                            .font(.custom("PixelifySans-Medium", size: 14))
                            .padding(8)
                            .foregroundColor(.white)
                            .background(Color(red: 252/255, green: 76/255, blue: 78/255))
                            .cornerRadius(8)
                    }.padding()
                    
                }
                Spacer()
                
                HStack {
                    Spacer()
                    Image("heart_pixel")
                        .resizable()
                        .frame(width: 25, height: 25)
                    
                    Text(winnerText)
                        .font(.custom("PixelifySans-Medium", size:25))
                        .padding(.horizontal)
                    
                    Image("heart_pixel")
                        .resizable()
                        .frame(width: 25, height: 25)
                    
                    Spacer()
                }
                
                ZStack {
                    Image("day_bg")
                        .resizable()
                        .frame(width: 380, height: 250)
                        .cornerRadius(20)
                        .clipped()
                        .padding()
                    
                    VStack(spacing:20) {
                        HStack {
                            if yourData?.color == "black" {
                                catView(for: yourData, label: "You")
                                    .padding(.leading, 20)
                                Spacer()
                                catView(for:partnerData, label: "Partner")
                                    .padding(.trailing, 20)
                            } else {
                                catView(for: partnerData, label: "You")
                                    .padding(.leading, 20)
                                Spacer()
                                catView(for:yourData, label: "Partner")
                                    .padding(.trailing, 20)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
                .onAppear{
                    loadData()
                    checkAndResetCountsIfNeeded()
                }
                .onChange(of: yourData) { _ in
                    tryUpdateWidgetData()
                }.onChange(of: partnerData) { _ in
                    tryUpdateWidgetData()
                }
                
                VStack(spacing:10) {
                    Button(action: sendLove) {
                        Text("I Love You <3")
                            .font(.custom("PixelifySans-Medium", size: 20))
                            .padding()
                            .background(Color(red: 252/255, green: 76/255, blue: 78/255))
                            .foregroundColor(.white)
                            .cornerRadius(40)
                    }
                    .disabled(yourData?.count == (dailyTarget - 1) && yourData?.color == "black" ? true : false)
                    .padding(.horizontal, 40)
                    
                    Text("Daily Goal: \(dailyTarget)")
                        .font(.custom("PixelifySans-Medium", size: 16))
                        .padding(.bottom, 20)
                }
                Spacer()
            }
            .padding(20)
        }
    }
    
    func updateWidgetSharedData() {
        guard let yourData = yourData, let partnerData = partnerData else { return }
        
        let defaults = UserDefaults(suiteName:"group.com.lovesulei.ilumore")
        
        defaults?.set(yourData.count, forKey: "yourCount")
        defaults?.set(partnerData.count, forKey: "partnerCount")
               defaults?.set(yourData.color, forKey: "yourColor")
               defaults?.set(partnerData.color, forKey: "partnerColor")
               defaults?.set(winnerText, forKey: "winnerText")
        
        WidgetCenter.shared.reloadAllTimelines()

    }
    
    func tryUpdateWidgetData() {
        if yourData != nil && partnerData != nil {
            updateWidgetSharedData()
        }
    }
    
    func heartImageName(for count: Int) -> String {
        switch count {
        case 0..<50: return "25"
        case 50..<75: return "50"
        case 75..<100: return "100"
        default: return "100"
        }
    }
    
    func progressPercent(for count: Int) -> Double {
        let percent = (Double(count) / Double(dailyTarget)) * 100
        return min(percent, 100)
    }
    
    func loadData() {
        guard !appState.userCode.isEmpty else { return }
        
        if let uid = Auth.auth().currentUser?.uid {
            db.collection(FirebaseManager.shared.users)
                .document(uid)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error fetching yourData: \(error)")
                        return
                    }
                    guard let snapshot = snapshot, snapshot.exists else {
                        print("No documents found for your uId")
                        return
                    }
                    do {
                        let data = try snapshot.data(as: LoveData.self)
                        
                        DispatchQueue.main.async {
                            self.yourData = data
                        }
                    } catch {
                        print("Error decoding yourData: \(error)")
                    }
                }
        }
        print("MainView: partnerUid = \(appState.partnerUid)")
        
        guard !appState.partnerUid.isEmpty else { return }
        
        print("Partner UID: \(appState.partnerUid)")
        
        db.collection(FirebaseManager.shared.users)
            .document(appState.partnerUid)
            .addSnapshotListener { docSnapshot, error in
                if let error = error {
                    print("Error fetching partnerData by UID: \(error)")
                    return
                }
                
                guard let doc = docSnapshot, doc.exists else {
                    print("No parnter document found for UID: \(appState.partnerUid)")
                    return
                }
                
                do {
                    let data = try doc.data(as: LoveData.self)
                    DispatchQueue.main.async {
                        self.partnerData = data
                        print("Loaded partnerData: \(data.username), color: \(data.color), count: \(data.count)")
                    }
                }catch {
                    print("Error decoding partnerData: \(error)")
                }
                
            }
    }
    
    func sendLove() {
        checkAndResetCountsIfNeeded()
        guard var data = yourData else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        let lastUpdate = data.lastUpdated.map { Calendar.current.startOfDay(for: $0)}
        
        if lastUpdate == nil || lastUpdate! < today {
            data.count = 0
        }
        
        data.count += 1
        data.lastUpdated = Date()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No uid found")
            return
        }
        
        db.collection(FirebaseManager.shared.users)
            .document(uid)
            .updateData([
                "count": data.count,
                "lastUpdated": Timestamp(date: data.lastUpdated ?? Date())
            ]) { error in
                if let error = error {
                    print("error: \(error)")
                } else {
                    print("Love count updated success.")
                }
            }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
                  appState.userCode = ""
                  appState.partnerUid = ""
                  appState.partnerCode = ""
                  appState.color = ""
                  appState.count = 0
                  appState.lastUpdated = Date()
                  appState.isConnected = false
                  appState.isSignedIn = false
        } catch {
            print("error signing out:\(error.localizedDescription)")
        }
    }
    
    // reset at midnight
    func checkAndResetCountsIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        
        let yourDoc = db.collection(FirebaseManager.shared.users).document(appState.userCode)
        
        let partnerDoc =
        db.collection(FirebaseManager.shared.users).document(appState.partnerCode)
        
        yourDoc.getDocument { yourSnapshot, _ in
            partnerDoc.getDocument { partnerSnapshot, _ in
                guard
                    let yourData = try? yourSnapshot?.data(as: LoveData.self),
                    let partnerData = try? partnerSnapshot?.data(as: LoveData.self)
                        
                else { return }
                
                let yourLast = yourData.lastUpdated.map { Calendar.current.startOfDay(for: $0)} ?? .distantPast
                
                let partnerLast = partnerData.lastUpdated.map {
                    Calendar.current.startOfDay(for: $0)} ?? .distantPast
                
                if yourLast < today || partnerLast < today {
                    var resetYourData = yourData
                    var resetPartnerData = partnerData
                    
                    resetYourData.count = 0
                    resetYourData.lastUpdated = Date()
                    
                    resetPartnerData.count = 0
                    resetPartnerData.lastUpdated = Date()
                    
                    do {
                        try yourDoc.setData(from: resetYourData)
                        try partnerDoc.setData(from: resetPartnerData)
                    } catch {
                        print("Error resetting counts: \(error)")
                    }
                }
                
            }
            
            
        }
    }
    
    @ViewBuilder
    func catView(for data: LoveData?, label: String) -> some View {
        VStack {
            if let data = data {
                Text("\(data.count)")
                    .font(.custom("PixelifySans-Medium", size: 25))
                AnimatedImage(name: "\(data.color)_\(heartImageName(for: Int(progressPercent(for: data.count)))).GIF")
                                 .resizable()
                                 .frame(width: 100, height: 100)
                             Text(data.username)
                                 .font(.custom("PixelifySans-Medium", size: 18))

            }
        }
    }
    
    var winnerText: String {
        if let your = yourData, let partner = partnerData {
            if your.count >= dailyTarget && your.count > partner.count {
                return "\(your.username) wins today"
            } else if partner.count >= dailyTarget && partner.count > your.count {
                return "\(partner.username) wins today"
            }
        }
        return "Who loves more?"
    }
    
}

