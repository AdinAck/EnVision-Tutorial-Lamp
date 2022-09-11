//
//  InfoRowView.swift
//  Lamp (iOS)
//
//  Created by Adin Ackerman on 9/8/22.
//

import SwiftUI

struct InfoRowView: View {
    let name: String
    let value: String
    let doTextField: Bool
    
    init(name: String, value: String) {
        self.name = name
        self.value = value
        self.doTextField = false
    }
    
    init(name: String, value: String, doTextField: Bool) {
        self.name = name
        self.value = value
        self.doTextField = doTextField
    }
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            if doTextField {
                TextField(name, text: Binding(get: { value }, set: { _,_ in }))
                    .textFieldStyle(.roundedBorder)
            } else {
                Text(value)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct InfoRowView_Previews: PreviewProvider {
    static var previews: some View {
        InfoRowView(name: "Test", value: "\(3)")
    }
}
