//
//  ProfileView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//

import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    let userEmail: String
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var router: Router

    @State private var isLoading = false
    @State private var createdEvents: [CreateEventModel] = []
    @State private var joinedEvents: [CreateEventModel] = []
    @State private var showEditProfile = false
    @State private var showCreatedAll = false
    @State private var showJoinedAll = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection

                        createdSection

                        joinedSection

                        signOutSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Profilim")
            .navigationBarTitleDisplayMode(.inline)
            .task { await loadData() }
            .sheet(isPresented: $showEditProfile) {
                CompleteProfileView()
            }
            .sheet(isPresented: $showCreatedAll) {
                MyEventsListView(title: "Oluşturduğum Etkinlikler", events: createdEvents)
            }
            .sheet(isPresented: $showJoinedAll) {
                MyEventsListView(title: "Katıldığım Etkinlikler", events: joinedEvents)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                avatarView

                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(sessionManager.user?.email ?? userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    showEditProfile = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(Circle().fill(Color.blue.opacity(0.1)))
                }
                .accessibilityLabel("Profili Düzenle")
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }

    private var createdSection: some View {
        FormSectionCard(title: "Oluşturduğum Etkinlikler", icon: "calendar.badge.plus") {
            sectionHeader(action: { showCreatedAll = true }, count: createdEvents.count)

            if isLoading {
                ProgressView().frame(maxWidth: .infinity)
            } else if createdEvents.isEmpty {
                emptyRow(text: "Henüz etkinlik oluşturmamışsınız.")
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(createdEvents.prefix(3))) { event in
                        CompactCardView(event: event)
                    }
                }
            }
        }
    }

    private var joinedSection: some View {
        FormSectionCard(title: "Katıldığım Etkinlikler", icon: "person.3") {
            sectionHeader(action: { showJoinedAll = true }, count: joinedEvents.count)

            if isLoading {
                ProgressView().frame(maxWidth: .infinity)
            } else if joinedEvents.isEmpty {
                emptyRow(text: "Henüz bir etkinliğe katılmadınız.")
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(joinedEvents.prefix(3))) { event in
                        CompactCardView(event: event)
                    }
                }
            }
        }
    }

    private var signOutSection: some View {
        Button {
            sessionManager.signOut()
        } label: {
            HStack {
                Text("Çıkış Yap")
                    .fontWeight(.semibold)
            }
            .padding(5)
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
    }

    private func sectionHeader(action: @escaping () -> Void, count: Int) -> some View {
        HStack {
            Text("Toplam: \(count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Button(action: action) {
                HStack(spacing: 6) {
                    Text("Tümünü Göster")
                    Image(systemName: "chevron.right")
                }
            }
            .buttonStyle(.borderless)
            .foregroundColor(.blue)
        }
    }

    private func emptyRow(text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .foregroundColor(.secondary)
            Text(text)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 64, height: 64)
            Text(initials)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
    }

    private var displayName: String {
        let first = sessionManager.userProfile?.firstName ?? ""
        let last = sessionManager.userProfile?.lastName ?? ""
        let name = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        return name.isEmpty ? "Kullanıcı" : name
    }

    private var initials: String {
        let first = sessionManager.userProfile?.firstName?.first.map { String($0) } ?? ""
        let last = sessionManager.userProfile?.lastName?.first.map { String($0) } ?? ""
        let combined = (first + last)
        return combined.isEmpty ? "👤" : combined.uppercased()
    }

    private func loadData() async {
        guard let uid = sessionManager.user?.uid else { return }
        isLoading = true
        async let createdTask = EventService.shared.fetchEventsCreatedBy(userId: uid)
        async let joinedTask = EventService.shared.fetchJoinedEvents(for: uid)
        do {
            let (c, j) = try await (createdTask, joinedTask)
            createdEvents = c
            joinedEvents = j
        } catch {
            // For simplicity, ignore per-field errors; could add toast later
            Logger.error("Profile load error: \(error.localizedDescription)", category: .profile)
        }
        isLoading = false
    }
}

struct MyEventsListView: View {
    let title: String
    let events: [CreateEventModel]
    @EnvironmentObject private var router: Router

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if events.isEmpty {
                        Text("Gösterilecek etkinlik yok")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(events) { event in
                            CompactCardView(event: event)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProfileView(userEmail: "test@example.com")
        .environmentObject(SessionManager())
        .environmentObject(Router())
}
