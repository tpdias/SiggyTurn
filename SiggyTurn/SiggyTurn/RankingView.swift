//
//  RankingView.swift
//  SiggyTurn
//
//  Created by Thiago Parisotto on 23/08/23.
//

import SwiftUI

struct RankingView: View {
    @EnvironmentObject var cloud: CKCrudService
    var body: some View {
        List(cloud.users.prefix(3), id: \.username) { user in
                        VStack(alignment: .leading) {
                            Text(user.username)
                                .font(.headline)
                            Text("Points: \(user.turns)")
                                .foregroundColor(.gray)
                        }
                    }
    }
}
