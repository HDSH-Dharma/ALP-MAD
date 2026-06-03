//
//  TripDashboardView.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import SwiftUI

// MARK: - THEME COLOR PALETTE (Rose Gold)
fileprivate extension Color {
    static let roseGoldMain = Color(red: 0.89, green: 0.61, blue: 0.63)
    static let roseGoldDarkText = Color(red: 0.48, green: 0.27, blue: 0.30)
    static let roseGoldLightBg = Color(red: 0.98, green: 0.94, blue: 0.94)
    static let roseGoldCard = Color(red: 0.95, green: 0.87, blue: 0.88)
}

// MARK: - DUMMY DATA MODEL FOR UI
struct DummyTrip: Identifiable {
    let id = UUID()
    let destination: String
    let dateRange: String
    let imageSystemName: String
    let tag: String
}

struct DashboardView: View {
    // Data dummy untuk visualisasi list "My Trips"
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
                        Text("User")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.roseGoldDarkText)
                    }
                    
                    Spacer()
                    
                    // Profile Avatar matching Figma
                    ZStack {
                        Circle()
                            .fill(Color.roseGoldMain)
                            .frame(width: 50, height: 50)
                        Text("DT")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color.roseGoldMain.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 16)
                
                // --- 2. STATS CARD (Places Visited & Local UMKM) ---
                VStack(spacing: 16) {
                    HStack {
                        Text("Kontribusi Liburan Anda")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.roseGoldDarkText.opacity(0.8))
                            .textCase(.uppercase)
                        Spacer()
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    HStack(spacing: 0) {
                        // Stats 1
                        VStack(alignment: .center, spacing: 6) {
                            Text("12")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.roseGoldDarkText)
                            Text("Tempat Dikunjungi")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Divider
                        Rectangle()
                            .fill(Color.roseGoldDarkText.opacity(0.2))
                            .frame(width: 1, height: 45)
                        
                        // Stats 2 (SDG 8 Focus)
                        VStack(alignment: .center, spacing: 6) {
                            Text("28")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
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
                        .fill(Color.roseGoldLightBg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.roseGoldCard, lineWidth: 1)
                )
                
                // --- 3. PROMOTIONAL BANNER / SLOGAN ---
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            colors: [Color.roseGoldMain, Color.roseGoldMain.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ayo Jelajahi Nusantara")
                            .font(.headline)
                            .foregroundColor(.white)
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
                            .foregroundColor(.roseGoldDarkText)
                        Spacer()
                        Button("Lihat Semua") {
                            // Action
                        }
                        .font(.caption)
                        .bold()
                        .foregroundColor(.roseGoldMain)
                    }
                    
                    // List Card Perjalanan
                    ForEach(sampleTrips) { trip in
                        HStack(spacing: 16) {
                            // Icon Box Placeholder pengganti gambar
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.roseGoldCard)
                                    .frame(width: 65, height: 65)
                                Image(systemName: trip.imageSystemName)
                                    .foregroundColor(.roseGoldDarkText)
                                    .font(.title3)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(trip.destination)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Text(trip.dateRange)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // Tag SDG lokal ekonomi
                                Text(trip.tag)
                                    .font(.system(size: 10, weight: .medium))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                                    .clipShape(Capsule())
                                    .padding(.top, 2)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
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

// MARK: - PREVIEW AREA
#Preview {
    NavigationStack {
        DashboardView()
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
    }
}
