//
//  ContentView.swift
//  wordscramble
//
//  Created by pushkar mondal on 19/12/22.
//

import SwiftUI

struct ContentView: View {
    @State private var useword = [String]()
    @State private var rootword = ""
    @State private var newword = ""
   
    
    @State private var errortitle = ""
    @State private var errormassage = ""
    @State private var showingerror = false
    
    
    
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("ENTER YOUR WORD" ,text:$newword)
                        .autocapitalization(.none)
                }
                Section{
                    ForEach(useword, id: \.self){word in
                        HStack{
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootword)
            .onSubmit (addnewWord)
            .onAppear(perform: startgame)
            .alert(errortitle, isPresented: $showingerror){
                Button("OK",role: .cancel) { }
            }message: {
                Text(errormassage)
            }
        }
    }
    func addnewWord(){
        let answer = newword.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        
        guard isoriginal(word: answer) else{
            worderror(title: "WORD ALREADY USED", message: "ORIGINAL")
            return
        }
        
        guard ispossible(word: answer) else{
            worderror(title: "NOT POSSIBLE", message: "YOU CAN'T SPELL THIS WORD FROM \(rootword)")
            return
        }
        
        guard isreal(word: answer) else{
            worderror(title: "NOT RECOGNIZED", message: "YOU CAN'T")
            return
        }
        
        withAnimation{
            
            useword.insert(answer, at: 0)
        }
        newword = ""
    }
    func startgame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allwords = startWords.components(separatedBy: "\n")
                rootword = allwords.randomElement() ?? "silkworm"
                return
                
            }
        }
        fatalError("couls not load start.txt from file")
    }
    func isoriginal(word: String) -> Bool{
        !useword.contains(word)
    }
    func ispossible(word:String) -> Bool{
        var tempword = rootword
        for letter in word {
            if let pos = tempword.firstIndex(of: letter){
                tempword.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    func isreal(word:String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspell = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspell.location == NSNotFound
    }
    func worderror(title:String ,message:String){
        errortitle = title
        errormassage = message
        showingerror = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
