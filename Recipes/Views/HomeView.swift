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
                ForEach(cuisines.keys.sorted(), id: \.self) { cuisine in
                    Section(header: Text(cuisine)) {
                        ForEach(cuisines[cuisine] ?? []) { recipe in
                            HStack {
                                AsyncImage(url: recipe.photoUrlSmall) { image in
                                    image.image?.resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                }
                                Text(recipe.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .task {
                do {
                    recipes = try await recipeManager.getRecipes()
                }
                catch RecipeManagerError.invalidURL {
                    isShowingAlert = true
                    alertTitle = "Invalid URL"
                    alertMessage = "Please check that the URL was entered correctly."
                }
                catch RecipeManagerError.invalidData {
                    isShowingAlert = true
                    alertTitle = "Invalid Data"
                    alertMessage = "The data returned is invalid. Please check that the URL is returning valid data."
                }
                catch RecipeManagerError.badRequest {
                    isShowingAlert = true
                    alertTitle = "Bad Request"
                    alertMessage = "The server returned a bad request. Please confirm the URL is correct."
                }
                catch RecipeManagerError.unauthorized {
                    isShowingAlert.toggle()
                    alertTitle = "Unauthorized"
                    alertMessage = "You are unauthorized to access this resource."
                }
                catch RecipeManagerError.forbidden {
                    isShowingAlert.toggle()
                    alertTitle = "Forbidden"
                    alertMessage = "You are forbidden to access this resource."
                }
                catch RecipeManagerError.notFound {
                    isShowingAlert.toggle()
                    alertTitle = "Server Not Found"
                    alertMessage = "The server could not be found. Please confirm the URL is correct."
                }
                catch RecipeManagerError.requestTimeout {
                    isShowingAlert.toggle()
                    alertTitle = "Request Timeout"
                    alertMessage = "The server timed out waiting for a response. Please check your internet connection, confirm the URL is correct, and try again."
                }
                catch RecipeManagerError.internalServerError {
                    isShowingAlert.toggle()
                    alertTitle = "Internal Server Error"
                    alertMessage = "The server encountered an internal error. Please try again later."
                }
                catch RecipeManagerError.badGateway {
                    isShowingAlert.toggle()
                    alertTitle = "Bad Gateway"
                    alertMessage = "The server received a bad gateway response. Please try again later."
                }
                catch RecipeManagerError.serviceUnavailable {
                    isShowingAlert.toggle()
                    alertTitle = "Service Unavailable"
                    alertMessage = "The server is currently unavailable. Please try again later."
                }
                catch {
                    isShowingAlert.toggle()
                    alertTitle = "Unknown Error"
                    alertMessage = "An unknown error has occured. Please try again later."
                }
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage))
            }
        }
        }
        
}

#Preview {
    HomeView()
}
