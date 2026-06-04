//
//  TripJournalView.swift
//  ALP_MAD
//
//  Created by student on 04/06/26.
//

import SwiftUI

struct TripJournalView: View {
    var body: some View {
        NavigationStack{
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        VStack {
                            Image(systemName: "camera")
                                .foregroundStyle(Color.orange)
                                .fontWeight(.bold)
                            Text("PHOTO")
                                .padding(.top, 8)
                                .foregroundStyle(Color.black)
                                .font(Font.caption2.bold())
                        }
                        .padding(16)
                        .padding(.horizontal, 32)
                    })
                    .background(Color.white)
                    .border(Color.gray, width: 1)
                    .cornerRadius(10)
                    .overlay{
                        RoundedRectangle(cornerRadius: 10.0).stroke(.gray, lineWidth: 1.0)
                    }
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        VStack {
                            Image(systemName: "pencil")
                                .fontWeight(.bold)
                            Text("WRITE")
                                .padding(.top, 8)
                                .font(Font.caption2.bold())
                        }
                        .padding(16)
                        .padding(.horizontal, 32)
                    })
                    .background(Color.orange)
                    .foregroundStyle(Color.white)
                    .cornerRadius(10)
                    Spacer()
                }
                JournalCards()
            }
            .navigationTitle("Trip Journal")
            .navigationSubtitle("Your authentic memories")
        }
    }
}

#Preview {
    TripJournalView()
}
