//
//  HistoryView.swift
//  IOS-Project
//
//  Created by Warre Descamps on 20/12/2022.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var historyManager = HistoryManager.shared
    @StateObject var mangadex = SingletonManager.instance(key: "history")
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(sortInHeaders().sorted(by: { _,_ in true }), id: \.key) { key, histories in
                        HStack {
                            Text(key)
                                .font(Font.headline.weight(.semibold))
                                .padding()
                            Spacer()
                        }
                        ForEach(histories) { history in
                            if let manga = mangadex.manga.first(where: { $0.id == history.mangaId }),
                                let _ = history.lastRead {
                                HistoryRow(manga: manga, history: history)
                            }
                        }
                    }
                    Color.clear
                }
                .toolbar(.visible, for: .navigationBar)
                .toolbar(.visible, for: .tabBar)
                .ignoresSafeArea(.all, edges: .bottom)
            }
            .navigationTitle("History")
        }
        .onAppear(perform: initData)
    }
    
    private func initData() {
        mangadex.getMangaById(mangaIds: historyManager.fullHistory.map { $0.mangaId })
        HistoryManager.shared.fetchFullHistory()
    }
    
    private func sortInHeaders() -> [String: [History]] {
        let history = historyManager.fullHistory
            .sorted(by: { item1, item2 in item1.lastRead ?? Date.now > item2.lastRead ?? Date.now })
        var uniqueDates = [Date?]()
        uniqueDates = history
            .map {
                $0.lastRead ?? Date.now
            }
            .filter {
                let comps = Calendar.current.dateComponents([.day, .month, .year], from: $0 ?? Date.now)
                if uniqueDates.map({ Calendar.current.dateComponents([.day, .month, .year], from: $0 ?? Date.now) }).contains(comps) {
                    return false
                }
                uniqueDates.append(comps.date)
                return true
            }
        var historyHeaders: [String: [History]] = [:]
        for date in uniqueDates {
            historyHeaders[relativeDate(date: date ?? Date.now)] = history
                .filter {
                    Calendar.current.dateComponents([.day, .month, .year], from: $0.lastRead ?? Date.now) == Calendar.current.dateComponents([.day, .month, .year], from: date ?? Date.now)
                }
        }
        return historyHeaders
    }
    
    private func relativeDate(date: Date) -> String {
        if Calendar(identifier: .iso8601).dateComponents([.month], from: date, to: Date.now).day ?? 0 < 7 {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            let relativeDate = formatter.localizedString(for: date, relativeTo: Date.now)
            if relativeDate.contains("hour") || relativeDate.contains("minut") || relativeDate.contains("second") {
                return "Today"
            }
            if relativeDate.contains("1 day ago") {
                return "Yesterday"
            }
            return relativeDate
        }
        return date.formatted(date: .numeric, time: .omitted)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView_PreviewContainer()
    }
}

struct HistoryView_PreviewContainer: View {
    init() {
        _ = SingletonManager.userInstance(userId: DebugConstants.userId)
    }
    
    var body: some View {
        HistoryView()
    }
}
