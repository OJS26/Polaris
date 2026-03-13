import SwiftUI

struct WordleView: View {
    @State private var answer: String = ""
    @State private var guesses: [[String]] = Array(repeating: Array(repeating: "", count: 5), count: 6)
    @State private var rowStates: [[LetterState]] = Array(repeating: Array(repeating: .empty, count: 5), count: 6)
    @State private var currentRow = 0
    @State private var currentCol = 0
    @State private var gameOver = false
    @State private var showingResult = false
    @State private var resultMessage = ""
    @State private var keyStates: [String: LetterState] = [:]
    
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
                            KeyButton(key: key, state: keyStates[key] ?? .empty) {
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
        
        .onAppear {
            answer = WordleView.loadRandomWord()
        }
    }
    
    func handleKey(_ key: String) {
        guard !gameOver else { return }
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
        //keyboard colours
        for i in 0..<5 {
            let key = guessLetters[i]
            let newState = newStates[i]
            
            if let existing = keyStates[key] {
                //dont dowgrade colours
                if existing == .correct { continue }
                if existing == .present && newState == .absent { continue }
            }
            keyStates[key] = newState
        }
        
        currentRow += 1
        currentCol = 0
    }
    func resetGame() {
        answer = WordleView.loadRandomWord()
        guesses = Array(repeating: Array(repeating: "", count: 5), count: 6)
        rowStates = Array(repeating: Array(repeating: .empty, count: 5), count: 6)
        currentRow = 0
        currentCol = 0
        gameOver = false
        keyStates = [:]
    }
    
    static func loadRandomWord() -> String {
        let words = [
            "APPLE", "BRAVE", "CHAIR", "DANCE", "EAGLE",
            "FAULT", "GRACE", "HEART", "IMAGE", "JOKER",
            "KNIFE", "LEMON", "MANGO", "NIGHT", "OCEAN",
            "PIANO", "QUEEN", "RIVER", "STONE", "TIGER",
            "BLAST", "CLOUD", "DREAM", "FLAME", "GIANT",
            "HONEY", "LIGHT", "MUSIC", "NOBLE", "OLIVE",
            "PEARL", "QUICK", "RADAR", "SMOKE", "TRAIN",
            "BEACH", "CANDY", "DEPOT", "EMPTY", "GLOBE",
            "KARMA", "LUNAR", "MAPLE", "NERVE", "ORBIT",
            "RAVEN", "SOLAR", "TOXIC", "VENOM", "WITTY",
            "CRISP", "FLUTE", "GRAZE", "HASTE", "JOUST",
            "KNACK", "MIRTH", "OPTIC", "PRISM", "QUIRK",
            "RHYME", "SCALP", "THYME", "VIGIL", "WHIRL",
            "SWIFT", "POLAR", "NORTH", "STARS", "GAMES",
            "BRAIN", "PIXEL", "CLOCK", "BLEND", "CRIMP"
        ]
        return words.randomElement() ?? "SWIFT"
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
    let state: LetterState
    let action: () -> Void
    
    var backgrundColor: Color {
        switch state {
        case .correct: return .green
        case .present: return .yellow
        case .absent: return Color(.systemGray)
        default: return Color (.systemGray4)
        }
    }
    var body: some View {
        Button(action: action) {
            Text(key)
                .font(.system(size: key.count > 1 ? 12 : 16, weight: .semibold))
                .frame(width: key.count > 1 ? 48 : 32, height: 44)
                .background(backgrundColor)
                .foregroundStyle(state == .empty || state == .filled ? Color.primary : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

#Preview {
    NavigationStack {
        WordleView()
    }
}
