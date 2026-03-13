import SwiftUI

struct WordleView: View {
    let answer = "SWIFT"
    @State private var guesses: [[String]] = Array(repeating: Array(repeating: "", count: 5), count: 6)
    @State private var rowStates: [[LetterState]] = Array(repeating: Array(repeating: .empty, count: 5), count: 6)
    @State private var currentRow = 0
    @State private var currentCol = 0
    @State private var gameOver = false
    @State private var showingResult = false
    @State private var resultMessage = ""
    
    let keyboard = [
        ["Q","W","E","R","T","Y","U","I","O","P"],
        ["A","S","D","F","G","H","J","K","L"],
        ["ENTER","Z","X","C","V","B","N","M","⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Title
            Text("Wordle")
                .font(.system(size: 24, weight: .bold))
                .padding(.top)
            
            Divider()
            
            // Grid
            VStack(spacing: 6) {
                ForEach(0..<6, id: \.self) { row in
                    HStack(spacing: 6) {
                        ForEach(0..<5, id: \.self) { col in
                            LetterCell(letter: guesses[row][col], state: rowStates[row][col])
                        }
                    }
                }
            }
            
            Spacer()
            
            // Keyboard
            VStack(spacing: 8) {
                ForEach(keyboard, id: \.self) { row in
                    HStack(spacing: 5) {
                        ForEach(row, id: \.self) { key in
                            KeyButton(key: key) {
                                handleKey(key)
                            }
                        }
                    }
                }
            }
            .padding(.bottom)
        }
        .alert(resultMessage, isPresented: $showingResult) {
            Button("Play Again") {
                resetGame()
            }
        }
    }
    
    func resetGame() {
        guesses = Array(repeating: Array(repeating: "", count: 5), count: 6)
        rowStates = Array(repeating: Array(repeating: .empty, count: 5), count: 6)
        currentRow = 0
        currentCol = 0
        gameOver = false
    }
    
    func handleKey(_ key: String) {
        if key == "⌫" {
            deleteLetter()
        } else if key == "ENTER" {
            submitGuess()
        } else {
            addLetter(key)
        }
    }
    
    func addLetter(_ letter: String) {
        guard currentCol < 5, currentRow < 6 else { return }
        guesses[currentRow][currentCol] = letter
        currentCol += 1
    }
    
    func deleteLetter() {
        guard currentCol > 0 else { return }
        currentCol -= 1
        guesses[currentRow][currentCol] = ""
    }
    
    func submitGuess() {
        guard currentCol == 5 else { return }
        let guess = guesses[currentRow]
        let answerLetters = Array(answer)
        let guessLetters = guess.map { $0 }
        
        //Work out state of each cell
        var newStates: [LetterState] = Array(repeating: .absent, count: 5)
        var remainingAnswer = answerLetters.map { String($0) }
        
        //First pass - correct letters = green
        for i in 0..<5 {
            if guessLetters[i] == String(answerLetters[i]) {
                newStates[i] = .correct
                remainingAnswer[i] = ""
            }
        }
        //Second pass - Present letters = yellow
        for i in 0..<5 {
            if newStates[i] == .correct { continue }
            if let index =  remainingAnswer.firstIndex(of: guessLetters[i]) {
                newStates[i] = .present
                remainingAnswer[index] = ""
            }
        }
        //Save and move to next row
        rowStates[currentRow] = newStates
        
        //Check for win
        if newStates.allSatisfy({ $0 == .correct}) {
            gameOver = true
            showingResult = true
            resultMessage = "Well Done! 🎉"
        } else if currentRow == 5 {
            gameOver = true
            showingResult = true
            resultMessage = "The Wordle was \(answer)"
        }
        currentRow += 1
        currentCol = 0
    }
}

// MARK: - Letter Cell
enum LetterState {
    case empty, filled, correct, present, absent
}

struct LetterCell: View {
    let letter: String
    let state: LetterState
    
    var backgroundColor: Color {
        switch state {
        case .empty: return .clear
        case .filled: return .clear
        case .correct: return .green
        case .present: return .yellow
        case .absent: return Color(.systemGray)
        }
    }
    
    var borderColor: Color {
        switch state {
        case .empty: return Color(.systemGray4)
        case .filled: return Color(.systemGray2)
        default: return .clear
        }
    }
    
    var body: some View {
        Text(letter)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(state == .empty || state == .filled ? Color.primary : Color.white)
            .frame(width: 56, height: 56)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(borderColor, lineWidth: 2)
            )
    }
}

// MARK: - Key Button
struct KeyButton: View {
    let key: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(key)
                .font(.system(size: key.count > 1 ? 12 : 16, weight: .semibold))
                .frame(width: key.count > 1 ? 48 : 32, height: 44)
                .background(Color(.systemGray4))
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

#Preview {
    WordleView()
}
