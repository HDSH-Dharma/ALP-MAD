//
//  TripDashboardView.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import SwiftUI

struct DummyTrip: Identifiable {
    let id = UUID()
    let destination: String
    let dateRange: String
    let imageSystemName: String
    let tag: String
}

struct TripDashboardView: View {
    private let sampleTrips = [
        DummyTrip(destination: "Eksplorasi Budaya Yogyakarta", dateRange: "12 - 15 Jun 2026", imageSystemName: "building.columns.fill", tag: "6 Destinasi UMKM"),
        DummyTrip(destination: "Pesona Pantai & Kuliner Bali", dateRange: "02 - 08 Jul 2026", imageSystemName: "beach.umbrella.fill", tag: "12 Destinasi UMKM"),
        DummyTrip(destination: "Heritage Tour Semarang", dateRange: "20 - 22 Agu 2026", imageSystemName: "tram.fill", tag: "4 Destinasi UMKM")
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // --- 1. HEADER PROFILE & GREETING ---
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Halo, Petualang! 👋")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Dhevin Tandiono")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.themeDarkText)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.themeGold)
                            .frame(width: 50, height: 50)
                        Text("DT")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color.themeGold.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 16)
                
                // --- 2. STATS CARD ---
                VStack(spacing: 16) {
                    HStack {
                        Text("Kontribusi Liburan Anda")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.themeDarkText.opacity(0.8))
                            .textCase(.uppercase)
                        Spacer()
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.themeTeal)
                            .font(.caption)
                    }
                    
                    HStack(spacing: 0) {
                        VStack(alignment: .center, spacing: 6) {
                            Text("12")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.themeBlue)
                            Text("Tempat Dikunjungi")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Rectangle()
                            .fill(Color.themeTeal.opacity(0.3))
                            .frame(width: 1, height: 45)
                        
                        VStack(alignment: .center, spacing: 6) {
                            Text("28")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.themeTeal)
                            Text("UMKM Didukung")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.themeTurquoiseLight)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.themeTeal.opacity(0.2), lineWidth: 1)
                )
                
                // --- 3. PROMOTIONAL BANNER ---
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            colors: [Color.themeTeal, Color.themeBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ayo Jelajahi Nusantara")
                            .font(.headline)
                            .foregroundColor(.themeGold)
                        Text("Buat rencana perjalanan mandiri Anda lebih bermakna dengan mendukung roda ekonomi lokal.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                    .padding()
                }
                .frame(height: 100)
                
                // --- 4. SECTION MY TRIPS ---
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Rencana Perjalanan")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.themeDarkText)
                        Spacer()
                        Button("Lihat Semua") { }
                        .font(.caption)
                        .bold()
                        .foregroundColor(.themeGold)
                    }
                    
                    ForEach(sampleTrips) { trip in
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.themeTurquoiseLight)
                                    .frame(width: 65, height: 65)
                                Image(systemName: trip.imageSystemName)
                                    .foregroundColor(.themeTeal)
                                    .font(.title3)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(trip.destination)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.themeDarkText)
                                    .lineLimit(1)
                                
                                Text(trip.dateRange)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(trip.tag)
                                    .font(.system(size: 10, weight: .medium))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.themeGold.opacity(0.2))
                                    .foregroundColor(.themeGold)
                                    .clipShape(Capsule())
                                    .padding(.top, 2)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.themeTeal)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                    }
                }
                
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        TripDashboardView()
            .navigationTitle("LocaRuta")
            .navigationBarTitleDisplayMode(.inline)
    }
}
