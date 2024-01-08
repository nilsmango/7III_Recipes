//
//  AboutView.swift
//  7III Recipes
//
//  Created by Simon Lang on 05.12.23.
//

import SwiftUI

struct PrivacyView: View {
    var body: some View {
        List {
            Text("""
                This privacy notice outlines the data practices of the 7III Recipes app. We are committed to ensuring the privacy and security of your personal information. Please read this notice carefully to understand how we handle your data.

                Data Collection and Usage:
                We want to make it clear that we do not collect, view, save, or sell any user data through the 7III Recipes app. Your recipes and any related information are stored exclusively on your device, ensuring that you have complete control over your data.

                Third-Party Services:
                The 7III Recipes app does not integrate with any third-party services that could compromise your data privacy. We do not engage in any data-sharing practices with external entities.

                Contact Information:
                If you have any questions or concerns regarding the privacy practices of the 7III Recipes app, please contact us at [recipes@project7iii.com](recipes@project7iii.com).

                By using the 7III Recipes app, you acknowledge and agree to the terms outlined in this privacy notice. We reserve the right to update this notice to reflect any changes in our data practices. Please check back periodically for the latest information.

                Thank you for choosing 7III Recipes.
                """)
        }
        
        .background {
            BackgroundAnimation(backgroundColor: Color(.gray).opacity(0.1), foregroundColor: .blue)
        }
        .navigationTitle("Privacy Notice")
        
        
    }
}

#Preview {
    PrivacyView()
}
