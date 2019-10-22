import Foundation

let testString = """
    {
        "integration-metadata": {
            "agentry-object-uid-value": "AgentryObjectUid",
            "agentry-object": "WorkOrder",
            "agentry-object-uid-property": "WONum"
        },
        "integration-type": "agentry",
        "integration-data-exchange": "import",
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
                            "integration-path": [
                                { "property-name": "FunctionalLocations" },
                                { "collection-index": 0 },
                                { "property-name": "ZRegion" }
                            ],
                            "type": "string"
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
}

struct Field : Codable {
    let type: FieldType
    let fields: [String: Field]?
}

struct IntegrationDataMapping : Codable {
    let meta: [String: String]
    let fields: [String: Field]
    
    enum CodingKeys: String, CodingKey {
        case meta = "$meta"
        case fields
    }
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

func resolveFieldValues(fields: [String: Field]) -> [String: Any] {
    var fieldValues: [String: Any] = [:]
    for (fieldName, field) in fields {
        switch field.type {
        case .string:
            fieldValues[fieldName] = ""
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
    
    print(">>> im.dm.meta = \(agentryMapping.integrationDataMapping.meta)")
    
    let fv = resolveFieldValues(fields: agentryMapping.integrationDataMapping.fields)
    
    let encoded = try JSONSerialization.data(withJSONObject: fv, options: .prettyPrinted)
    
    print(">>> encoded = \(String(data: encoded, encoding: .utf8)!)")
}

try doIt()

