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
    @State private var searchText = ""
    
    // Creates a group of key-value pairs that take a key (cuisine) and a value (array of recipes)
    var cuisines: [String : [Recipe]] {
        // Sorts the recipes and cuisines alphabetically
        Dictionary(uniqueKeysWithValues: Dictionary(grouping: recipes, by: { $0.cuisine })
            .sorted { $0.key < $1.key })
    }
    
    var filteredRecipes: [Recipe] {
        guard !searchText.isEmpty else {
            return recipes
        }
        
        return recipes.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    // Alert properties
    @State private var isShowingAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    
    @MainActor
    var body: some View {
        NavigationStack {
            
            // The URL returns empty data
            if recipes.isEmpty {
                NoRecipesView()
                    .navigationTitle("Recipes")
                
                Button {
                    Task {
                        await refreshRecipes()
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding()
            }
            
            // URL returns data, or file has data
            else {
                List {
                    // Catagorized by cuisine type and contains the filtered recipes for searching
                    ForEach(Dictionary(grouping: filteredRecipes, by: { $0.cuisine })
                        .sorted {$0.key < $1.key}, id: \.key) { cuisine, recipes in
                        // Cuisine Header in alphabetical order
                        Section(header: Text(cuisine).textCase(.none).font(.headline)) {
                            // Recipe List
                            ForEach(recipes) { recipe in
                                RecipeCellView(recipe: recipe)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search for a recipe")
                .overlay {
                    if filteredRecipes.isEmpty {
                        ContentUnavailableView.search
                    }
                }
                .navigationTitle("Recipes")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                await refreshRecipes()
                            }
                        } label: {
                            Label(title: { Text("Refresh") }, icon: { Image(systemName: "arrow.clockwise") })
                                .labelsHidden()
                        }
                    }
                }
            }
        }
        .tint(.orange)
        
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        
        // Refreshes the recipe list with new data
        .refreshable {
            await refreshRecipes()
        }
        
        // Gets data from file every time the view appears
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
            alertTitle = "Failed to Load Data"
            alertMessage = "Failed to load recipe data locally from file. Please refresh to get data from API."
            isShowingAlert = true
        }
    }
    
    // Function to refresh recipes from file or API
    private func refreshRecipes() async {
        do {
            recipes = try await recipeManager.getRecipes()
            if recipes.isEmpty {
                alertTitle = "No Data Retrieved"
                alertMessage = "No data was returned from the URL. Either data is not available or the URL is incorrect."
                isShowingAlert = true
            }
        }
        catch RecipeManagerNetworkError.invalidData {
            alertTitle = "Invalid Data"
            alertMessage = "Invalid data received from the server. Please check the URL and try again."
            isShowingAlert = true
        }
        catch {
            alertTitle = "Unknown Error"
            alertMessage = "An unknown error has occurred while refreshing the recipes."
            isShowingAlert = true
        }
    }
}


struct RecipeCellView: View {
    let recipe: Recipe
    var body: some View {
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


#Preview {
    HomeView()
}
