//
//  String+Pluralize.swift
//  MDRecipes
//
//  Created by Simon Lang on 27.03.23.
//

import Foundation

extension String {
    public var pluralized: String {
        Inflector.default.pluralize(self)
    }
    
    public var singularized: String {
        Inflector.default.singularize(self)
    }
}
