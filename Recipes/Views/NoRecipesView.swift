//
//  NoRecipesView.swift
//  Recipes
//
//  Created by Dillon Teakell on 2/3/25.
//

import SwiftUI

struct NoRecipesView: View {
    var body: some View {
        VStack {
            Image(systemName: "carrot.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            Text("No Recipes Found")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Press 'Refresh' to try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NoRecipesView()
}
