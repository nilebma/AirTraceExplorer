
/**
 * This is a generated class and is not intended for modification.  
 */
package valueObjects
{
import com.adobe.fiber.styles.IStyle;
import com.adobe.fiber.styles.Style;
import com.adobe.fiber.styles.StyleValidator;
import com.adobe.fiber.valueobjects.AbstractEntityMetadata;
import com.adobe.fiber.valueobjects.AvailablePropertyIterator;
import com.adobe.fiber.valueobjects.IPropertyIterator;
import mx.events.ValidationResultEvent;
import com.adobe.fiber.core.model_internal;
import com.adobe.fiber.valueobjects.IModelType;
import mx.events.PropertyChangeEvent;

use namespace model_internal;

[ExcludeClass]
internal class _VOScreenshotEntityMetadata extends com.adobe.fiber.valueobjects.AbstractEntityMetadata
{
    private static var emptyArray:Array = new Array();

    model_internal static var allProperties:Array = new Array("id", "time", "traceUri", "filename");
    model_internal static var allAssociationProperties:Array = new Array();
    model_internal static var allRequiredProperties:Array = new Array("id", "time", "traceUri", "filename");
    model_internal static var allAlwaysAvailableProperties:Array = new Array("id", "time", "traceUri", "filename");
    model_internal static var guardedProperties:Array = new Array();
    model_internal static var dataProperties:Array = new Array("id", "time", "traceUri", "filename");
    model_internal static var sourceProperties:Array = emptyArray
    model_internal static var nonDerivedProperties:Array = new Array("id", "time", "traceUri", "filename");
    model_internal static var derivedProperties:Array = new Array();
    model_internal static var collectionProperties:Array = new Array();
    model_internal static var collectionBaseMap:Object;
    model_internal static var entityName:String = "VOScreenshot";
    model_internal static var dependentsOnMap:Object;
    model_internal static var dependedOnServices:Array = new Array();
    model_internal static var propertyTypeMap:Object;

    
    model_internal var _traceUriIsValid:Boolean;
    model_internal var _traceUriValidator:com.adobe.fiber.styles.StyleValidator;
    model_internal var _traceUriIsValidCacheInitialized:Boolean = false;
    model_internal var _traceUriValidationFailureMessages:Array;
    
    model_internal var _filenameIsValid:Boolean;
    model_internal var _filenameValidator:com.adobe.fiber.styles.StyleValidator;
    model_internal var _filenameIsValidCacheInitialized:Boolean = false;
    model_internal var _filenameValidationFailureMessages:Array;

    model_internal var _instance:_Super_VOScreenshot;
    model_internal static var _nullStyle:com.adobe.fiber.styles.Style = new com.adobe.fiber.styles.Style();

    public function _VOScreenshotEntityMetadata(value : _Super_VOScreenshot)
    {
        // initialize property maps
        if (model_internal::dependentsOnMap == null)
        {
            // dependents map
            model_internal::dependentsOnMap = new Object();
            model_internal::dependentsOnMap["id"] = new Array();
            model_internal::dependentsOnMap["time"] = new Array();
            model_internal::dependentsOnMap["traceUri"] = new Array();
            model_internal::dependentsOnMap["filename"] = new Array();

            // collection base map
            model_internal::collectionBaseMap = new Object();
        }

        // Property type Map
        model_internal::propertyTypeMap = new Object();
        model_internal::propertyTypeMap["id"] = "int";
        model_internal::propertyTypeMap["time"] = "Number";
        model_internal::propertyTypeMap["traceUri"] = "Object";
        model_internal::propertyTypeMap["filename"] = "String";

        model_internal::_instance = value;
        model_internal::_traceUriValidator = new StyleValidator(model_internal::_instance.model_internal::_doValidationForTraceUri);
        model_internal::_traceUriValidator.required = true;
        model_internal::_traceUriValidator.requiredFieldError = "traceUri is required";
        //model_internal::_traceUriValidator.source = model_internal::_instance;
        //model_internal::_traceUriValidator.property = "traceUri";
        model_internal::_filenameValidator = new StyleValidator(model_internal::_instance.model_internal::_doValidationForFilename);
        model_internal::_filenameValidator.required = true;
        model_internal::_filenameValidator.requiredFieldError = "filename is required";
        //model_internal::_filenameValidator.source = model_internal::_instance;
        //model_internal::_filenameValidator.property = "filename";
    }

    override public function getEntityName():String
    {
        return model_internal::entityName;
    }

    override public function getProperties():Array
    {
        return model_internal::allProperties;
    }

    override public function getAssociationProperties():Array
    {
        return model_internal::allAssociationProperties;
    }

    override public function getRequiredProperties():Array
    {
         return model_internal::allRequiredProperties;   
    }

    override public function getDataProperties():Array
    {
        return model_internal::dataProperties;
    }

    public function getSourceProperties():Array
    {
        return model_internal::sourceProperties;
    }

    public function getNonDerivedProperties():Array
    {
        return model_internal::nonDerivedProperties;
    }

    override public function getGuardedProperties():Array
    {
        return model_internal::guardedProperties;
    }

    override public function getUnguardedProperties():Array
    {
        return model_internal::allAlwaysAvailableProperties;
    }

    override public function getDependants(propertyName:String):Array
    {
       if (model_internal::nonDerivedProperties.indexOf(propertyName) == -1)
            throw new Error(propertyName + " is not a data property of entity VOScreenshot");
            
       return model_internal::dependentsOnMap[propertyName] as Array;  
    }

    override public function getDependedOnServices():Array
    {
        return model_internal::dependedOnServices;
    }

    override public function getCollectionProperties():Array
    {
        return model_internal::collectionProperties;
    }

    override public function getCollectionBase(propertyName:String):String
    {
        if (model_internal::collectionProperties.indexOf(propertyName) == -1)
            throw new Error(propertyName + " is not a collection property of entity VOScreenshot");

        return model_internal::collectionBaseMap[propertyName];
    }
    
    override public function getPropertyType(propertyName:String):String
    {
        if (model_internal::allProperties.indexOf(propertyName) == -1)
            throw new Error(propertyName + " is not a property of VOScreenshot");

        return model_internal::propertyTypeMap[propertyName];
    }

    override public function getAvailableProperties():com.adobe.fiber.valueobjects.IPropertyIterator
    {
        return new com.adobe.fiber.valueobjects.AvailablePropertyIterator(this);
    }

    override public function getValue(propertyName:String):*
    {
        if (model_internal::allProperties.indexOf(propertyName) == -1)
        {
            throw new Error(propertyName + " does not exist for entity VOScreenshot");
        }

        return model_internal::_instance[propertyName];
    }

    override public function setValue(propertyName:String, value:*):void
    {
        if (model_internal::nonDerivedProperties.indexOf(propertyName) == -1)
        {
            throw new Error(propertyName + " is not a modifiable property of entity VOScreenshot");
        }

        model_internal::_instance[propertyName] = value;
    }

    override public function getMappedByProperty(associationProperty:String):String
    {
        switch(associationProperty)
        {
            default:
            {
                return null;
            }
        }
    }

    override public function getPropertyLength(propertyName:String):int
    {
        switch(propertyName)
        {
            default:
            {
                return 0;
            }
        }
    }

    override public function isAvailable(propertyName:String):Boolean
    {
        if (model_internal::allProperties.indexOf(propertyName) == -1)
        {
            throw new Error(propertyName + " does not exist for entity VOScreenshot");
        }

        if (model_internal::allAlwaysAvailableProperties.indexOf(propertyName) != -1)
        {
            return true;
        }

        switch(propertyName)
        {
            default:
            {
                return true;
            }
        }
    }

    override public function getIdentityMap():Object
    {
        var returnMap:Object = new Object();
        returnMap["id"] = model_internal::_instance.id;

        return returnMap;
    }

    [Bindable(event="propertyChange")]
    override public function get invalidConstraints():Array
    {
        if (model_internal::_instance.model_internal::_cacheInitialized_isValid)
        {
            return model_internal::_instance.model_internal::_invalidConstraints;
        }
        else
        {
            // recalculate isValid
            model_internal::_instance.model_internal::_isValid = model_internal::_instance.model_internal::calculateIsValid();
            return model_internal::_instance.model_internal::_invalidConstraints;        
        }
    }

    [Bindable(event="propertyChange")]
    override public function get validationFailureMessages():Array
    {
        if (model_internal::_instance.model_internal::_cacheInitialized_isValid)
        {
            return model_internal::_instance.model_internal::_validationFailureMessages;
        }
        else
        {
            // recalculate isValid
            model_internal::_instance.model_internal::_isValid = model_internal::_instance.model_internal::calculateIsValid();
            return model_internal::_instance.model_internal::_validationFailureMessages;
        }
    }

    override public function getDependantInvalidConstraints(propertyName:String):Array
    {
        var dependants:Array = getDependants(propertyName);
        if (dependants.length == 0)
        {
            return emptyArray;
        }

        var currentlyInvalid:Array = invalidConstraints;
        if (currentlyInvalid.length == 0)
        {
            return emptyArray;
        }

        var filterFunc:Function = function(element:*, index:int, arr:Array):Boolean
        {
            return dependants.indexOf(element) > -1;
        }

        return currentlyInvalid.filter(filterFunc);
    }

    /**
     * isValid
     */
    [Bindable(event="propertyChange")] 
    public function get isValid() : Boolean
    {
        if (model_internal::_instance.model_internal::_cacheInitialized_isValid)
        {
            return model_internal::_instance.model_internal::_isValid;
        }
        else
        {
            // recalculate isValid
            model_internal::_instance.model_internal::_isValid = model_internal::_instance.model_internal::calculateIsValid();
            return model_internal::_instance.model_internal::_isValid;
        }
    }

    [Bindable(event="propertyChange")]
    public function get isIdAvailable():Boolean
    {
        return true;
    }

    [Bindable(event="propertyChange")]
    public function get isTimeAvailable():Boolean
    {
        return true;
    }

    [Bindable(event="propertyChange")]
    public function get isTraceUriAvailable():Boolean
    {
        return true;
    }

    [Bindable(event="propertyChange")]
    public function get isFilenameAvailable():Boolean
    {
        return true;
    }


    /**
     * derived property recalculation
     */
    public function invalidateDependentOnTraceUri():void
    {
        if (model_internal::_traceUriIsValidCacheInitialized )
        {
            model_internal::_instance.model_internal::_doValidationCacheOfTraceUri = null;
            model_internal::calculateTraceUriIsValid();
        }
    }
    public function invalidateDependentOnFilename():void
    {
        if (model_internal::_filenameIsValidCacheInitialized )
        {
            model_internal::_instance.model_internal::_doValidationCacheOfFilename = null;
            model_internal::calculateFilenameIsValid();
        }
    }

    model_internal function fireChangeEvent(propertyName:String, oldValue:Object, newValue:Object):void
    {
        this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, propertyName, oldValue, newValue));
    }

    [Bindable(event="propertyChange")]   
    public function get idStyle():com.adobe.fiber.styles.Style
    {
        return model_internal::_nullStyle;
    }

    [Bindable(event="propertyChange")]   
    public function get timeStyle():com.adobe.fiber.styles.Style
    {
        return model_internal::_nullStyle;
    }

    [Bindable(event="propertyChange")]   
    public function get traceUriStyle():com.adobe.fiber.styles.Style
    {
        return model_internal::_nullStyle;
    }

    public function get traceUriValidator() : StyleValidator
    {
        return model_internal::_traceUriValidator;
    }

    model_internal function set _traceUriIsValid_der(value:Boolean):void 
    {
        var oldValue:Boolean = model_internal::_traceUriIsValid;         
        if (oldValue !== value)
        {
            model_internal::_traceUriIsValid = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "traceUriIsValid", oldValue, value));
        }                             
    }

    [Bindable(event="propertyChange")]
    public function get traceUriIsValid():Boolean
    {
        if (!model_internal::_traceUriIsValidCacheInitialized)
        {
            model_internal::calculateTraceUriIsValid();
        }

        return model_internal::_traceUriIsValid;
    }

    model_internal function calculateTraceUriIsValid():void
    {
        var valRes:ValidationResultEvent = model_internal::_traceUriValidator.validate(model_internal::_instance.traceUri)
        model_internal::_traceUriIsValid_der = (valRes.results == null);
        model_internal::_traceUriIsValidCacheInitialized = true;
        if (valRes.results == null)
             model_internal::traceUriValidationFailureMessages_der = emptyArray;
        else
        {
            var _valFailures:Array = new Array();
            for (var a:int = 0 ; a<valRes.results.length ; a++)
            {
                _valFailures.push(valRes.results[a].errorMessage);
            }
            model_internal::traceUriValidationFailureMessages_der = _valFailures;
        }
    }

    [Bindable(event="propertyChange")]
    public function get traceUriValidationFailureMessages():Array
    {
        if (model_internal::_traceUriValidationFailureMessages == null)
            model_internal::calculateTraceUriIsValid();

        return _traceUriValidationFailureMessages;
    }

    model_internal function set traceUriValidationFailureMessages_der(value:Array) : void
    {
        var oldValue:Array = model_internal::_traceUriValidationFailureMessages;

        var needUpdate : Boolean = false;
        if (oldValue == null)
            needUpdate = true;
    
        // avoid firing the event when old and new value are different empty arrays
        if (!needUpdate && (oldValue !== value && (oldValue.length > 0 || value.length > 0)))
        {
            if (oldValue.length == value.length)
            {
                for (var a:int=0; a < oldValue.length; a++)
                {
                    if (oldValue[a] !== value[a])
                    {
                        needUpdate = true;
                        break;
                    }
                }
            }
            else
            {
                needUpdate = true;
            }
        }

        if (needUpdate)
        {
            model_internal::_traceUriValidationFailureMessages = value;   
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "traceUriValidationFailureMessages", oldValue, value));
            // Only execute calculateIsValid if it has been called before, to update the validationFailureMessages for
            // the entire entity.
            if (model_internal::_instance.model_internal::_cacheInitialized_isValid)
            {
                model_internal::_instance.model_internal::isValid_der = model_internal::_instance.model_internal::calculateIsValid();
            }
        }
    }

    [Bindable(event="propertyChange")]   
    public function get filenameStyle():com.adobe.fiber.styles.Style
    {
        return model_internal::_nullStyle;
    }

    public function get filenameValidator() : StyleValidator
    {
        return model_internal::_filenameValidator;
    }

    model_internal function set _filenameIsValid_der(value:Boolean):void 
    {
        var oldValue:Boolean = model_internal::_filenameIsValid;         
        if (oldValue !== value)
        {
            model_internal::_filenameIsValid = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "filenameIsValid", oldValue, value));
        }                             
    }

    [Bindable(event="propertyChange")]
    public function get filenameIsValid():Boolean
    {
        if (!model_internal::_filenameIsValidCacheInitialized)
        {
            model_internal::calculateFilenameIsValid();
        }

        return model_internal::_filenameIsValid;
    }

    model_internal function calculateFilenameIsValid():void
    {
        var valRes:ValidationResultEvent = model_internal::_filenameValidator.validate(model_internal::_instance.filename)
        model_internal::_filenameIsValid_der = (valRes.results == null);
        model_internal::_filenameIsValidCacheInitialized = true;
        if (valRes.results == null)
             model_internal::filenameValidationFailureMessages_der = emptyArray;
        else
        {
            var _valFailures:Array = new Array();
            for (var a:int = 0 ; a<valRes.results.length ; a++)
            {
                _valFailures.push(valRes.results[a].errorMessage);
            }
            model_internal::filenameValidationFailureMessages_der = _valFailures;
        }
    }

    [Bindable(event="propertyChange")]
    public function get filenameValidationFailureMessages():Array
    {
        if (model_internal::_filenameValidationFailureMessages == null)
            model_internal::calculateFilenameIsValid();

        return _filenameValidationFailureMessages;
    }

    model_internal function set filenameValidationFailureMessages_der(value:Array) : void
    {
        var oldValue:Array = model_internal::_filenameValidationFailureMessages;

        var needUpdate : Boolean = false;
        if (oldValue == null)
            needUpdate = true;
    
        // avoid firing the event when old and new value are different empty arrays
        if (!needUpdate && (oldValue !== value && (oldValue.length > 0 || value.length > 0)))
        {
            if (oldValue.length == value.length)
            {
                for (var a:int=0; a < oldValue.length; a++)
                {
                    if (oldValue[a] !== value[a])
                    {
                        needUpdate = true;
                        break;
                    }
                }
            }
            else
            {
                needUpdate = true;
            }
        }

        if (needUpdate)
        {
            model_internal::_filenameValidationFailureMessages = value;   
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "filenameValidationFailureMessages", oldValue, value));
            // Only execute calculateIsValid if it has been called before, to update the validationFailureMessages for
            // the entire entity.
            if (model_internal::_instance.model_internal::_cacheInitialized_isValid)
            {
                model_internal::_instance.model_internal::isValid_der = model_internal::_instance.model_internal::calculateIsValid();
            }
        }
    }


     /**
     * 
     * @inheritDoc 
     */ 
     override public function getStyle(propertyName:String):com.adobe.fiber.styles.IStyle
     {
         switch(propertyName)
         {
            default:
            {
                return null;
            }
         }
     }
     
     /**
     * 
     * @inheritDoc 
     *  
     */  
     override public function getPropertyValidationFailureMessages(propertyName:String):Array
     {
         switch(propertyName)
         {
            case("traceUri"):
            {
                return traceUriValidationFailureMessages;
            }
            case("filename"):
            {
                return filenameValidationFailureMessages;
            }
            default:
            {
                return emptyArray;
            }
         }
     }

}

}
