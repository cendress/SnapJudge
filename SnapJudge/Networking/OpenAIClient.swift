//
//  OpenAIClient.swift
//  SnapJudge
//
//  Created by Christopher Endress on 12/4/25.
//

import Foundation
import UIKit

enum OpenAIClientError: LocalizedError {
    case missingAPIKey
    case invalidImage
    case invalidResponse
    case noOutputText
    case invalidJSON
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key is missing. Please add it to the networking file in Xcode."
        case .invalidImage:
            return "Could not convert image to JPEG data."
        case .invalidResponse:
            return "Received an invalid response from the AI."
        case .noOutputText:
            return "AI did not return any output text."
        case .invalidJSON:
            return "AI output was not valid JSON."
        }
    }
}

// Internal struct matching the JSON we ask the model to output
// Later converted into AnalysisResult model
private struct AIAnalysisPayload: Decodable {
    let ideaTitle: String
    let ideaSummary: String
    let feasibilityScore: Int
    let costEstimate: String
    let timeEstimate: String
    let complexityLevel: Int
    let decision: String
    let reasons: String
}

// Very small client to message the OpenAI Responses API with an image and instructions
final class OpenAIClient {
    static let shared = OpenAIClient()
    
    private let apiKey: String = Secrets.openAIKey
    
    private init() {}
    
    func analyzeIdea(from image: UIImage) async throws -> AnalysisResult {
        guard !apiKey.isEmpty, apiKey != Secrets.openAIKey else {
            throw OpenAIClientError.missingAPIKey
        }
        
        guard let jpegData = image.jpegData(compressionQuality: 0.7) else {
            throw OpenAIClientError.invalidImage
        }
        
        let base64 = jpegData.base64EncodedString()
        let dataURL = "data:image/jpeg;base64,\(base64)"
        
        // Prompt: tell the model to output STRICT JSON only
        let prompt = """
        You are an expert startup / product idea evaluator.
        
        You will be given an image that contains a startup idea, UI mockup, landing page, notes, or pitch.
        
        1. Infer the core idea and target user from the image.
        2. Evaluate it on feasibility, cost, time-to-build, and complexity.
        3. Output ONLY valid JSON (no markdown, no backticks, no comments) in this exact shape:
        
        {
          "ideaTitle": "short name of the idea",
          "ideaSummary": "1-3 sentence summary of the idea from the image",
          "feasibilityScore": 0-100,
          "costEstimate": "rough MVP cost like '$5k–$15k'",
          "timeEstimate": "rough MVP time like '4–8 weeks with 1 dev'",
          "complexityLevel": 1-5,
          "decision": "go" | "no-go" | "maybe",
          "reasons": "2-5 short bullet-style sentences explaining your reasoning"
        }
        
        Rules:
        - "decision" MUST be exactly one of: "go", "no-go", "maybe".
        - Respond with JSON only. No extra text.
        """
        
        let url = URL(string: "https://api.openai.com/v1/responses")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "model": "gpt-4.1-mini",
            "max_output_tokens": 500,
            "input": [[
                "role": "user",
                "content": [
                    [
                        "type": "input_text",
                        "text": prompt
                    ],
                    [
                        "type": "input_image",
                        "image_url": dataURL,
                        "detail": "low"
                    ]
                ]
            ]]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let bodyString = String(data: data, encoding: .utf8) ?? ""
            print("OpenAI error (\(http.statusCode)): \(bodyString)")
            throw OpenAIClientError.invalidResponse
        }
        
        let rawJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        var outputText: String? = rawJSON?["output_text"] as? String
        
        // Fallback: manually dig into output[0].content[0].text if needed.
        if outputText == nil,
           let outputArray = rawJSON?["output"] as? [[String: Any]],
           let firstOutput = outputArray.first,
           let contentArray = firstOutput["content"] as? [[String: Any]],
           let firstContent = contentArray.first,
           let text = firstContent["text"] as? String {
            outputText = text
        }
        
        guard var text = outputText, !text.isEmpty else {
            throw OpenAIClientError.noOutputText
        }
        
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("```") {
            if let firstBrace = text.firstIndex(of: "{"),
               let lastBrace = text.lastIndex(of: "}") {
                text = String(text[firstBrace...lastBrace])
            }
        }
        
        guard let jsonData = text.data(using: .utf8) else {
            throw OpenAIClientError.invalidJSON
        }
        
        let payloadDecoded = try JSONDecoder().decode(AIAnalysisPayload.self, from: jsonData)
        
        let decisionEnum: SnapDecision
        switch payloadDecoded.decision.lowercased() {
        case "go":
            decisionEnum = .go
        case "no-go", "nogo", "no_go":
            decisionEnum = .noGo
        default:
            decisionEnum = .maybe
        }
        
        return AnalysisResult(
            ideaTitle: payloadDecoded.ideaTitle,
            ideaSummary: payloadDecoded.ideaSummary,
            feasibilityScore: payloadDecoded.feasibilityScore,
            costEstimate: payloadDecoded.costEstimate,
            timeEstimate: payloadDecoded.timeEstimate,
            complexityLevel: payloadDecoded.complexityLevel,
            decision: decisionEnum,
            reasons: payloadDecoded.reasons
        )
    }
}
