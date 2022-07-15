//
//  AboutView.swift
//  hackertracker
//
//  Created by Seth W Law on 7/15/22.
//  Copyright © 2022 Beezle Labs. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    @State var rick: Int = 0
    var body: some View {
        VStack(spacing: 3) {
            HStack {
                Button(action: {
                    if let url = URL(string: "https://twitter.com/sethlaw") {
                           UIApplication.shared.open(url)
                        }
                }, label: {
                    Text("@sethlaw").font(.body).foregroundColor(ThemeColors.blue)

                })
                
                Text(" | ").font(.body).foregroundColor(.gray)
                Button(action: {
                    if let url = URL(string: "https://github.com/cak") {
                           UIApplication.shared.open(url)
                        }
                }, label: {
                    Text("@cak").font(.body).foregroundColor(ThemeColors.blue)

                })
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
            //.padding(EdgeInsets(top: 0, leading: 0, bottom: 3, trailing: 0))
            if let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Text("#hackertracker iOS v\(v)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        tapped()
                    }


            } else {
                Text("#hackertracker iOS")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        tapped()
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color.white)
            .background(ThemeColors.gray)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))

    }
    
    func tapped() {
        rick += 1
        if rick >= 6 {
            print("roll")
            rick = 0
            if let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ?autoplay=1") {
                   UIApplication.shared.open(url)
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
