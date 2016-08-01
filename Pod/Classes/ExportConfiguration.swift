//
//  ExportConfiguration.swift
//  Pods
//
//  Created by Michael Seemann on 16.10.15.
//
//

import Foundation
import HealthKit

/**
    Description of what should be exported.
*/
public protocol ExportConfiguration {
    /// what should be exported - see HealthDataToExportType
    var exportType:HealthDataToExportType {get}
    /// the name of the profile
    var profileName:String {get}
    /// should uuids be exported or not
    var exportUuids:Bool {get}
    /// What date to start at
    var startDate: NSDate? {get}
    /// What date to end at
    var endDate: NSDate? {get}
}

// possible configuration extension: 
// export correlations even if they are present in the correlation type section
// export endDate always - even if the endDate and startDate are the same

internal extension ExportConfiguration {
    
    internal func getPredicate() -> NSPredicate? {
        
        var predicateNoCorreltion = HKQuery.predicateForObjectsWithNoCorrelation()
        
        switch exportType {
        case .ALL:
            break
        case .ADDED_BY_THIS_APP:
            predicateNoCorreltion =  NSCompoundPredicate(andPredicateWithSubpredicates: [predicateNoCorreltion, HKQuery.predicateForObjectsFromSource(HKSource.defaultSource())])
        case .GENERATED_BY_THIS_APP:
            predicateNoCorreltion =  NSCompoundPredicate(andPredicateWithSubpredicates: [predicateNoCorreltion, HKQuery.predicateForObjectsWithMetadataKey("GeneratorSource", allowedValues: ["HSG"])])
        }
        
        if startDate != nil && endDate != nil {
           predicateNoCorreltion = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateNoCorreltion, HKQuery.predicateForSamplesWithStartDate(self.startDate, endDate: self.endDate, options: HKQueryOptions.StrictStartDate)])
                
        }
        return predicateNoCorreltion
    }
}

/**
    Epxort the whole Data from first Entry up to the current Date. E.g. full means the whole period of time.
*/
public struct HealthDataFullExportConfiguration : ExportConfiguration {
    /// what should be exported - see HealthDataToExportType
    public var exportType = HealthDataToExportType.ALL // required
    /// the name of the profile
    public var profileName: String // required
    /// should uuids be exported or not
    public var exportUuids = false
    /// What date to start at
    public var startDate: NSDate?
    /// What date to end at
    public var endDate: NSDate?

    
    /**
        instantiate a HealthDataFullExportConfiguration.
        - Parameter profileName: the name of the profile
        - Parameter exportType: what should be exported. see HealthDataToExportType
    */
    public init(profileName:String, exportType: HealthDataToExportType){
        self.profileName = profileName
        self.exportType = exportType
    }
    
    public init(profileName:String, exportType: HealthDataToExportType, startDate: NSDate, endDate:NSDate){
        self.profileName = profileName
        self.exportType = exportType
        self.startDate = startDate
        self.endDate = endDate
    }
}
