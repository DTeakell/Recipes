//
//  HomeView.swift
//  Recipes
//
//  Created by Dillon Teakell on 1/30/25.
//

import SwiftUI

struct HomeView: View {
    
    // Recipes and recipe manager
    @State var recipes: [Recipe] = []
    let recipeManager = RecipeManager()
    let imageManager = ImageManager()
    
    // Create a group of cuisine with the name of the cuisine and the recipes with the cuisine name
    var cuisines: [String : [Recipe]] {
        Dictionary(grouping: recipes, by: { $0.cuisine }).sorted { $0.key < $1.key }
            .reduce(into: [String: [Recipe]]()) { result, element in
                result[element.key] = element.value
            }
    }
    
    // Alert properties
    @State private var isShowingAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    @State private var isLoading: Bool = false
    
    @MainActor
    var body: some View {
        NavigationStack {
            List {
                ForEach(cuisines.keys.sorted(), id: \.self) { cuisine in
                    Section(header: Text(cuisine).textCase(.none).font(.headline)) {
                        ForEach(cuisines[cuisine] ?? []) { recipe in
                            HStack {
                                if let url = recipe.photoUrlSmall {
                                    if let cachedImage = imageManager.shared.loadImage(for: url) {
                                        Image(uiImage: cachedImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 70, height: 70)
                                            .clipShape(Circle())
                                    }
                                }
                                else {
                                    AsyncImage(url: recipe.photoUrlSmall) { phase in
                                        switch phase {
                                            // Getting image
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 70, height: 70)
                                            // Image retrieved
                                        case .success(let image):
                                            image.resizable()
                                                .scaledToFit()
                                                .frame(width: 70, height: 70)
                                                .clipShape(Circle())
                                            // Image failed
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                                VStack (alignment: .leading) {
                                    Text(recipe.name)
                                        .font(.headline)
                                    
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 15,height: 15)
                                        Link("View Recipe", destination: URL(string: "\(recipe.youtubeUrl ?? "")") ?? URL(filePath: "https://www.youtube.com/")!)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
        }
            // Refreshes the recipe list with new data
            .refreshable {
                await refreshRecipes()
            }
            // Fetches data every time the view appears
            .onAppear {
                Task {
                    await loadRecipesFromFile()
                }
            }
}
    
    // Function to load recipes from file
    private func loadRecipesFromFile() async {
        if let loadedRecipes = recipeManager.loadRecipesFromFile() {
            recipes = loadedRecipes
        } else {
            print("Failed to load recipes from file.")
        }
    }
    
    // Function to refresh recipes from file or API
    private func refreshRecipes() async {
        do {
            recipes = try await recipeManager.getRecipes()
        }
        catch {
            print("Error refreshing recipes: \(error.localizedDescription)")
        }
    }
}

#Preview {
    HomeView()
}
