import SwiftUI
import PencilKit

struct CrimeSketchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var drawingData: Data?
    @State private var showingOptions = false
    @State private var sketchTitle = "Crime Scene Sketch"
    @State private var sketchDescription = ""
    @Binding var savedSketch: UIImage?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark gradient background to match theme
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "141E30"),
                        Color(hex: "243B55")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Custom header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CRIME SCENE")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(Color(hex: "64B5F6"))
                                .kerning(2)
                            
                            Text("Sketch Evidence")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingOptions = true
                        }) {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color(hex: "1A2133"))
                    
                    // Canvas view
                    CanvasView(canvasView: $canvasView, toolPicker: $toolPicker, drawingData: $drawingData)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding()
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    
                    // Instruction text
                    Text("Use Apple Pencil or your finger to sketch the crime scene")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom)
                    
                    // Controls
                    HStack(spacing: 20) {
                        Button(action: {
                            // Clear the canvas
                            canvasView.drawing = PKDrawing()
                        }) {
                            Label("Clear", systemImage: "trash")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(hex: "1A2133"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            // Save the sketch
                            saveSketch()
                        }) {
                            Label("Save Sketch", systemImage: "square.and.arrow.down")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(hex: "64B5F6"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingOptions) {
                SketchOptionsView(title: $sketchTitle, description: $sketchDescription)
            }
            .onAppear {
                setupToolPicker()
            }
        }
    }
    
    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
    
    private func saveSketch() {
        // Convert canvas to UIImage
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
        
        // Save the image to binding
        savedSketch = image
        
        // You could also save metadata about the sketch to Firestore here
        
        // Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }
}

// Canvas view that wraps PKCanvasView
struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    @Binding var drawingData: Data?
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .white
        canvasView.isOpaque = false
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 10)
        
        // If we have saved data, restore it
        if let data = drawingData {
            if let drawing = try? PKDrawing(data: data) {
                canvasView.drawing = drawing
            }
        }
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Store the current drawing as data
        drawingData = uiView.drawing.dataRepresentation()
    }
}

// View for sketch options
struct SketchOptionsView: View {
    @Binding var title: String
    @Binding var description: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Sketch Details")) {
                        TextField("Title", text: $title)
                        TextField("Description", text: $description)
                    }
                }
            }
            .navigationTitle("Sketch Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
