//
//  JournalCards.swift
//  ALP_MAD
//
//  Created by student on 04/06/26.
//

import SwiftUI

struct JournalCards: View {
    @StateObject private var viewModel = TripJournalVM(journal: [])
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.journal) {index in
                    VStack {
                        ZStack {
                            Image(index.image)
                                .resizable()
                                .scaledToFit()
                            Rectangle()
                                .fill(.black.opacity(0.25))
                            VStack{
                                HStack {
                                    Image(systemName: "calendar")
                                    Text(index.date, format: .dateTime.day().month().year())
                                }
                                .foregroundStyle(Color.white)
                                .font(Font.caption)
                                Text(index.title)
                                    .font(Font.title.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 240, height: 240)
                        Text(index.entry)
                    }
                    .background(Color.white)
                }
            }
        }
    }
}

#Preview {
    JournalCards()
}
