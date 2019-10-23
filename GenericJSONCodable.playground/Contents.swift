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
                "pipe-to-soil-transition-section": { "type": "group", "fields": {} },
                "pipe-condition-section": { "type": "group", "fields": {} },
                "pipeline-exposure-section": { "type": "group", "fields": {} },
                "pipe-supports-section": { "type": "group", "fields": {} },
                "pipe-pentrations-section": { "type": "group", "fields": {} },
                "std-form-footer": { "type": "group", "fields": {} },
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
    
    enum CodingKeys: String, CodingKey {
        case agentryObject = "agentry-object"
        case agentryObjectUidValue = "agentry-object-uid-value"
        case agentryObjectUidProperty = "agentry-object-uid-property"
    }
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
    case LAST
}

struct IntegrationPathComponent : Codable {
    let propertyName: String?
    let collectionIndex: Int?
    let agentryValue: String?
    let pathDirective: IntegrationPathDirective?
    
    enum CodingKeys: String, CodingKey {
        case propertyName = "property-name"
        case collectionIndex = "collection-index"
        case agentryValue = "agentry-value"
        case pathDirective = "path-directive"
    }
}

struct IntegrationConcatenationComponent : Codable {
    let contatenationString: String?
    let integrationPath: [IntegrationPathComponent]?
    
    enum CodingKeys: String, CodingKey {
        case contatenationString = "concatenation-string"
        case integrationPath = "integration-path"
    }
}

struct Field : Codable {
    let type: FieldType
    let fields: [String: Field]? // if it's a "group"
    let integrationPath: [IntegrationPathComponent]? // if there is an integration
    let integrationConcatenation: [IntegrationConcatenationComponent]? // if there are multiple integrations
    
    enum CodingKeys: String, CodingKey {
        case type
        case fields
        case integrationPath = "integration-path"
        case integrationConcatenation = "integration-concatenation"
    }
}

struct IntegrationDataMapping : Codable {
    let fields: [String: Field]
}

struct AgentryMapping : Codable {
    
    let integrationType: IntegrationType
    let integrationDataExchange: IntegrationDataExchange
    let integrationMetadata: IntegrationMetadata
    let integrationDataMapping: IntegrationDataMapping
    
    enum CodingKeys: String, CodingKey {
        case integrationType = "integration-type"
        case integrationDataExchange = "integration-data-exchange"
        case integrationMetadata = "integration-metadata"
        case integrationDataMapping = "integration-data-mapping"
    }
}

enum AgentryDataMappingError: Error {
    case invalidMappingData
    case invalidMappingString
    case invalidMappingTarget
}

// #andytodo : return type here might not be a string!
func resolveIntegrationPath(integrationPath: [IntegrationPathComponent]) -> String {
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

func resolveIntegrationConcatenation(integrationConcatenation: [IntegrationConcatenationComponent]) -> String {
    return integrationConcatenation.reduce("") { value, icc in
        var newTerm = ""
        if let concatenationString = icc.contatenationString {
            newTerm = concatenationString
        } else if let integrationPath = icc.integrationPath {
            newTerm = resolveIntegrationPath(integrationPath: integrationPath)
        }
        return value + newTerm
    }
}

func resolveFieldValues(fields: [String: Field]) -> [String: Any] {
    var fieldValues: [String: Any] = [:]
    for (fieldName, field) in fields {
        switch field.type {
        case .string:
            if let integrationPath = field.integrationPath {
                fieldValues[fieldName] = resolveIntegrationPath(integrationPath: integrationPath)
            } else if let integrationConcatenation = field.integrationConcatenation {
                fieldValues[fieldName] = resolveIntegrationConcatenation(integrationConcatenation: integrationConcatenation)
            }
        case .group:
            if let groupFields = field.fields, groupFields.count > 0 {
                fieldValues[fieldName] = resolveFieldValues(fields: groupFields)
            }
        }
    }
    return fieldValues
}

func doIt() throws {
    
    guard let data = testString.data(using: .utf8) else {
        print("AgentryDataMappingError.invalidMappingData")
        return
    }

    let decoder = JSONDecoder()
    let agentryMapping = try decoder.decode(AgentryMapping.self, from: data)
    
    print(">>> it = \(agentryMapping.integrationType)")
    print(">>> ide = \(agentryMapping.integrationDataExchange)")
    
    print(">>> im.ao = \(agentryMapping.integrationMetadata.agentryObject)")
    
    let fv = resolveFieldValues(fields: agentryMapping.integrationDataMapping.fields)
    
    let encoded = try JSONSerialization.data(withJSONObject: fv, options: .prettyPrinted)
    
    print(">>> encoded = \(String(data: encoded, encoding: .utf8)!)")
}

try doIt()

