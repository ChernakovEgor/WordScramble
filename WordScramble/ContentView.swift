//
//  ContentView.swift
//  WordScramble
//
//  Created by Egor Chernakov on 22.02.2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var alertTitle = ""
    @State private var alertMessege = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter new word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text("\($0)")
                }
                
                Text("Your score: \(score)")
                    .font(.title)
                    .padding(.bottom, 10)
            }
            .navigationBarTitle("\(rootWord)")
            .navigationBarItems(leading: Button("New Game") {
                startGame()
            })
        }
        .onAppear(perform: startGame)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessege), dismissButton: .default(Text("OK!")))
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            alertMessege(title: "Word was already entered", messege: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            alertMessege(title: "Think carefully", messege: "Word is impossible to form with given letters.")
            return
        }
        
        guard isReal(word: answer) else {
            alertMessege(title: "No cheating", messege: "Word does not exist.")
            return
        }
        
        guard isLong(word: answer) else {
            alertMessege(title: "Word too short", messege: "Think harder.")
            return
        }
        
        score += countScore(for: answer)
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func isOriginal(word: String) -> Bool {
        guard word != rootWord else { return false }
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var copy = rootWord
        for letter in word {
            if let position = copy.firstIndex(of: letter) {
                copy.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isLong(word: String) -> Bool {
        return word.count >= 3
    }
    
    func countScore(for word: String) -> Int {
        return word.count
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let words = startWords.components(separatedBy: "\n")
                rootWord = words.randomElement() ?? "silkworm"
                usedWords.removeAll()
                score = 0
                return
            }
        }
        fatalError("Could load start.txt from bundle.")
    }
    
    func alertMessege(title: String, messege: String) {
        alertTitle = title
        alertMessege = messege
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
