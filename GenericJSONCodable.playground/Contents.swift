import Foundation

let testString = """
    {
        "integration-type": "agentry",
        "integration-data-exchange": "import",
        "integration-metadata": {
            "agentry-object-uid-value": "AgentryObjectUid",
            "agentry-object": "WorkOrder",
            "agentry-object-uid-property": "WONum"
        },
        "integration-data-mapping": {
            "$meta": { "status": "" },
            "fields": {
                "form-header-1": {
                    "type": "group",
                    "fields": {
                        "location-state": {
                            "type": "string",
                            "integration-path": [
                                { "property-name": "FunctionalLocations" },
                                { "collection-index": 0 },
                                { "property-name": "ZRegion" }
                            ]
                        },
                        "WO-operation": {
                            "type": "string",
                            "integration-concatenation": [
                                {
                                    "integration-path": [
                                        { "property-name": "WONum" }
                                    ]
                                },
                                {
                                    "concatenation-string": "-"
                                },
                                {
                                    "integration-path": [
                                        { "property-name": "Operations" },
                                        { "collection-index": 0 },
                                        { "property-name": "OperationNum" }
                                    ]
                                }
                            ]
                        },
                        "WO-number": {
                            "type": "string",
                            "integration-path": [
                                { "agentry-value": "AgentryObjectUid" }
                            ]
                        },
                        "inspection-type": {
                            "type": "string",
                            "integration-path": [
                                { "property-name": "Operations" },
                                { "path-directive": "LAST" },
                                { "property-name": "Description" }
                            ]
                        }
                    }
                }
            }
        }
    }
"""

struct IntegrationMetadata : Codable {
    
    let agentryObject: String
    let agentryObjectUidValue: String
    let agentryObjectUidProperty: String
}

enum IntegrationType: String, Codable {
    case agentry
}

enum IntegrationDataExchange: String, Codable {
    case `import` // import is a reserved word in Swift
}

enum FieldType : String, Codable {
    case group
    case string
    // #andytodo: other types + tests
}

enum IntegrationPathDirective : String, Codable {
    case MAIN
    case PARENT
    case FIRST
    case LAST
}

struct IntegrationPathElement : Codable {
    
    let propertyName: String?
    let collectionIndex: Int?
    let agentryValue: String?
    let pathDirective: IntegrationPathDirective?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        propertyName = try? container.decodeIfPresent(String.self, forKey: .propertyName)
        collectionIndex = try? container.decodeIfPresent(Int.self, forKey: .collectionIndex)
        agentryValue = try? container.decodeIfPresent(String.self, forKey: .agentryValue)
        pathDirective = try? container.decodeIfPresent(IntegrationPathDirective.self, forKey: .pathDirective)
        
        guard propertyName != nil || collectionIndex != nil || agentryValue != nil || pathDirective != nil else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "At least one of the keys is required for the Integration Path Element")
            throw DecodingError.dataCorrupted(context)
        }
    }
}

typealias IntegrationPath = [IntegrationPathElement]

struct IntegrationConcatenationElement : Codable {
    
    let concatenationString: String?
    let integrationPath: IntegrationPath?
}

typealias IntegrationConcatenation = [IntegrationConcatenationElement]

struct Field : Codable {
    
    let type: FieldType
    
    let fields: [String: Field]? // if it's a "group"
    
    let integrationPath: IntegrationPath? // if there is an integration
    let integrationConcatenation: IntegrationConcatenation? // if there are multiple integrations
}

struct IntegrationDataMapping : Codable {
    let fields: [String: Field]
}

struct AgentryMapping : Codable {
    
    let integrationType: IntegrationType
    let integrationDataExchange: IntegrationDataExchange
    let integrationMetadata: IntegrationMetadata
    let integrationDataMapping: IntegrationDataMapping
}

enum AgentryDataMappingError: Error {
    case invalidMappingData
    case invalidMappingString
    case invalidMappingTarget
    
    case invalidIntegrationPathElement
    case invalidIntegrationConcatenationElement(fieldName: String)
}

func resolveIntegrationPath(integrationPath: IntegrationPath) -> String {
    return integrationPath.reduce("") { value, ipc in
        var newTerm = ""
        if let collIndex = ipc.collectionIndex {
            newTerm = "[\(collIndex)]"
        } else if let propName = ipc.propertyName {
            newTerm = propName
        } else if let agentryValue = ipc.agentryValue {
            newTerm = "getAgentryString(\(agentryValue))"
        } else if let pathDirective = ipc.pathDirective {
            newTerm = "<\(pathDirective.rawValue)>"
        }
        return value + newTerm + "."
    }
}

func resolveIntegrationConcatenation(integrationConcatenation: IntegrationConcatenation) throws -> String {
    return try integrationConcatenation.reduce("") { value, icc in
        var newTerm = ""
        if let concatenationString = icc.concatenationString {
            newTerm = concatenationString
        } else if let integrationPath = icc.integrationPath {
            newTerm = resolveIntegrationPath(integrationPath: integrationPath)
        } else {
            throw AgentryDataMappingError.invalidIntegrationConcatenationElement(fieldName: "field-name-here")
        }
        return value + newTerm
    }
}

func resolveFieldValues(fields: [String: Field]) throws -> [String: Any] {
    var fieldValues: [String: Any] = [:]
    for (fieldName, field) in fields {
        switch field.type {
        case .string:
            if let integrationPath = field.integrationPath {
                fieldValues[fieldName] = resolveIntegrationPath(integrationPath: integrationPath)
            } else if let integrationConcatenation = field.integrationConcatenation {
                fieldValues[fieldName] = try resolveIntegrationConcatenation(integrationConcatenation: integrationConcatenation)
            }
        case .group:
            if let groupFields = field.fields, groupFields.count > 0 {
                fieldValues[fieldName] = try resolveFieldValues(fields: groupFields)
            }
        }
    }
    return fieldValues
}

struct MappingCodingKeys : CodingKey {
    
    var stringValue: String
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        return nil
    }
}

func mappingKeys(_ keys : [CodingKey]) -> CodingKey {
    let lastKey = keys.last!
    if lastKey.intValue != nil {
        return lastKey // It's an array key, we don't need to change anything
    }
    let stringKey = lastKey.stringValue
    let keyParts = stringKey.split(separator: "-")
    let newKey = keyParts.reduce("") { currentValue, nextElement in
        // only capitalize after the first one
        let path = currentValue == "" ? String(nextElement) : nextElement.capitalized
        return currentValue + path
    }
    return MappingCodingKeys(stringValue: newKey)
}

func doIt() throws {
    
    guard let data = testString.data(using: .utf8) else {
        print("AgentryDataMappingError.invalidMappingData")
        return
    }

    let decoder = JSONDecoder()
    
    decoder.keyDecodingStrategy = .custom(mappingKeys)
    
    let agentryMapping = try decoder.decode(AgentryMapping.self, from: data)
    
    let fv = try resolveFieldValues(fields: agentryMapping.integrationDataMapping.fields)
    
    let encoded = try JSONSerialization.data(withJSONObject: fv, options: .prettyPrinted)
    
    print(">>> encoded = \(String(data: encoded, encoding: .utf8)!)")
}

try doIt()

