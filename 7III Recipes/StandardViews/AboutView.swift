//
//  AboutView.swift
//  7III Recipes
//
//  Created by Simon Lang on 05.12.23.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Text("""
                7III Recipes is a cookbook app that utilizes markdown files in the background to save and retrieve recipes. This ensures that you never lose your recipes and always maintain complete control over them.
                
                If you have any questions, bugs to report, or if you want to see a feature, send us an [email](0@project7iii.com).
                
                We make useful things, find us at [project7iii.com](https://project7iii.com)
                
                **Licenses**
                This app uses some parts of [ConfettiSwiftUI](https://github.com/simibac/ConfettiSwiftUI):
                ConfettiSwiftUI is Copyright (c) 2020 Simon Bachmann.

                Permission is hereby granted, free of charge, to any person obtaining a copy
                of ConfettiSwiftUI and associated documentation files (the "Software"), to deal
                in the Software without restriction, including without limitation the rights
                to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                copies of the Software, and to permit persons to whom the Software is
                furnished to do so, subject to the following conditions:

                The above copyright notice and this permission notice shall be included in all
                copies or substantial portions of the Software.

                THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                SOFTWARE.
                
                ---
                
                This app also uses [ZIP Foundation](https://github.com/weichsel/ZIPFoundation) to zip and unzip files:
                ZIP Foundation is Copyright (c) 2017-2024 Thomas Zoechling (https://www.peakstep.com)

                Permission is hereby granted, free of charge, to any person obtaining a copy
                of this software and associated documentation files (the "Software"), to deal
                in the Software without restriction, including without limitation the rights
                to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                copies of the Software, and to permit persons to whom the Software is
                furnished to do so, subject to the following conditions:

                The above copyright notice and this permission notice shall be included in all
                copies or substantial portions of the Software.

                THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                SOFTWARE.
                """)
        }
        
        .background {
            BackgroundAnimation(backgroundColor: Color(.gray).opacity(0.1), foregroundColor: .blue)
        }
        .navigationTitle("About")
        
        
    }
}

#Preview {
    AboutView()
}
