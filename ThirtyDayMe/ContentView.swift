import SwiftData
import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService(baseURL: "https://30day.me")

    var body: some View {
//        HomeView()
        Group {
             if authService.isAuthenticated {
                 Text("your email is: \(authService.user?.email ?? "Unknown")")
                 Button(action: {
                     Task {
                         await authService.signOut()
                     }
                 }) {
                     Text("Sign Out")
                 }
             } else {
                 SignIn()
             }
         }
            .environmentObject(authService)
    }
}
	
#Preview {
    ContentView()
        .modelContainer(ThirtyDayMeApp.sharedModelContainer)
}
