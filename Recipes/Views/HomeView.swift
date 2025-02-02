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
    
    
    @MainActor
    var body: some View {
        NavigationStack {
            List {
                // Catagorized by cuisine type
                ForEach(cuisines.keys.sorted(), id: \.self) { cuisine in
                    // Cuisine Header in alphabetical order
                    Section(header: Text(cuisine).textCase(.none).font(.headline)) {
                        // Recipe List
                        ForEach(cuisines[cuisine] ?? []) { recipe in
                            HStack {
                                // Image
                                AsyncCachedImage(url: recipe.photoUrlSmall) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                    
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 70, height: 70)
                                }
                                
                                // Recipe Name
                                VStack (alignment: .leading) {
                                    Text(recipe.name)
                                        .font(.headline)
                                    
                                    // View Recipe via YouTube link
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
        
            // Gets data from file every time the view appears
            .onAppear {
                Task {
                    do {
                        await loadRecipesFromFile()
            }
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
