//
//  ProfileView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//

import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @EnvironmentObject var router: Router

    init(userEmail: String, sessionManager: SessionManager) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(sessionManager: sessionManager))
    }

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
            .task { await viewModel.loadData() }
            .sheet(isPresented: $viewModel.showEditProfile) {
                CompleteProfileView()
            }
            .sheet(isPresented: $viewModel.showCreatedAll) {
                MyEventsListView(title: "Oluşturduğum Etkinlikler", events: viewModel.createdEvents)
            }
            .sheet(isPresented: $viewModel.showJoinedAll) {
                MyEventsListView(title: "Katıldığım Etkinlikler", events: viewModel.joinedEvents)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                avatarView

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(viewModel.userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    viewModel.showEditProfileSheet()
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
            sectionHeader(action: { viewModel.showCreatedEventsSheet() }, count: viewModel.createdEvents.count)

            if viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity)
            } else if viewModel.createdEvents.isEmpty {
                emptyRow(text: "Henüz etkinlik oluşturmamışsınız.")
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.createdEvents.prefix(3))) { event in
                        CompactCardView(event: event)
                    }
                }
            }
        }
    }

    private var joinedSection: some View {
        FormSectionCard(title: "Katıldığım Etkinlikler", icon: "person.3") {
            sectionHeader(action: { viewModel.showJoinedEventsSheet() }, count: viewModel.joinedEvents.count)

            if viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity)
            } else if viewModel.joinedEvents.isEmpty {
                emptyRow(text: "Henüz bir etkinliğe katılmadınız.")
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.joinedEvents.prefix(3))) { event in
                        CompactCardView(event: event)
                    }
                }
            }
        }
    }

    private var signOutSection: some View {
        Button {
            viewModel.signOut()
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
            Text(viewModel.initials)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
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
    ProfileView(userEmail: "test@example.com", sessionManager: SessionManager())
        .environmentObject(Router())
}
