//
//  ContentView.swift
//  KelimeBulmaca
//
//  Created by Alp Selvi on 23.09.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var kullanilmisKelimeler = [String]()
    @State private var kokKelime = ""
    @State private var yeniKelime = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    func yeniKelimeEkle() {
        let cevap = yeniKelime.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard cevap.count > 0 else { return }
        
        guard gercekMi(kelime: cevap) else {
            wordError(title: "Bu kelimeyi daha önceden yazdın.", message: "Biraz daha düşün!")
            return
        }
        
        guard mumkun(kelime: cevap) else {
            wordError(title: "Böyle bir kelime var , fakat bunu yazamazsın", message: "\(kokKelime) kelimesinden böyle bir kelime türetemezsin!")
            return
        }
        
        guard gercekMi(kelime: cevap) else {
            wordError(title: "Böyle bir kelime yok", message: "Kelimeleri uydurarak başaramazsın!")
            return
        }
        
        withAnimation {
            kullanilmisKelimeler.insert(cevap, at: 0)
        }
        
//        kullanilmisKelimeler.insert(cevap, at: 0)
        yeniKelime = ""
    }
    
    func oyunuBaslat() {
        if let baslamaKelimeleriURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let baslamaKelimeleri = try? String(contentsOf: baslamaKelimeleriURL) {
                let tumKelimeler = baslamaKelimeleri.components(separatedBy: "\n")
                kokKelime = tumKelimeler.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("start.txt dosyası yüklenemedi")
    }
    
    func orijinaldir(kelime: String) -> Bool {
        !kullanilmisKelimeler.contains(kelime)
    }
    
    func mumkun(kelime: String) -> Bool {
        var geciciKelime = kokKelime
        
        for harf in kelime {
            if let konum = geciciKelime.firstIndex(of: harf) {
                geciciKelime.remove(at: konum)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func gercekMi(kelime: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: kelime.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: kelime, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    var body: some View {
      
        NavigationView {
            
            
            List {
                Section {
                    TextField("Kelimenizi girin", text: $yeniKelime)
                        .textInputAutocapitalization(.none)
                }
                
                Section {
                    ForEach(kullanilmisKelimeler, id: \.self) { kelime in
                        HStack {
                            Image(systemName: "\(kelime.count).circle.fill")
                            Text(kelime)
                        }
                    }
                }
            }
            .navigationTitle(kokKelime)
            .onSubmit(yeniKelimeEkle)
            .onAppear(perform: oyunuBaslat)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar{
                Button("Yeni kelime", action: oyunuBaslat)
            }
            
            
            
            
        }
        
    }
}

#Preview {
    ContentView()
}


