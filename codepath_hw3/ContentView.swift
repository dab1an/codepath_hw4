import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var game = MemoryGame()
    @State private var showingSizeSheet = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {

                HStack(spacing: 15) {
                    Button(action: {
                        showingSizeSheet = true
                    }) {
                        Text("Choose Size")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(30)
                    }
                    
                    Button(action: {
                        game.resetGame()
                    }) {
                        Text("Reset Game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(30)
                    }
                }
                .padding()
                
                ScrollView {
                    LazyVGrid(columns: game.gridColumns, spacing: 12) {
                        ForEach(game.cards) { card in
                            CardView(card: card) {
                                game.choose(card)
                            }
                            .aspectRatio(3/4, contentMode: .fit)
                        }
                    }
                    .padding()
                    
                    if game.isGameWon {
                        VStack(spacing: 10) {
                            Text("🎉 You Won! 🎉")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Button("Play Again") {
                                game.resetGame()
                            }
                            .font(.headline)
                            .foregroundColor(.purple)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showingSizeSheet) {
            SizeSelectionView(game: game, isPresented: $showingSizeSheet)
        }
    }
}

struct CardView: View {
    let card: Card
    let action: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {

                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue)
                    .shadow(radius: 5)
                    .opacity(card.isMatched ? 0 : 1)
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(radius: 5)
                    .overlay(
                        Text(card.content)
                            .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.5))
                    )
                    .opacity(card.isFaceUp ? 1 : 0)
                    .opacity(card.isMatched ? 0 : 1)
                    .rotation3DEffect(
                        .degrees(card.isFaceUp ? 0 : 180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
            .rotation3DEffect(
                .degrees(card.isFaceUp ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.5)) {
                    action()
                }
            }
        }
    }
}

struct SizeSelectionView: View {
    @ObservedObject var game: MemoryGame
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Grid Size")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            ForEach([2, 4, 6], id: \.self) { size in
                Button(action: {
                    game.setGridSize(size)
                    isPresented = false
                }) {
                    Text("\(size)×\(size) Grid (\(size * size) cards)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(game.gridSize == size ? Color.purple : Color.gray)
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal)
            
            Button("Cancel") {
                isPresented = false
            }
            .padding()
        }
        .padding()
    }
}

struct Card: Identifiable {
    let id = UUID()
    let content: String
    var isFaceUp = false
    var isMatched = false
}

class MemoryGame: ObservableObject {
    @Published var cards: [Card] = []
    @Published var gridSize = 4
    
    private var flippedCards: [Card] = []
    private let emojis = ["🌍", "🎨", "🎮", "🎵", "⭐️", "🍕", "🚀", "🎭", "🎪", "🎯", "🎲", "🎸"]
    
    var gridColumns: [GridItem] {
        let columnCount = gridSize == 2 ? 2 : (gridSize == 4 ? 3 : 4)
        return Array(repeating: GridItem(.flexible(), spacing: 12), count: columnCount)
    }
    
    var isGameWon: Bool {
        !cards.isEmpty && cards.allSatisfy { $0.isMatched }
    }
    
    init() {
        resetGame()
    }
    
    func setGridSize(_ size: Int) {
        gridSize = size
        resetGame()
    }
    
    func resetGame() {
        let numberOfPairs = (gridSize * gridSize) / 2
        let selectedEmojis = Array(emojis.prefix(numberOfPairs))
        let cardContents = (selectedEmojis + selectedEmojis).shuffled()
        
        cards = cardContents.map { Card(content: $0) }
        flippedCards = []
    }
    
    func choose(_ card: Card) {
        guard let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
              !cards[chosenIndex].isFaceUp,
              !cards[chosenIndex].isMatched,
              flippedCards.count < 2 else {
            return
        }
        
        cards[chosenIndex].isFaceUp = true
        flippedCards.append(cards[chosenIndex])
        
        if flippedCards.count == 2 {
            checkForMatch()
        }
    }
    
    private func checkForMatch() {
        let firstCard = flippedCards[0]
        let secondCard = flippedCards[1]
        
        if firstCard.content == secondCard.content {

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if let firstIndex = self.cards.firstIndex(where: { $0.id == firstCard.id }),
                   let secondIndex = self.cards.firstIndex(where: { $0.id == secondCard.id }) {
                    withAnimation {
                        self.cards[firstIndex].isMatched = true
                        self.cards[secondIndex].isMatched = true
                    }
                }
                self.flippedCards = []
            }
        } else {

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let firstIndex = self.cards.firstIndex(where: { $0.id == firstCard.id }),
                   let secondIndex = self.cards.firstIndex(where: { $0.id == secondCard.id }) {
                    withAnimation {
                        self.cards[firstIndex].isFaceUp = false
                        self.cards[secondIndex].isFaceUp = false
                    }
                }
                self.flippedCards = []
            }
        }
    }
}


@main
struct MemoryGameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
